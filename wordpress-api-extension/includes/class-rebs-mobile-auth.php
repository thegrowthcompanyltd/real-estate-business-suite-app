<?php
if (!defined('ABSPATH')) exit;

/**
 * Token authentication for the mobile client.
 *
 * Tokens are returned only once, stored as SHA-256 hashes, and expire after
 * 30 days. WordPress passwords and auth cookies are never exposed to the app.
 */
class REBS_Mobile_Auth {
    private const TOKEN_META_KEY = '_rebs_mobile_tokens';
    private const TOKEN_INDEX_OPTION = 'rebs_mobile_token_index';
    private const TOKEN_TTL = 2592000;

    public function __construct() {
        add_action('rest_api_init', [$this, 'register_routes']);
    }

    public function register_routes() {
        register_rest_route('rebs/v1', '/auth/login', [
            'methods' => WP_REST_Server::CREATABLE,
            'callback' => [$this, 'login'],
            'permission_callback' => '__return_true',
        ]);
        register_rest_route('rebs/v1', '/auth/register', [
            'methods' => WP_REST_Server::CREATABLE,
            'callback' => [$this, 'register'],
            'permission_callback' => '__return_true',
        ]);
        register_rest_route('rebs/v1', '/auth/me', [
            'methods' => WP_REST_Server::READABLE,
            'callback' => [$this, 'me'],
            'permission_callback' => [$this, 'authenticated_request'],
        ]);
    }

    public function login(WP_REST_Request $request) {
        $identifier = sanitize_text_field((string) $request->get_param('email'));
        $password = (string) $request->get_param('password');
        if (!$identifier || !$password) return new WP_Error('invalid_login', 'Email and password are required.', ['status' => 400]);

        $user = wp_authenticate($identifier, $password);
        if (is_wp_error($user)) return new WP_Error('invalid_login', 'Invalid email or password.', ['status' => 401]);
        if ($this->is_blocked($user->ID)) return new WP_Error('account_unavailable', 'This account is awaiting activation or is suspended.', ['status' => 403]);

        return rest_ensure_response($this->issue_session($user));
    }

    public function register(WP_REST_Request $request) {
        if (!(int) get_option('rebs_registration_enabled', 1)) return new WP_Error('registration_disabled', 'Registration is currently closed.', ['status' => 403]);

        $name = sanitize_text_field((string) $request->get_param('name'));
        $email = sanitize_email((string) $request->get_param('email'));
        $password = (string) $request->get_param('password');
        $plan = sanitize_key((string) $request->get_param('plan'));
        if (!$name || !is_email($email) || strlen($password) < 12) return new WP_Error('invalid_registration', 'Name, valid email, and a password of at least 12 characters are required.', ['status' => 400]);
        if (email_exists($email)) return new WP_Error('email_exists', 'An account already exists for this email.', ['status' => 409]);

        $plans = class_exists('REBS_Billing') ? REBS_Billing::instance()->plans() : [];
        if ($plans && (!$plan || empty($plans[$plan]) || empty($plans[$plan]['enabled']))) return new WP_Error('plan_required', 'Select an available subscription plan.', ['status' => 400]);

        $username = sanitize_user(strtok($email, '@'), true);
        if (!$username || username_exists($username)) $username = 'rebs_' . wp_generate_password(8, false, false);
        $user_id = wp_insert_user(['user_login' => $username, 'user_pass' => $password, 'user_email' => $email, 'display_name' => $name, 'role' => 'rebs_manager']);
        if (is_wp_error($user_id)) return new WP_Error('registration_failed', $user_id->get_error_message(), ['status' => 400]);

        update_user_meta($user_id, 'rebs_re_customer', '1');
        update_user_meta($user_id, 'rebs_account_owner', $user_id);
        update_user_meta($user_id, 'rebs_account_pending', 1);
        update_user_meta($user_id, 'rebs_subscription_status', 'awaiting_approval');
        update_user_meta($user_id, 'rebs_business_contact_email', $email);
        if ($plan) update_user_meta($user_id, 'rebs_subscription_plan', $plan);
        if ($plans && $plan && !empty($plans[$plan]['currency'])) update_user_meta($user_id, 'rebs_business_currency', $plans[$plan]['currency']);

        return new WP_REST_Response(['success' => true, 'pending' => true, 'message' => 'Account created and awaiting activation.'], 201);
    }

    public function me(WP_REST_Request $request) {
        $user = $this->user_from_request($request);
        if (!$user) return new WP_Error('invalid_token', 'Your session is invalid or expired.', ['status' => 401]);
        if ($this->is_blocked($user->ID)) return new WP_Error('account_unavailable', 'This account is awaiting activation or is suspended.', ['status' => 403]);
        return rest_ensure_response(['user' => $this->user_payload($user)]);
    }

    public function authenticated_request(WP_REST_Request $request) {
        return (bool) $this->user_from_request($request);
    }

    private function issue_session(WP_User $user) {
        $now = time();
        $raw = 'rebs_' . bin2hex(random_bytes(32));
        $record = ['user_id' => (int) $user->ID, 'hash' => hash('sha256', $raw), 'expires' => $now + self::TOKEN_TTL];
        $user_tokens = array_values(array_filter($this->tokens_for($user->ID), function ($token) use ($now) { return !empty($token['expires']) && (int) $token['expires'] > $now; }));
        $user_tokens[] = $record;
        update_user_meta($user->ID, self::TOKEN_META_KEY, array_slice($user_tokens, -5));

        $index = array_values(array_filter($this->tokens_for(0), function ($token) use ($now) { return !empty($token['expires']) && (int) $token['expires'] > $now; }));
        $index[] = $record;
        update_option(self::TOKEN_INDEX_OPTION, array_slice($index, -500), false);
        return ['token' => $raw, 'expires_at' => gmdate('c', $now + self::TOKEN_TTL), 'user' => $this->user_payload($user)];
    }

    private function user_from_request(WP_REST_Request $request) {
        $header = (string) $request->get_header('authorization');
        if (!preg_match('/^Bearer\s+(.+)$/i', $header, $matches)) return null;
        $presented = trim($matches[1]);
        if (!$presented) return null;
        $hash = hash('sha256', $presented);
        foreach ($this->tokens_for(0) as $token) {
            if (!empty($token['hash']) && !empty($token['expires']) && (int) $token['expires'] > time() && hash_equals($token['hash'], $hash)) return get_user_by('id', (int) ($token['user_id'] ?? 0));
        }
        return null;
    }

    private function tokens_for($user_id) {
        $key = $user_id ? self::TOKEN_META_KEY : self::TOKEN_INDEX_OPTION;
        $tokens = $user_id ? get_user_meta($user_id, $key, true) : get_option($key, []);
        return is_array($tokens) ? $tokens : [];
    }

    private function is_blocked($user_id) {
        return (bool) get_user_meta($user_id, 'rebs_account_pending', true) || (bool) get_user_meta($user_id, 'rebs_suspended', true);
    }

    private function user_payload(WP_User $user) {
        return ['id' => (int) $user->ID, 'email' => $user->user_email, 'name' => $user->display_name, 'role' => $this->primary_role($user)];
    }

    private function primary_role(WP_User $user) {
        foreach (['administrator', 'rebs_manager', 'rebs_agent'] as $role) if (in_array($role, (array) $user->roles, true)) return $role;
        return !empty($user->roles[0]) ? (string) $user->roles[0] : 'client';
    }
}
