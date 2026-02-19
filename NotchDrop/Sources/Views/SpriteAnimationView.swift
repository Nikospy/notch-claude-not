import SwiftUI
import AppKit

// MARK: - SpriteAnimationView
// Displays pixel-art sprite animation with nearest-neighbor rendering.

struct SpriteAnimationView: NSViewRepresentable {
    let kind: NotificationKind
    let isAnimating: Bool

    func makeNSView(context: Context) -> SpriteNSView {
        let view = SpriteNSView()
        view.setKind(kind, animate: isAnimating)
        return view
    }

    func updateNSView(_ nsView: SpriteNSView, context: Context) {
        nsView.setKind(kind, animate: isAnimating)
    }
}

final class SpriteNSView: NSView {
    private let imageLayer = CALayer()
    private var frames: [NSImage] = []
    private var currentFrame = 0
    private var animTimer: Timer?
    private var currentKind: NotificationKind?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    private func setupLayer() {
        wantsLayer = true
        layer?.addSublayer(imageLayer)
        imageLayer.magnificationFilter = .nearest
        imageLayer.minificationFilter = .nearest
        imageLayer.contentsGravity = .resizeAspect
    }

    override func layout() {
        super.layout()
        imageLayer.frame = bounds
    }

    func setKind(_ kind: NotificationKind, animate: Bool) {
        let isCurrentlyAnimating = (animTimer != nil)
        if currentKind == kind && isCurrentlyAnimating == animate { return }
        currentKind = kind
        frames = SpriteGenerator.generateFrames(for: kind)
        currentFrame = 0

        if !frames.isEmpty {
            imageLayer.contents = frames[0]
        }

        animTimer?.invalidate()
        animTimer = nil

        if animate && frames.count > 1 {
            animTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentFrame = (self.currentFrame + 1) % self.frames.count
                DispatchQueue.main.async {
                    self.imageLayer.contents = self.frames[self.currentFrame]
                }
            }
        }
    }

    deinit {
        animTimer?.invalidate()
    }
}
