# NotchDrop 🎮

Własna nakładka pod notchem — pixel-art overlay triggerowany z CLI.

Toast "wysuwa się" spod notcha z animacją spring, wyświetla pixel-art sprite z animacją,
i znika po 2.8s. Kliknięcie wykonuje akcję (np. focus na aplikację).

## Quick Start

```bash
# Budowanie
./Scripts/build.sh

# Instalacja (/Applications + /usr/local/bin)
./Scripts/install.sh

# Uruchomienie
open /Applications/NotchDrop.app

# Test
notchdrop notify --title "Claude Code" --message "Claude czeka na Twoją decyzję" --kind waiting --sound Glass --action focus
```

## Architektura

```
NotchDrop.app (agent, bez Docka — LSUIElement)
   ├── NSPanel (borderless, non-activating, .statusBar level)
   ├── NSVisualEffectView (blur: .hudWindow)
   ├── SwiftUI layout (pill shape)
   ├── CALayer pixel-art (nearest-neighbor, 32×32)
   └── URL scheme handler: notchdrop://notify?b64=...

notchdrop CLI
   └── JSON → base64url → open -g "notchdrop://notify?b64=..."
```

## CLI — `notchdrop notify`

```
USAGE:
    notchdrop notify [options]

OPTIONS:
    --title, -t        Tytuł (default: "NotchDrop")
    --message, -m      Treść wiadomości
    --kind, -k         Rodzaj: waiting|success|error|info (default: info)
    --duration, -d     Czas wyświetlania w sekundach (default: 2.8)
    --sound, -s        Dźwięk systemowy: Glass|Submarine|Basso|... (default: brak)
    --action, -a       Akcja po kliknięciu: focus|open-url|none (default: none)
    --app-bundle-id, -b  Bundle ID dla focus action
    --url, -u          URL dla open-url action
```

## Przykłady

```bash
# Waiting — Claude czeka
notchdrop notify \
  --title "Claude Code" \
  --message "Claude czeka na Twoją decyzję" \
  --kind waiting \
  --sound Glass \
  --action focus

# Success
notchdrop notify -t "Build" -m "Kompilacja OK!" -k success -s Glass

# Error
notchdrop notify -t "Error" -m "Kompilacja nie powiodła się" -k error -s Basso

# Info
notchdrop notify -t "Info" -m "Nowa wersja dostępna" -k info
```

## Hook Integration (Claude Code)

```json
{
  "type": "command",
  "command": "notchdrop notify --title \"Claude Code\" --message \"Claude czeka na Twoją decyzję\" --kind waiting --sound Glass --action focus"
}
```

## Wygląd

| Element       | Specyfikacja                         |
| ------------- | ------------------------------------ |
| Rozmiar       | 420×64 px                            |
| Corner radius | 20 px                                |
| Tło           | NSVisualEffectView (blur .hudWindow) |
| Border        | 1px white @ 15% alpha                |
| Cień          | black @ 25%, blur 12, offset y:4     |
| Pixel-art     | 36×36, nearest-neighbor (crisp)      |
| Title         | System semibold 12.5pt               |
| Message       | System regular 11pt, 75% opacity     |

## Kolory akcentu (per kind)

| Kind    | Kolor      | Hex       |
| ------- | ---------- | --------- |
| waiting | Warm amber | `#D4A574` |
| success | Soft green | `#7EC897` |
| error   | Soft coral | `#E88B8B` |
| info    | Soft blue  | `#8BB8E8` |

## Animacje

- **Wejście:** slide-down + spring (0.45s, damping 0.72)
- **Sprite:** 10 FPS loop przez ~1.2s, potem stop na idle
- **Wyjście:** fade + slide-up (0.25s)
- **Kolejka:** update content + restart timer (bez chowania)

## Pozycjonowanie

- Ekran z kursorem (fallback: main screen)
- X: wycentrowane
- Y: tuż pod notch/safe-area + 8px
- Mac bez notcha: pod paskiem menu (działa tak samo)

## Interakcje

- **Klik:** wykonaj akcję (focus/open-url) + dismiss
- Brak alert/prompt — ciche overlay

## Struktura projektu

```
notch-claude-not/
├── NotchDrop/Sources/
│   ├── App/NotchDropApp.swift          # Entry point + URL handler
│   ├── Models/NotificationPayload.swift # Data models
│   ├── Managers/
│   │   ├── NotificationManager.swift    # Show/dismiss/queue logic
│   │   └── SpriteGenerator.swift        # Programmatic pixel-art
│   └── Views/
│       ├── OverlayPanel.swift           # NSPanel (borderless overlay)
│       ├── ToastContentView.swift       # SwiftUI pill layout
│       ├── SpriteAnimationView.swift    # CALayer sprite animation
│       └── ToastOverlayView.swift       # Root view + animations
├── CLI/Sources/main.swift               # CLI tool
├── Scripts/
│   ├── build.sh                         # Build script
│   └── install.sh                       # Install script
└── README.md
```

## Wymagania

- macOS 13.0+
- Xcode Command Line Tools (`xcode-select --install`)
