#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
flutter_version=3.35.7
flutter_sdk=".flutter-sdk/$flutter_version"

if [ ! -d "$flutter_sdk/.git" ]; then
  git clone --depth 1 --branch "$flutter_version" \
    https://github.com/flutter/flutter.git "$flutter_sdk"
fi

"$flutter_sdk/bin/flutter" --version
"$flutter_sdk/bin/flutter" pub get --enforce-lockfile
