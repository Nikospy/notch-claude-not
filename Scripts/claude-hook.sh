#!/bin/bash
# NotchDrop smart hook for Claude Code
# Analyzes notification context and picks the right kind + message.
#
# Claude Code passes notification info via environment.
# We parse it and route to the correct notchdrop kind.

# Get the notification text from Claude Code hook arguments
NOTIFICATION_TEXT="${CLAUDE_NOTIFICATION:-}"

# If empty, try reading from $1 or stdin
if [ -z "$NOTIFICATION_TEXT" ]; then
    NOTIFICATION_TEXT="${1:-}"
fi

# ─── Detect kind based on content keywords ───────────────
detect_kind() {
    local text="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

    # Error patterns
    if echo "$text" | grep -qiE 'error|fail|exception|crash|bug|broken|nie powiod|błąd|problem|fatal|panic|segfault'; then
        echo "error"
        return
    fi

    # Success patterns
    if echo "$text" | grep -qiE 'success|complete|done|finish|gotowe|zakończon|pomyślnie|sukces|pass|merged|deployed|built|compiled'; then
        echo "success"
        return
    fi

    # Waiting/input patterns (most common for Claude Code notifications)
    if echo "$text" | grep -qiE 'wait|input|decision|decyzj|czeka|question|confirm|review|approve|attention|respond|odpowied|wybierz|choose|accept|reject|permission'; then
        echo "waiting"
        return
    fi

    # Default: waiting (Claude Code notifications are usually "needs your attention")
    echo "waiting"
}

# ─── Detect sound based on kind ──────────────────────────
detect_sound() {
    case "$1" in
        error)   echo "Basso" ;;
        success) echo "Glass" ;;
        waiting) echo "Glass" ;;
        info)    echo "Pop" ;;
        *)       echo "Glass" ;;
    esac
}

# ─── Main ─────────────────────────────────────────────────
KIND=$(detect_kind "$NOTIFICATION_TEXT")
SOUND=$(detect_sound "$KIND")

# Build notchdrop command
exec notchdrop notify \
    -t "Claude Code" \
    -k "$KIND" \
    -s "$SOUND" \
    --action focus
