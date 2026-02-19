import AppKit
import SwiftUI

// MARK: - NotchDropApp
// Main entry point. LSUIElement app (no dock icon).
// Receives payloads via custom URL scheme: notchdrop://notify?b64=...

@main
struct NotchDropApp {
    static var panel: OverlayPanel!
    static var statusItem: NSStatusItem?

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // LSUIElement — no dock icon

        // Register URL scheme handler
        NSAppleEventManager.shared().setEventHandler(
            delegate,
            andSelector: #selector(AppDelegate.handleURL(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        app.run()
    }
}

// MARK: - AppDelegate
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the overlay panel
        let panel = OverlayPanel()
        NotchDropApp.panel = panel

        // Set SwiftUI content
        let hostingView = NSHostingView(rootView: ToastOverlayView())
        hostingView.frame = panel.contentView!.bounds
        hostingView.autoresizingMask = [.width, .height]
        panel.contentView?.addSubview(hostingView)

        // Make the panel's content view layer-backed and transparent
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.backgroundColor = .clear

        // Observe visibility changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NotchDropShow"),
            object: nil,
            queue: .main
        ) { [weak panel] _ in
            panel?.positionUnderNotch()
            panel?.orderFrontRegardless()
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NotchDropHide"),
            object: nil,
            queue: .main
        ) { [weak panel] _ in
            // Delay slightly to allow exit animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                panel?.orderOut(nil)
            }
        }

        // Wire up the notification manager visibility
        let manager = NotificationManager.shared
        var lastVisible = false
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let visible = manager.isVisible
            if visible != lastVisible {
                lastVisible = visible
                if visible {
                    NotificationCenter.default.post(name: NSNotification.Name("NotchDropShow"), object: nil)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name("NotchDropHide"), object: nil)
                }
            }
        }

        // Create a minimal status bar icon (optional but useful)
        setupStatusItem()

        // Show a startup notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationManager.shared.show(payload: NotificationPayload(
                title: "NotchDrop",
                message: "Gotowy do pracy! 🎮",
                kind: .info,
                duration: 2.5,
                sound: nil,
                action: nil
            ))
        }
    }

    private func setupStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bell.badge", accessibilityDescription: "NotchDrop")
            button.image?.size = NSSize(width: 16, height: 16)
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Test: Waiting", action: #selector(testWaiting), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Test: Success", action: #selector(testSuccess), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Test: Error", action: #selector(testError), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Test: Info", action: #selector(testInfo), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit NotchDrop", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.menu = menu
        NotchDropApp.statusItem = statusItem
    }

    // MARK: - URL handler
    @objc func handleURL(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else { return }

        // notchdrop://notify?b64=<base64url-encoded JSON>
        guard url.scheme == "notchdrop", url.host == "notify" else { return }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let b64Item = components.queryItems?.first(where: { $0.name == "b64" }),
           let b64 = b64Item.value {

            // Decode base64url
            var base64 = b64
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            // Pad if needed
            while base64.count % 4 != 0 { base64.append("=") }

            if let data = Data(base64Encoded: base64),
               let payload = try? JSONDecoder().decode(NotificationPayload.self, from: data) {
                DispatchQueue.main.async {
                    NotificationManager.shared.show(payload: payload)
                }
            } else {
                // Try plain JSON (percent-encoded)
                if let jsonStr = b64.removingPercentEncoding,
                   let data = jsonStr.data(using: .utf8),
                   let payload = try? JSONDecoder().decode(NotificationPayload.self, from: data) {
                    DispatchQueue.main.async {
                        NotificationManager.shared.show(payload: payload)
                    }
                }
            }
        }
    }

    // MARK: - Test actions
    @objc private func testWaiting() {
        NotificationManager.shared.show(payload: NotificationPayload(
            title: "Claude Code",
            message: "Claude czeka na Twoją decyzję",
            kind: .waiting,
            sound: "Glass"
        ))
    }

    @objc private func testSuccess() {
        NotificationManager.shared.show(payload: NotificationPayload(
            title: "Claude Code",
            message: "Zadanie zakończone pomyślnie ✓",
            kind: .success,
            sound: "Glass"
        ))
    }

    @objc private func testError() {
        NotificationManager.shared.show(payload: NotificationPayload(
            title: "Claude Code",
            message: "Wystąpił błąd podczas kompilacji",
            kind: .error,
            sound: "Basso"
        ))
    }

    @objc private func testInfo() {
        NotificationManager.shared.show(payload: NotificationPayload(
            title: "NotchDrop",
            message: "To jest informacja testowa",
            kind: .info
        ))
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
