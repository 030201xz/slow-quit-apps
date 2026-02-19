import Foundation

/// Legacy app config model used by Defaults.swift (UserDefaults-based storage)
struct AppConfig: Codable, Sendable {
    /// Whether long-press-to-quit (⌘Q) is enabled
    var quitOnLongPress: Bool

    /// Hold duration (seconds)
    var holdDuration: Double

    /// Whether to show the menu bar icon
    var showMenuBarIcon: Bool

    /// Whether to launch at login
    var launchAtLogin: Bool

    /// Whether to show the progress animation
    var showProgressAnimation: Bool

    /// Default config
    static let `default` = AppConfig(
        quitOnLongPress: true,
        holdDuration: 1.0,
        showMenuBarIcon: true,
        launchAtLogin: false,
        showProgressAnimation: true
    )
}
