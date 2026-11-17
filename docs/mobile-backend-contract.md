# Mobile backend API contract

All authenticated routes use:

```text
Authorization: Bearer <token>
```

## Routes

| Method | Route | Purpose |
|---|---|---|
| POST | `/wp-json/rebs/v1/auth/login` | Create a mobile session |
| POST | `/wp-json/rebs/v1/auth/register` | Create an account pending activation |
| GET | `/wp-json/rebs/v1/auth/me` | Read the authenticated user |
| GET | `/wp-json/rebs/v1/saved-properties` | Read account saved property IDs |
| POST | `/wp-json/rebs/v1/saved-properties` | Replace account saved property IDs |
| POST | `/wp-json/rebs/v1/leads` | Submit a property inquiry |

## Saved properties

Response:

```json
{"property_ids":[12,45]}
```

Update request:

```json
{"property_ids":[12,45]}
```

The server normalizes IDs to positive integers, removes duplicates, and stores them per WordPress user.

## Installation status

The PHP implementation is committed under `wordpress-api-extension/`. It is source code only and still needs to be installed on the WordPress site before mobile authentication or account synchronization can work against production.
