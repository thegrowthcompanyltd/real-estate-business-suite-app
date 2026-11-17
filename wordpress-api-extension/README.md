# WordPress mobile authentication extension

This directory contains the mobile authentication extension for Real Estate Business Suite v1.10.2.

## Installation

1. Back up the WordPress site and plugin directory.
2. Copy `includes/class-rebs-mobile-auth.php` into the plugin directory:
   `real-estate-business-suite/includes/class-rebs-mobile-auth.php`
3. In `real-estate-business-suite.php`, after the existing `class-rebs-rest.php` require, add:

```php
require_once REBS_PATH . 'includes/class-rebs-mobile-auth.php';
```

4. In `rebs_init_plugin()`, after `REBS_REST::instance();`, add:

```php
REBS_Mobile_Auth::instance();
```

5. Save the plugin, clear any page/cache/CDN cache, and test the three routes.

## Routes

- `POST /wp-json/rebs/v1/auth/login`
- `POST /wp-json/rebs/v1/auth/register`
- `GET /wp-json/rebs/v1/auth/me`

Use the bearer token returned by login:

```text
Authorization: Bearer <token>
```

## Security behavior

- Passwords are never returned to the client.
- Tokens are returned only during login.
- Only SHA-256 token hashes are stored.
- Tokens expire after 30 days.
- Each user keeps at most five user-scoped token records.
- The global lookup index keeps at most 500 active records and removes expired records on new login.
- Pending and suspended REBS accounts cannot log in or call `/auth/me`.
- Existing web authentication and registration flows are not modified.

This extension is committed as source code only; it has not been installed on the live WordPress site by this repository operation.
