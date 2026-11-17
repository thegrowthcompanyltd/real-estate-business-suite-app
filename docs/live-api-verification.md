# Live API verification status

Checked on 2026-11-17.

## Working route

```text
GET https://realtyeasy.sitesavvvy.com/wp-json/rebs/v1/properties
```

The public properties route is available.

## Routes not installed yet

The following routes currently return a WordPress no-route response in production:

```text
POST /wp-json/rebs/v1/auth/login
POST /wp-json/rebs/v1/auth/register
GET  /wp-json/rebs/v1/auth/me
GET  /wp-json/rebs/v1/saved-properties
POST /wp-json/rebs/v1/saved-properties
```

## Required next action

Install `wordpress-api-extension/includes/class-rebs-mobile-auth.php` into the active Real Estate Business Suite plugin, add the bootstrap require and initialization, clear WordPress and CDN caches, then verify the routes on staging before production use.

No production credentials or deployment connector are available in this workflow, so the installation cannot be performed automatically.
