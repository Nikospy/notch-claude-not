#!/bin/bash
set -euo pipefail

# NotchDrop Build Script
# Builds NotchDrop.app bundle and notchdrop CLI

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_NAME="NotchDrop"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "╔══════════════════════════════════════╗"
echo "║     Building NotchDrop v1.0.0        ║"
echo "╚══════════════════════════════════════╝"

# Clean
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ─── Build the App ───────────────────────────────────────
echo ""
echo "▸ Building $APP_NAME.app..."

# Create app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy Info.plist
cp "$ROOT_DIR/NotchDrop/Resources/Info.plist" "$APP_BUNDLE/Contents/"

# Compile all Swift sources into the app binary
APP_SOURCES=(
    "$ROOT_DIR/NotchDrop/Sources/App/NotchDropApp.swift"
    "$ROOT_DIR/NotchDrop/Sources/Models/NotificationPayload.swift"
    "$ROOT_DIR/NotchDrop/Sources/Models/MessageVariants.swift"
    "$ROOT_DIR/NotchDrop/Sources/Managers/NotificationManager.swift"
    "$ROOT_DIR/NotchDrop/Sources/Managers/SpriteGenerator.swift"
    "$ROOT_DIR/NotchDrop/Sources/Views/OverlayPanel.swift"
    "$ROOT_DIR/NotchDrop/Sources/Views/ToastContentView.swift"
    "$ROOT_DIR/NotchDrop/Sources/Views/SpriteAnimationView.swift"
    "$ROOT_DIR/NotchDrop/Sources/Views/ToastOverlayView.swift"
)

swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/NotchDrop" \
    -target "$(uname -m)-apple-macosx13.0" \
    -sdk "$(xcrun --show-sdk-path)" \
    -framework AppKit \
    -framework SwiftUI \
    -framework Combine \
    -O \
    -parse-as-library \
    "${APP_SOURCES[@]}"

echo "  ✓ App binary compiled"

# Sign the app (ad-hoc)
codesign --force --sign - "$APP_BUNDLE" 2>/dev/null || true
echo "  ✓ App signed (ad-hoc)"

# ─── Build the CLI ───────────────────────────────────────
echo ""
echo "▸ Building notchdrop CLI..."

swiftc \
    -o "$BUILD_DIR/notchdrop" \
    -target "$(uname -m)-apple-macosx13.0" \
    -sdk "$(xcrun --show-sdk-path)" \
    -O \
    "$ROOT_DIR/CLI/Sources/main.swift"

echo "  ✓ CLI compiled"

# ─── Summary ─────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════╗"
echo "║        Build Complete! ✓             ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  App:  $APP_BUNDLE"
echo "  CLI:  $BUILD_DIR/notchdrop"
echo ""
echo "To install, run:"
echo "  ./Scripts/install.sh"
echo ""
echo "To test immediately:"
echo "  open $APP_BUNDLE"
echo "  sleep 2"
echo "  $BUILD_DIR/notchdrop notify --title 'Hello' --message 'NotchDrop works!' --kind success --sound Glass"
