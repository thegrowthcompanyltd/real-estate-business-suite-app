# Live WordPress deployment checklist

The mobile authentication and saved-property routes are implemented in:

```text
wordpress-api-extension/includes/class-rebs-mobile-auth.php
```

## Install

1. Back up the WordPress plugin directory and database.
2. Copy the PHP class into the active Real Estate Business Suite plugin:

```text
real-estate-business-suite/includes/class-rebs-mobile-auth.php
```

3. Add the require after the existing REST class require:

```php
require_once REBS_PATH . 'includes/class-rebs-mobile-auth.php';
```

4. Initialize the class after the existing REST initialization:

```php
REBS_Mobile_Auth::instance();
```

5. Clear WordPress page cache, object cache, and CDN cache.
6. Confirm PHP syntax:

```bash
php -l includes/class-rebs-mobile-auth.php
```

## Verification

The following routes should be available after installation:

```text
POST /wp-json/rebs/v1/auth/login
POST /wp-json/rebs/v1/auth/register
GET  /wp-json/rebs/v1/auth/me
GET  /wp-json/rebs/v1/saved-properties
POST /wp-json/rebs/v1/saved-properties
```

The saved-property route requires:

```text
Authorization: Bearer <token>
```

The live saved-property route currently returns a no-route response, which confirms the extension has not yet been installed on production.

Do not enable production mobile sign-in until the authenticated routes have been tested on staging first.
