# NotchDrop 🎮

A custom notch overlay with pixel-art animations triggered via CLI.

Toasts "slide down" from under the notch with a spring animation, display an animated pixel-art sprite, and dismiss after 2.8s. Clicking the toast performs an action (e.g., focusing the terminal).

## Quick Start

```bash
# Build the project
./Scripts/build.sh

# Install (/Applications + /usr/local/bin)
./Scripts/install.sh

# Launch the app
open /Applications/NotchDrop.app

# Test it
notchdrop notify --title "Claude Code" --kind waiting --sound Glass --action focus
```

## Architecture

- **NotchDrop.app**: Background agent (LSUIElement) built with AppKit/SwiftUI.
  - Borderless `NSPanel` at `.statusBar` level for true overlay behavior.
  - `NSVisualEffectView` for a modern "HUD" blur.
  - Programmatic pixel-art rendering (CALayer, nearest-neighbor).
  - Custom URL scheme handler: `notchdrop://notify?b64=...`
- **notchdrop CLI**: A lightweight wrapper that encodes payloads into base64url and triggers the app via `open -g`.

## Smart Hook Integration (Claude Code)

Instead of a static command, NotchDrop includes a smart hook script (`notchdrop-hook`) that automatically detects the notification type.

### Installation for Claude Code

1. Install NotchDrop normally using `./Scripts/install.sh`.
2. Update your `~/.claude/settings.json`:

```json
"hooks": {
  "Notification": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "notchdrop-hook"
        }
      ]
    }
  ]
}
```

### How it works
The hook analyzes the notification text and picks the appropriate kind:
- **Success**: "Task completed", "Done", "Built" -> Green sprite + Glass sound.
- **Error**: "Fail", "Error", "Problem" -> Red sprite + Basso sound.
- **Waiting/Prompt**: "Decision", "Input", "Wait" -> Amber sprite + Glass sound.
- **Random Variants**: If no message is provided, NotchDrop picks one of 15+ fun, Anthropic-style variants (e.g., *"Claude is making tea while waiting ☕"*, *"Your move, human 🎲"*).

## CLI Usage — `notchdrop notify`

```bash
OPTIONS:
    --title, -t        Title (default: "NotchDrop")
    --message, -m      Message text (if omitted, a random fun variant is picked!)
    --kind, -k         Kind: waiting|success|error|info (default: info)
    --duration, -d     Display duration in seconds (default: 2.8)
    --sound, -s        System sound: Glass|Submarine|Basso|...
    --action, -a       Click action: focus|open-url|none (default: none)
    --url, -u          URL for open-url action
```

## Visual Specs

| Element       | Specification                        |
| ------------- | ------------------------------------ |
| Size          | 420×64 px                            |
| Corner Radius | 20 px                                |
| Background    | NSVisualEffectView (blur .hudWindow) |
| Border        | 1px white @ 15% alpha                |
| Pixel-art     | 36×36, crisp (nearest-neighbor)      |
| Title         | System semibold 12.5pt               |
| Message       | System regular 11pt, 75% opacity     |

## Positioning
- Automatically finds the screen with the mouse cursor.
- Centers horizontally under the notch/safe-area.
- Works on Macs without a notch (positions under the menu bar).

## Requirements
- macOS 13.0+
- Xcode Command Line Tools (`xcode-select --install`)

