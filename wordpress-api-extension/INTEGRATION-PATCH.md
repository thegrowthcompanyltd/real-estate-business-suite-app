# Mobile auth integration patch

Source plugin inspected from the uploaded Real Estate Business Suite v1.10.2 archive:

```text
real-estate-business-suite/real-estate-business-suite.php
```

Apply these two changes to the active plugin copy.

## 1. Add the class require

Immediately after:

```php
require_once REBS_PATH . 'includes/class-rebs-rest.php';
```

add:

```php
require_once REBS_PATH . 'includes/class-rebs-mobile-auth.php';
```

Copy the implementation from:

```text
wordpress-api-extension/includes/class-rebs-mobile-auth.php
```

into the plugin's `includes` directory.

## 2. Initialize the class

Inside `rebs_init_plugin()`, immediately after:

```php
REBS_REST::instance();
```

add:

```php
new REBS_Mobile_Auth();
```

Do not add the initialization twice. The class constructor registers its REST routes on `rest_api_init`.

## 3. Validate before activation

From the plugin directory, run:

```bash
php -l includes/class-rebs-mobile-auth.php
php -l real-estate-business-suite.php
```

Then activate the updated plugin on staging and clear WordPress, object, page, and CDN caches.

## 4. Verify route registration

Expected routes:

```text
POST /wp-json/rebs/v1/auth/login
POST /wp-json/rebs/v1/auth/register
GET  /wp-json/rebs/v1/auth/me
GET  /wp-json/rebs/v1/saved-properties
POST /wp-json/rebs/v1/saved-properties
```

The protected routes must be tested with a bearer token. Do not use production credentials in source control or test commands committed to the repository.

## Current status

The source extension is ready in this repository. The uploaded ZIP remains unchanged, and the live WordPress installation still requires an administrator or hosting-level deployment action.
