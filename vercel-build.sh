#!/bin/bash
set -e

FLUTTER_VERSION="3.44.0"

git clone https://github.com/flutter/flutter.git --depth 1 --branch "$FLUTTER_VERSION" _flutter
export PATH="$PATH:$PWD/_flutter/bin"

flutter pub get

echo "API_BASE_URL=$API_BASE_URL" > .env

flutter build web --release
