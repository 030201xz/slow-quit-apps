import ServiceManagement

/// Launch-at-login manager
/// Uses SMAppService (macOS 13+) to manage login items
/// Note: only works inside a signed .app bundle, not in swift run
enum LaunchAtLoginManager {

    /// Whether running inside a valid .app bundle
    private static var isValidAppBundle: Bool {
        Bundle.main.bundleIdentifier != nil && Bundle.main.bundleURL.pathExtension == "app"
    }

    /// Whether launch-at-login is currently enabled
    static var isEnabled: Bool {
        guard isValidAppBundle else { return false }
        return SMAppService.mainApp.status == .enabled
    }

    /// Set the launch-at-login state
    /// - Parameter enabled: whether to enable
    /// - Returns: whether the operation succeeded
    @discardableResult
    static func setEnabled(_ enabled: Bool) -> Bool {
        guard isValidAppBundle else {
            print("⚠️ Not an app bundle — skipping launch-at-login (dev mode)")
            return false
        }

        do {
            if enabled {
                // Register login item
                if SMAppService.mainApp.status == .enabled {
                    print("✅ Launch-at-login already enabled")
                    return true
                }
                try SMAppService.mainApp.register()
                print("✅ Launch-at-login enabled")
            } else {
                // Unregister login item
                if SMAppService.mainApp.status != .enabled {
                    print("✅ Launch-at-login not enabled")
                    return true
                }
                try SMAppService.mainApp.unregister()
                print("✅ Launch-at-login disabled")
            }
            return true
        } catch {
            print("❌ Failed to set launch-at-login: \(error)")
            return false
        }
    }

    /// Human-readable status description
    static var statusDescription: String {
        guard isValidAppBundle else {
            return "Dev mode (unavailable)"
        }
        switch SMAppService.mainApp.status {
        case .notRegistered:
            return "Not registered"
        case .enabled:
            return "Enabled"
        case .requiresApproval:
            return "Requires approval"
        case .notFound:
            return "App not found"
        @unknown default:
            return "Unknown status"
        }
    }
}
