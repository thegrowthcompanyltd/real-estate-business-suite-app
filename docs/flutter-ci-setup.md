# Flutter CI setup

The GitHub connector cannot write files under hidden dot-directories, so create
`.github/workflows/flutter-ci.yml` manually in the repository web interface and
paste the workflow below.

```yaml
name: Flutter CI

on:
  push:
    branches: [feature/mobile-app-foundation]
  pull_request:
    branches: [main, feature/mobile-app-foundation]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze --fatal-infos

      - name: Run tests
        run: flutter test
```

Local equivalent: `bash tool/run_checks.sh`
