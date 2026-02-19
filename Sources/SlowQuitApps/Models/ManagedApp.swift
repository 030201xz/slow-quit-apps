import Foundation

/// Managed app model
/// Represents an app in the excluded list
struct ManagedApp: Codable, Identifiable, Hashable, Sendable {
    /// Bundle identifier
    let bundleIdentifier: String

    /// Display name
    let name: String

    /// Icon path (optional)
    let iconPath: String?

    /// Whether the app is excluded from long-press interception
    var isExcluded: Bool

    // MARK: - Identifiable

    var id: String { bundleIdentifier }

    // MARK: - Init

    /// Create from a running application
    init(bundleIdentifier: String, name: String, iconPath: String? = nil, isExcluded: Bool = true) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.iconPath = iconPath
        self.isExcluded = isExcluded
    }
}

// MARK: - Presets

extension ManagedApp {
    /// Default excluded apps
    static let systemDefaults: [ManagedApp] = [
        ManagedApp(bundleIdentifier: "com.apple.finder", name: "Finder"),
        ManagedApp(bundleIdentifier: "com.apple.Terminal", name: "Terminal"),
    ]
}
