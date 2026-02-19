import SwiftUI
import AppKit

// MARK: - Toast Content View
// The pill-shaped overlay with blur background, pixel-art sprite, and text.

struct ToastContentView: View {
    let payload: NotificationPayload
    let isAnimating: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Pixel-art sprite
            SpriteAnimationView(kind: payload.kind, isAnimating: isAnimating)
                .frame(width: 36, height: 36)

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(payload.title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(payload.message)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
            }

            Spacer(minLength: 4)

            // Status dot
            Circle()
                .fill(accentColor)
                .frame(width: 8, height: 8)
                .opacity(isAnimating ? 1.0 : 0.5)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 420, height: 64)
        .background(
            ZStack {
                // Blur background
                VisualEffectBlur()

                // Accent tint
                RoundedRectangle(cornerRadius: 20)
                    .fill(accentColor.opacity(0.08))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private var accentColor: Color {
        Color(nsColor: hexNSColor(payload.kind.accentColorHex))
    }

    private func hexNSColor(_ hex: String) -> NSColor {
        var h = hex
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return .white }
        return NSColor(
            red: CGFloat((val >> 16) & 0xFF) / 255.0,
            green: CGFloat((val >> 8) & 0xFF) / 255.0,
            blue: CGFloat(val & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - NSVisualEffectView wrapper
struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        view.wantsLayer = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
