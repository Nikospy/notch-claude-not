import Foundation

// MARK: - NotchDrop CLI
// Usage: notchdrop notify [options]
// Sends a notification payload to NotchDrop.app via custom URL scheme.

struct NotchDropCLI {
    static func main() {
        let args = CommandLine.arguments

        guard args.count >= 2 else {
            printUsage()
            exit(1)
        }

        let command = args[1]

        switch command {
        case "notify":
            handleNotify(Array(args.dropFirst(2)))
        case "help", "--help", "-h":
            printUsage()
        case "version", "--version":
            print("notchdrop 1.0.0")
        default:
            print("Unknown command: \(command)")
            printUsage()
            exit(1)
        }
    }

    static func handleNotify(_ args: [String]) {
        var title = "NotchDrop"
        var message = ""
        var kind = "info"
        var duration: Double? = nil
        var sound: String? = nil
        var actionType = "none"
        var bundleId: String? = nil
        var url: String? = nil

        var i = 0
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--title", "-t":
                i += 1
                if i < args.count { title = args[i] }
            case "--message", "-m":
                i += 1
                if i < args.count { message = args[i] }
            case "--kind", "-k":
                i += 1
                if i < args.count { kind = args[i] }
            case "--duration", "-d":
                i += 1
                if i < args.count { duration = Double(args[i]) }
            case "--sound", "-s":
                i += 1
                if i < args.count { sound = args[i] }
            case "--action", "-a":
                i += 1
                if i < args.count { actionType = args[i] }
            case "--app-bundle-id", "--bundle-id", "-b":
                i += 1
                if i < args.count { bundleId = args[i] }
            case "--url", "-u":
                i += 1
                if i < args.count { url = args[i] }
            default:
                print("Unknown option: \(arg)")
            }
            i += 1
        }

        // Build payload
        var payload: [String: Any] = [
            "title": title,
            "message": message,
            "kind": kind,
        ]

        if let d = duration { payload["duration"] = d }
        if let s = sound { payload["sound"] = s }

        var action: [String: Any] = ["type": actionType]
        if let bid = bundleId { action["bundleId"] = bid }
        if let u = url { action["url"] = u }
        if actionType != "none" {
            payload["action"] = action
        }

        // Serialize to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            print("Error: failed to serialize payload")
            exit(1)
        }

        // Base64url encode
        let base64 = jsonData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        // Build URL
        let urlScheme = "notchdrop://notify?b64=\(base64)"

        // Open via `open -g` (silent, no focus)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-g", urlScheme]

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                print("Warning: open command exited with status \(process.terminationStatus)")
                print("Make sure NotchDrop.app is running and registered for the notchdrop:// URL scheme.")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            print("Make sure NotchDrop.app is running.")
            exit(1)
        }
    }

    static func printUsage() {
        let usage = """
        NotchDrop CLI v1.0.0

        USAGE:
            notchdrop notify [options]

        OPTIONS:
            --title, -t        Notification title (default: "NotchDrop")
            --message, -m      Notification message (if omitted, a random fun variant is picked!)
            --kind, -k         Kind: waiting|success|error|info (default: info)
            --duration, -d     Display duration in seconds (default: 2.8)
            --sound, -s        System sound name: Glass|Submarine|Basso|... (default: none)
            --action, -a       Action on click: focus|open-url|none (default: none)
            --app-bundle-id, -b  Bundle ID for focus action
            --url, -u          URL for open-url action

        EXAMPLES:
            # Random message variant (fun mode!):
            notchdrop notify --title "Claude Code" --kind waiting --sound Glass --action focus

            # Explicit message:
            notchdrop notify -t "Error" -m "Kompilacja nie powiodła się" -k error -s Basso

        HOOK INTEGRATION:
            {
              "type": "command",
              "command": "notchdrop notify --title \\"Claude Code\\" --message \\"Claude czeka\\" --kind waiting --sound Glass --action focus"
            }
        """
        print(usage)
    }
}

NotchDropCLI.main()
