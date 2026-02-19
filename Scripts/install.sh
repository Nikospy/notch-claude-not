#!/bin/bash
set -euo pipefail

# NotchDrop Install Script
# Copies NotchDrop.app to /Applications and symlinks CLI to /usr/local/bin

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"

APP_SRC="$BUILD_DIR/NotchDrop.app"
CLI_SRC="$BUILD_DIR/notchdrop"

APP_DST="/Applications/NotchDrop.app"
CLI_DST="/usr/local/bin/notchdrop"

echo "╔══════════════════════════════════════╗"
echo "║     Installing NotchDrop v1.0.0      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check build exists
if [ ! -d "$APP_SRC" ]; then
    echo "Error: Build not found. Run ./Scripts/build.sh first."
    exit 1
fi

if [ ! -f "$CLI_SRC" ]; then
    echo "Error: CLI binary not found. Run ./Scripts/build.sh first."
    exit 1
fi

# ─── Install App ─────────────────────────────────────────
echo "▸ Installing NotchDrop.app to /Applications..."

# Kill running instance if any
osascript -e 'tell application "NotchDrop" to quit' 2>/dev/null || true
sleep 0.5

# Remove old version
if [ -d "$APP_DST" ]; then
    rm -rf "$APP_DST"
    echo "  ↻ Removed old version"
fi

cp -R "$APP_SRC" "$APP_DST"
echo "  ✓ App installed to $APP_DST"

# ─── Install CLI ─────────────────────────────────────────
echo ""
echo "▸ Installing notchdrop CLI..."

# Ensure /usr/local/bin exists
if [ ! -d "/usr/local/bin" ]; then
    sudo mkdir -p /usr/local/bin
fi

# Try /usr/local/bin first, fall back to ~/bin
if [ -w "/usr/local/bin" ] || sudo -n true 2>/dev/null; then
    sudo cp "$CLI_SRC" "$CLI_DST"
    sudo chmod +x "$CLI_DST"
    echo "  ✓ CLI installed to $CLI_DST"
else
    mkdir -p "$HOME/bin"
    cp "$CLI_SRC" "$HOME/bin/notchdrop"
    chmod +x "$HOME/bin/notchdrop"
    echo "  ✓ CLI installed to $HOME/bin/notchdrop"
    echo "  ℹ️  Add ~/bin to your PATH if not already there:"
    echo "     export PATH=\"\$HOME/bin:\$PATH\""
fi

# ─── Register URL scheme ─────────────────────────────────
echo ""
echo "▸ Registering URL scheme..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_DST" 2>/dev/null || true
echo "  ✓ URL scheme notchdrop:// registered"

# ─── Summary ─────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Installation Complete! ✓         ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  Quick start:"
echo "    1. Open NotchDrop:  open /Applications/NotchDrop.app"
echo "    2. Test:            notchdrop notify --title 'Test' --message 'Działa!' --kind success --sound Glass"
echo ""
echo "  Hook integration (Claude Code):"
echo '    notchdrop notify --title "Claude Code" --message "Claude czeka na Twoją decyzję" --kind waiting --sound Glass --action focus'
echo ""
