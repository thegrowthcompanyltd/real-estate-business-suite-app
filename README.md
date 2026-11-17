# Real Estate Business Suite App

Cross-platform Flutter foundation for Android and iPhone, connected to the Real Estate Business Suite WordPress installation.

## Development branch

`feature/mobile-app-foundation`

## Current foundation

- Flutter application entry point
- Material 3 theme
- Property feed screen
- WordPress property API client
- Loading, empty, error, and refresh states
- Defensive response parsing and request timeout

## Backend

The current public property endpoint is:

`GET https://realtyeasy.sitesavvvy.com/wp-json/rebs/v1/properties`

Authenticated API work will be added in a later phase. WordPress remains the system of record; app secrets must not be committed to this repository.

## Run locally

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
