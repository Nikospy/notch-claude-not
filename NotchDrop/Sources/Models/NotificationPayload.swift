import Foundation

// MARK: - Notification Kind
enum NotificationKind: String, Codable, CaseIterable {
    case waiting
    case success
    case error
    case info

    var accentColorHex: String {
        switch self {
        case .waiting: return "#D4A574"  // warm amber
        case .success: return "#7EC897"  // soft green
        case .error:   return "#E88B8B"  // soft coral
        case .info:    return "#8BB8E8"  // soft blue
        }
    }

    var statusDotColorHex: String {
        return accentColorHex
    }

    var spritePrefix: String {
        switch self {
        case .waiting: return "waiting"
        case .success: return "success"
        case .error:   return "error"
        case .info:    return "info"
        }
    }
}

// MARK: - Action
struct NotificationAction: Codable {
    let type: String           // "focus", "open-url", "none"
    let bundleId: String?
    let url: String?

    init(type: String = "none", bundleId: String? = nil, url: String? = nil) {
        self.type = type
        self.bundleId = bundleId
        self.url = url
    }
}

// MARK: - Payload
struct NotificationPayload: Codable {
    let title: String
    let message: String
    let kind: NotificationKind
    let duration: Double?
    let sound: String?
    let action: NotificationAction?

    var effectiveDuration: Double {
        return duration ?? 2.8
    }

    init(
        title: String = "NotchDrop",
        message: String = "",
        kind: NotificationKind = .info,
        duration: Double? = nil,
        sound: String? = nil,
        action: NotificationAction? = nil
    ) {
        self.title = title
        self.message = message
        self.kind = kind
        self.duration = duration
        self.sound = sound
        self.action = action
    }
}
