#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT_DIR/EbookApp.xcodeproj"
SCHEME="EbookApp"
ARCHIVE_PATH="$ROOT_DIR/build/EbookApp.xcarchive"
EXPORT_PATH="$ROOT_DIR/build/export"
EXPORT_OPTIONS="$ROOT_DIR/Config/ExportOptions.plist"

echo "==> Archive (Release)"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  clean archive

echo "==> Export & Upload to App Store Connect"
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -exportPath "$EXPORT_PATH"

echo "==> Done"
echo "Archive: $ARCHIVE_PATH"
echo "TestFlight 처리는 App Store Connect에서 확인하세요."
