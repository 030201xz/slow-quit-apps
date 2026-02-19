import Cocoa
import ApplicationServices

/// Accessibility permission manager
/// Checks and requests accessibility permission
@MainActor
final class AccessibilityManager {
    /// Shared instance
    static let shared = AccessibilityManager()

    private init() {}

    // MARK: - Permission

    /// Whether accessibility permission is granted
    var isAccessibilityEnabled: Bool {
        AXIsProcessTrusted()
    }

    /// Request accessibility permission
    /// Shows the system dialog prompting the user to grant access
    nonisolated func requestAccessibility() {
        // Use string literal to avoid concurrency safety issues
        // kAXTrustedCheckOptionPrompt value is "AXTrustedCheckOptionPrompt"
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    /// Open the Accessibility section in System Settings
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        guard let settingsUrl = url else { return }
        NSWorkspace.shared.open(settingsUrl)
    }

    /// Check permission and request it if not granted
    /// - Returns: current permission status
    @discardableResult
    func checkAndRequestIfNeeded() -> Bool {
        if isAccessibilityEnabled {
            return true
        }
        requestAccessibility()
        return false
    }
}
