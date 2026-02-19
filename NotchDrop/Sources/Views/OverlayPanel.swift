import AppKit

// MARK: - OverlayPanel
// A borderless, non-activating NSPanel that floats under the notch.

final class OverlayPanel: NSPanel {

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 64),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Panel configuration
        self.level = .statusBar
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false
        self.ignoresMouseEvents = false
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden

        // Position under notch
        positionUnderNotch()
    }

    // MARK: - Position under notch / menu bar
    func positionUnderNotch() {
        // Find the screen with the cursor (or main screen)
        let screen = screenWithCursor() ?? NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        let panelWidth: CGFloat = 420
        let panelHeight: CGFloat = 64
        let topOffset: CGFloat = 8  // px below notch/safe area

        // Safe area: the difference between frame top and visible frame top
        let menuBarHeight = screenFrame.maxY - visibleFrame.maxY
        let notchInset: CGFloat
        if #available(macOS 12.0, *) {
            notchInset = screen.safeAreaInsets.top
        } else {
            notchInset = menuBarHeight
        }

        // Use the larger of notch inset and menu bar height
        let effectiveTop = max(notchInset, menuBarHeight)

        // X: centered on screen
        let x = screenFrame.origin.x + (screenFrame.width - panelWidth) / 2

        // Y: macOS coordinates are bottom-up, so top of screen - effective top - offset - panel height
        let y = screenFrame.maxY - effectiveTop - topOffset - panelHeight

        self.setFrame(NSRect(x: x, y: y, width: panelWidth, height: panelHeight), display: true)
    }

    private func screenWithCursor() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { screen in
            screen.frame.contains(mouseLocation)
        }
    }

    // Allow clicks to pass through to action handler
    override var canBecomeKey: Bool { return false }
    override var canBecomeMain: Bool { return false }
}
