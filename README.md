# Real Estate Business Suite App

Cross-platform Flutter foundation for Android and iPhone, connected to the Real Estate Business Suite WordPress installation.

## Development branch

`feature/mobile-app-foundation`

## Current foundation

- Flutter application entry point with Material 3 navigation
- Public property feed with loading, empty, error, retry, and refresh states
- Property search, detail view, gallery-ready property model, and inquiry form
- WordPress property API client
- Auth session models and token-based login/registration client
- Persistent platform-secure authentication sessions
- Persistent local saved properties
- Authenticated account lookup and lead submission client
- WordPress mobile-auth extension source and installation guide
- Authentication client characterization tests

## Backend

Public endpoint:

`GET https://realtyeasy.sitesavvvy.com/wp-json/rebs/v1/properties`

Authenticated contracts:

```text
POST /wp-json/rebs/v1/auth/login
POST /wp-json/rebs/v1/auth/register
GET  /wp-json/rebs/v1/auth/me
POST /wp-json/rebs/v1/leads
```

The auth extension is committed under `wordpress-api-extension/`, but it has not been installed on the live WordPress site. WordPress remains the system of record; app secrets must not be committed to this repository.

## Local storage

- Authentication tokens are stored with `flutter_secure_storage`, using Android Keystore and iOS Keychain-backed storage.
- Saved property IDs are non-sensitive preferences and remain in `shared_preferences`.
- Expired or malformed authentication sessions are deleted automatically.

## Run locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Backend installation check

After installing the PHP extension into the WordPress plugin, run:

```bash
php -l includes/class-rebs-mobile-auth.php
```

Then test the routes on staging before enabling mobile login.
