import AppKit

// MARK: - Pixel Art Sprite Generator
// Generates pixel art sprites programmatically for each notification kind.
// Each kind has 8 frames of animation + 1 idle frame.

final class SpriteGenerator {
    static let spriteSize = 32
    static let frameCount = 8

    // MARK: - Generate sprite frames for a kind
    static func generateFrames(for kind: NotificationKind) -> [NSImage] {
        var frames: [NSImage] = []
        for i in 0..<frameCount {
            frames.append(generateFrame(for: kind, frameIndex: i))
        }
        return frames
    }

    static func idleFrame(for kind: NotificationKind) -> NSImage {
        return generateFrame(for: kind, frameIndex: 0)
    }

    // MARK: - Core pixel drawing
    private static func generateFrame(for kind: NotificationKind, frameIndex: Int) -> NSImage {
        let size = CGFloat(spriteSize)
        let image = NSImage(size: NSSize(width: size, height: size))

        image.lockFocus()

        let ctx = NSGraphicsContext.current!.cgContext
        ctx.setAllowsAntialiasing(false)
        ctx.interpolationQuality = .none

        // Clear
        ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))

        switch kind {
        case .waiting:
            drawWaitingSprite(ctx: ctx, frame: frameIndex)
        case .success:
            drawSuccessSprite(ctx: ctx, frame: frameIndex)
        case .error:
            drawErrorSprite(ctx: ctx, frame: frameIndex)
        case .info:
            drawInfoSprite(ctx: ctx, frame: frameIndex)
        }

        image.unlockFocus()
        return image
    }

    // MARK: - Waiting sprite: hourglass / pulsing dots
    private static func drawWaitingSprite(ctx: CGContext, frame: Int) {
        let c = hexColor("#D4A574")
        let cDark = hexColor("#B8875A")
        let cLight = hexColor("#F0D4B0")

        // Body base - rounded rectangle shape
        fillRect(ctx, x: 10, y: 4, w: 12, h: 24, color: cDark)
        fillRect(ctx, x: 8, y: 6, w: 16, h: 20, color: c)

        // Top and bottom caps
        fillRect(ctx, x: 8, y: 4, w: 16, h: 3, color: cLight)
        fillRect(ctx, x: 8, y: 25, w: 16, h: 3, color: cLight)

        // Inner hourglass shape - sand animation
        let sandLevel = frame % 8
        // Top sand (decreasing)
        let topSand = max(0, 7 - sandLevel)
        for i in 0..<topSand {
            let inset = i / 2
            fillRect(ctx, x: 12 + inset, y: 8 + i, w: 8 - inset * 2, h: 1, color: cLight)
        }

        // Bottom sand (increasing)
        let botSand = min(7, sandLevel + 1)
        for i in 0..<botSand {
            let inset = (6 - i) / 2
            fillRect(ctx, x: 12 + inset, y: 23 - i, w: 8 - inset * 2, h: 1, color: cLight)
        }

        // Falling grain
        if sandLevel > 0 && sandLevel < 7 {
            let grainY = 10 + sandLevel + 2
            fillRect(ctx, x: 15, y: grainY, w: 2, h: 2, color: cLight)
        }

        // Eyes (on the hourglass body)
        fillRect(ctx, x: 11, y: 14, w: 2, h: 2, color: hexColor("#3A2E1A"))
        fillRect(ctx, x: 19, y: 14, w: 2, h: 2, color: hexColor("#3A2E1A"))

        // Tiny mouth
        let mouthFrame = frame % 4
        if mouthFrame < 2 {
            fillRect(ctx, x: 14, y: 18, w: 4, h: 1, color: hexColor("#3A2E1A"))
        } else {
            fillRect(ctx, x: 14, y: 17, w: 4, h: 2, color: hexColor("#3A2E1A"))
            fillRect(ctx, x: 15, y: 18, w: 2, h: 1, color: cDark)
        }
    }

    // MARK: - Success sprite: checkmark character
    private static func drawSuccessSprite(ctx: CGContext, frame: Int) {
        let c = hexColor("#7EC897")
        let cDark = hexColor("#5CAA78")
        let cLight = hexColor("#B0E8C0")

        // Circular body
        fillCirclePixel(ctx, cx: 16, cy: 16, r: 12, color: c)
        fillCirclePixel(ctx, cx: 16, cy: 16, r: 10, color: cLight.withAlphaComponent(0.3))

        // Eyes - happy (arched)
        fillRect(ctx, x: 10, y: 12, w: 3, h: 2, color: hexColor("#2A5A3A"))
        fillRect(ctx, x: 19, y: 12, w: 3, h: 2, color: hexColor("#2A5A3A"))

        // Smile
        fillRect(ctx, x: 11, y: 18, w: 10, h: 1, color: hexColor("#2A5A3A"))
        fillRect(ctx, x: 10, y: 17, w: 2, h: 1, color: hexColor("#2A5A3A"))
        fillRect(ctx, x: 20, y: 17, w: 2, h: 1, color: hexColor("#2A5A3A"))

        // Checkmark appears in animation
        let progress = min(frame, 6)
        let checkColor = hexColor("#FFFFFF")

        // Checkmark animation: short stroke then long stroke
        if progress >= 1 {
            fillRect(ctx, x: 7, y: 7, w: 2, h: 2, color: checkColor)
        }
        if progress >= 2 {
            fillRect(ctx, x: 6, y: 5, w: 2, h: 2, color: checkColor)
        }
        if progress >= 3 {
            fillRect(ctx, x: 5, y: 3, w: 2, h: 2, color: checkColor)
        }

        // Sparkle particles
        if frame >= 4 {
            let sparkleOffset = (frame - 4) * 2
            fillRect(ctx, x: 24 + sparkleOffset % 4, y: 4, w: 2, h: 2, color: cLight)
            fillRect(ctx, x: 4 - sparkleOffset % 3, y: 6, w: 1, h: 1, color: cLight)
            fillRect(ctx, x: 26, y: 10 - sparkleOffset % 3, w: 1, h: 1, color: cLight)
        }

        // Bounce effect
        if frame == 3 || frame == 4 {
            fillRect(ctx, x: 14, y: 26, w: 4, h: 2, color: cDark.withAlphaComponent(0.3))
        }
    }

    // MARK: - Error sprite: X character
    private static func drawErrorSprite(ctx: CGContext, frame: Int) {
        let c = hexColor("#E88B8B")
        let cDark = hexColor("#CC6666")
        let cLight = hexColor("#FFB0B0")

        // Circular body with slight shake
        let shakeX = (frame % 3 == 1) ? 1 : (frame % 3 == 2 ? -1 : 0)
        fillCirclePixel(ctx, cx: 16 + shakeX, cy: 16, r: 12, color: c)

        // Upset eyes (X shaped or >< )
        let eyeFrame = frame % 4
        if eyeFrame < 2 {
            // X eyes
            fillRect(ctx, x: 10 + shakeX, y: 11, w: 2, h: 2, color: hexColor("#5A2020"))
            fillRect(ctx, x: 12 + shakeX, y: 13, w: 2, h: 2, color: hexColor("#5A2020"))
            fillRect(ctx, x: 12 + shakeX, y: 11, w: 2, h: 2, color: hexColor("#5A2020"))
            fillRect(ctx, x: 10 + shakeX, y: 13, w: 2, h: 2, color: hexColor("#5A2020"))

            fillRect(ctx, x: 20 + shakeX, y: 11, w: 2, h: 2, color: hexColor("#5A2020"))
            fillRect(ctx, x: 22 + shakeX, y: 13, w: 2, h: 2, color: hexColor("#5A2020"))
            fillRect(ctx, x: 22 + shakeX, y: 11, w: 2, h: 2, color: hexColor("#5A2020"))
            fillRect(ctx, x: 20 + shakeX, y: 13, w: 2, h: 2, color: hexColor("#5A2020"))
        } else {
            // Worried dot eyes
            fillRect(ctx, x: 11 + shakeX, y: 12, w: 3, h: 3, color: hexColor("#5A2020"))
            fillRect(ctx, x: 20 + shakeX, y: 12, w: 3, h: 3, color: hexColor("#5A2020"))
        }

        // Frown
        fillRect(ctx, x: 12 + shakeX, y: 20, w: 8, h: 1, color: hexColor("#5A2020"))
        fillRect(ctx, x: 11 + shakeX, y: 21, w: 2, h: 1, color: hexColor("#5A2020"))
        fillRect(ctx, x: 19 + shakeX, y: 21, w: 2, h: 1, color: hexColor("#5A2020"))

        // Exclamation mark above
        if frame % 2 == 0 {
            fillRect(ctx, x: 15, y: 0, w: 2, h: 4, color: cLight)
            fillRect(ctx, x: 15, y: 5, w: 2, h: 2, color: cLight)
        }

        // Sweat drop
        if frame >= 3 {
            let dropY = 8 + (frame - 3)
            fillRect(ctx, x: 25 + shakeX, y: dropY, w: 2, h: 3, color: hexColor("#88CCEE"))
        }
    }

    // MARK: - Info sprite: glowing "i"
    private static func drawInfoSprite(ctx: CGContext, frame: Int) {
        let c = hexColor("#8BB8E8")
        let cDark = hexColor("#6A98CC")
        let cLight = hexColor("#B0D8FF")

        // Rounded square body
        fillRect(ctx, x: 6, y: 6, w: 20, h: 20, color: c)
        fillRect(ctx, x: 8, y: 4, w: 16, h: 24, color: c)
        fillRect(ctx, x: 4, y: 8, w: 24, h: 16, color: c)

        // Subtle face
        fillRect(ctx, x: 10, y: 12, w: 3, h: 2, color: hexColor("#2A4A6A"))
        fillRect(ctx, x: 19, y: 12, w: 3, h: 2, color: hexColor("#2A4A6A"))

        // Neutral/thinking mouth
        let mouthFrame = frame % 6
        if mouthFrame < 3 {
            fillRect(ctx, x: 13, y: 18, w: 6, h: 1, color: hexColor("#2A4A6A"))
        } else {
            fillRect(ctx, x: 13, y: 18, w: 6, h: 1, color: hexColor("#2A4A6A"))
            fillRect(ctx, x: 14, y: 19, w: 4, h: 1, color: hexColor("#2A4A6A"))
        }

        // Info "i" symbol floating above
        let floatY = (frame % 4 < 2) ? 0 : 1
        fillRect(ctx, x: 15, y: 1 - floatY, w: 2, h: 2, color: cLight)
        fillRect(ctx, x: 14, y: 4 - floatY, w: 4, h: 1, color: cLight)
        fillRect(ctx, x: 15, y: 5 - floatY, w: 2, h: 5, color: cLight)
        fillRect(ctx, x: 14, y: 10 - floatY, w: 4, h: 1, color: cLight)

        // Glow pulses
        let glowAlpha = 0.15 + 0.1 * sin(Double(frame) * 0.8)
        if glowAlpha > 0.15 {
            fillRect(ctx, x: 3, y: 7, w: 26, h: 18, color: cLight.withAlphaComponent(CGFloat(glowAlpha)))
        }
    }

    // MARK: - Helpers
    private static func fillRect(_ ctx: CGContext, x: Int, y: Int, w: Int, h: Int, color: NSColor) {
        ctx.setFillColor(color.cgColor)
        ctx.fill(CGRect(x: x, y: 32 - y - h, width: w, height: h))
    }

    private static func fillCirclePixel(_ ctx: CGContext, cx: Int, cy: Int, r: Int, color: NSColor) {
        ctx.setFillColor(color.cgColor)
        for dy in -r...r {
            for dx in -r...r {
                if dx * dx + dy * dy <= r * r {
                    ctx.fill(CGRect(x: cx + dx, y: 32 - (cy + dy) - 1, width: 1, height: 1))
                }
            }
        }
    }

    private static func hexColor(_ hex: String) -> NSColor {
        var hexStr = hex
        if hexStr.hasPrefix("#") { hexStr.removeFirst() }
        guard hexStr.count == 6, let val = UInt64(hexStr, radix: 16) else {
            return .white
        }
        let r = CGFloat((val >> 16) & 0xFF) / 255.0
        let g = CGFloat((val >> 8) & 0xFF) / 255.0
        let b = CGFloat(val & 0xFF) / 255.0
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
