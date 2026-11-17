#!/usr/bin/env bash
# Local checks mirroring the Flutter CI workflow.
set -euo pipefail

flutter pub get
flutter analyze --fatal-infos
flutter test
