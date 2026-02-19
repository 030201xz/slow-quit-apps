import SwiftUI

/// Global app state
/// Single source of truth, persisted to JSON
@MainActor
@Observable
final class AppState {
    static let shared = AppState()

    // MARK: - Config Properties

    /// Whether long-press-to-quit (⌘Q) is enabled
    var quitOnLongPress: Bool {
        didSet { saveConfig() }
    }

    /// Hold duration (seconds)
    var holdDuration: Double {
        didSet { saveConfig() }
    }

    /// Whether to launch at login
    var launchAtLogin: Bool {
        didSet {
            // Call system API to update login item
            LaunchAtLoginManager.setEnabled(launchAtLogin)
            saveConfig()
        }
    }

    /// Whether to show the progress animation
    var showProgressAnimation: Bool {
        didSet { saveConfig() }
    }

    /// Whether long-press-to-close-window (⌘W) is enabled
    var closeWindowOnLongPress: Bool {
        didSet { saveConfig() }
    }

    /// Apps excluded from long-press interception
    var excludedApps: [ManagedApp] {
        didSet { saveConfig() }
    }

    /// Current language
    var language: Language {
        didSet {
            I18n.shared.setLanguage(language)
            saveConfig()
        }
    }

    // MARK: - Runtime State (not persisted)

    /// Current quit/close progress (0.0 – 1.0)
    var quitProgress: Double = 0.0

    /// Whether the progress overlay is visible
    var isShowingQuitProgress: Bool = false

    /// Bundle ID of the app being quit/closed
    var targetAppBundleId: String?

    // MARK: - Init

    private init() {
        let config = ConfigManager.shared.load()
        self.quitOnLongPress = config.quitOnLongPress
        self.holdDuration = config.holdDuration
        // Read from the system, not from the config file
        self.launchAtLogin = LaunchAtLoginManager.isEnabled
        self.showProgressAnimation = config.showProgressAnimation
        self.closeWindowOnLongPress = config.closeWindowOnLongPress
        self.excludedApps = config.excludedApps
        self.language = config.language

        // Sync language to I18n engine on init
        I18n.shared.setLanguage(config.language)
    }

    // MARK: - Persistence

    private func saveConfig() {
        let config = Config(
            quitOnLongPress: quitOnLongPress,
            holdDuration: holdDuration,
            launchAtLogin: launchAtLogin,
            showProgressAnimation: showProgressAnimation,
            closeWindowOnLongPress: closeWindowOnLongPress,
            excludedApps: excludedApps,
            language: language
        )
        ConfigManager.shared.save(config)
    }

    // MARK: - Actions

    func toggleQuitOnLongPress() {
        quitOnLongPress.toggle()
    }

    func setHoldDuration(_ duration: Double) {
        holdDuration = max(
            Constants.Progress.minHoldDuration,
            min(duration, Constants.Progress.maxHoldDuration)
        )
    }

    func addExcludedApp(_ app: ManagedApp) {
        guard !excludedApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) else {
            print("⚠️ App already in list: \(app.bundleIdentifier)")
            return
        }
        excludedApps.append(app)
        print("✅ Added app: \(app.name)")
    }

    func removeExcludedApp(_ app: ManagedApp) {
        excludedApps.removeAll { $0.bundleIdentifier == app.bundleIdentifier }
    }

    func isAppExcluded(_ bundleId: String) -> Bool {
        excludedApps.contains { $0.bundleIdentifier == bundleId && $0.isExcluded }
    }

    func startQuitProgress(for bundleId: String) {
        targetAppBundleId = bundleId
        quitProgress = 0.0
        isShowingQuitProgress = true
    }

    func updateQuitProgress(_ progress: Double) {
        quitProgress = min(1.0, max(0.0, progress))
    }

    func cancelQuitProgress() {
        quitProgress = 0.0
        isShowingQuitProgress = false
        targetAppBundleId = nil
    }

    func completeQuit() {
        quitProgress = 1.0
        isShowingQuitProgress = false
    }

    func resetToDefaults() {
        let config = ConfigManager.shared.reset()
        quitOnLongPress = config.quitOnLongPress
        holdDuration = config.holdDuration
        launchAtLogin = config.launchAtLogin
        showProgressAnimation = config.showProgressAnimation
        closeWindowOnLongPress = config.closeWindowOnLongPress
        excludedApps = config.excludedApps
        language = config.language
    }

    // MARK: - Import / Export

    func exportConfig(to url: URL) throws {
        try ConfigManager.shared.exportConfig(to: url)
    }

    func importConfig(from url: URL) throws {
        let config = try ConfigManager.shared.importConfig(from: url)
        quitOnLongPress = config.quitOnLongPress
        holdDuration = config.holdDuration
        launchAtLogin = config.launchAtLogin
        showProgressAnimation = config.showProgressAnimation
        closeWindowOnLongPress = config.closeWindowOnLongPress
        excludedApps = config.excludedApps
        language = config.language
    }
}
