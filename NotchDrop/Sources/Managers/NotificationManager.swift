import AppKit
import Combine

// MARK: - NotificationManager
// Manages the lifecycle of toast notifications: show, queue, dismiss.

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var currentPayload: NotificationPayload?
    @Published var isVisible = false

    private var dismissTimer: Timer?
    private var queue: [NotificationPayload] = []
    private let maxQueueSize = 3

    private init() {}

    // MARK: - Show notification
    func show(payload: NotificationPayload) {
        // If message is empty, pick a random variant for this kind
        var effectivePayload = payload
        if payload.message.isEmpty {
            effectivePayload = NotificationPayload(
                title: payload.title,
                message: MessageVariants.random(for: payload.kind),
                kind: payload.kind,
                duration: payload.duration,
                sound: payload.sound,
                action: payload.action
            )
        }

        // Play sound
        if let soundName = effectivePayload.sound, soundName.lowercased() != "none" {
            playSound(named: soundName)
        }

        if isVisible {
            // Behavior A: update content + restart timer
            currentPayload = effectivePayload
            restartTimer(duration: effectivePayload.effectiveDuration)
        } else {
            currentPayload = effectivePayload
            isVisible = true
            restartTimer(duration: effectivePayload.effectiveDuration)
        }
    }

    // MARK: - Dismiss
    func dismiss() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        isVisible = false

        // After animation, check queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showNextFromQueue()
        }
    }

    // MARK: - Execute action
    func executeAction() {
        guard let payload = currentPayload, let action = payload.action else {
            dismiss()
            return
        }

        switch action.type {
        case "focus":
            if let bundleId = action.bundleId {
                focusApp(bundleId: bundleId)
            }
        case "open-url":
            if let urlStr = action.url, let url = URL(string: urlStr) {
                NSWorkspace.shared.open(url)
            }
        default:
            break
        }

        dismiss()
    }

    // MARK: - Private
    private func restartTimer(duration: Double) {
        dismissTimer?.invalidate()
        dismissTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.dismiss()
            }
        }
    }

    private func showNextFromQueue() {
        guard !queue.isEmpty else { return }
        let next = queue.removeFirst()
        show(payload: next)
    }

    private func playSound(named name: String) {
        if let sound = NSSound(named: NSSound.Name(name)) {
            sound.play()
        }
    }

    private func focusApp(bundleId: String) {
        // Try the exact bundle ID first
        if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
            app.activate(options: [.activateIgnoringOtherApps])
            return
        }
        // Fallback: try Terminal
        let fallbacks = ["com.apple.Terminal", "com.googlecode.iterm2"]
        for fb in fallbacks {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: fb).first {
                app.activate(options: [.activateIgnoringOtherApps])
                return
            }
        }
    }
}
