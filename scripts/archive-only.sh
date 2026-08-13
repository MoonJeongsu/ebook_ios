#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT_DIR/EbookApp.xcodeproj"
SCHEME="EbookApp"
ARCHIVE_PATH="$ROOT_DIR/build/EbookApp.xcarchive"

echo "==> Archive only (Release)"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  clean archive

echo "==> Archive created: $ARCHIVE_PATH"
echo "Xcode → Window → Organizer 에서 Distribute App 으로 업로드할 수 있습니다."
