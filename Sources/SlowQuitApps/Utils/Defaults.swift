import Foundation

/// UserDefaults key definitions
enum DefaultsKey: String {
    case quitOnLongPress = "quitOnLongPress"
    case holdDuration = "holdDuration"
    case showMenuBarIcon = "showMenuBarIcon"
    case launchAtLogin = "launchAtLogin"
    case showProgressAnimation = "showProgressAnimation"
    case excludedApps = "excludedApps"
}

/// UserDefaults storage manager
/// Provides type-safe reads and writes
@MainActor
final class Defaults {
    /// Shared instance
    static let shared = Defaults()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    // MARK: - Primitives

    /// Read a boolean
    func bool(for key: DefaultsKey, default defaultValue: Bool = false) -> Bool {
        guard defaults.object(forKey: key.rawValue) != nil else {
            return defaultValue
        }
        return defaults.bool(forKey: key.rawValue)
    }

    /// Write a boolean
    func set(_ value: Bool, for key: DefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    /// Read a double
    func double(for key: DefaultsKey, default defaultValue: Double = 0) -> Double {
        guard defaults.object(forKey: key.rawValue) != nil else {
            return defaultValue
        }
        return defaults.double(forKey: key.rawValue)
    }

    /// Write a double
    func set(_ value: Double, for key: DefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }

    // MARK: - Codable

    /// Read a Decodable object
    func object<T: Decodable>(for key: DefaultsKey, type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            return nil
        }
        return try? decoder.decode(type, from: data)
    }

    /// Write an Encodable object
    func set<T: Encodable>(_ value: T, for key: DefaultsKey) {
        guard let data = try? encoder.encode(value) else {
            return
        }
        defaults.set(data, forKey: key.rawValue)
    }

    // MARK: - Convenience

    /// Load full config
    func loadConfig() -> AppConfig {
        AppConfig(
            quitOnLongPress: bool(for: .quitOnLongPress, default: true),
            holdDuration: double(for: .holdDuration, default: Constants.Progress.defaultHoldDuration),
            showMenuBarIcon: bool(for: .showMenuBarIcon, default: true),
            launchAtLogin: bool(for: .launchAtLogin, default: false),
            showProgressAnimation: bool(for: .showProgressAnimation, default: true)
        )
    }

    /// Save full config
    func saveConfig(_ config: AppConfig) {
        set(config.quitOnLongPress, for: .quitOnLongPress)
        set(config.holdDuration, for: .holdDuration)
        set(config.showMenuBarIcon, for: .showMenuBarIcon)
        set(config.launchAtLogin, for: .launchAtLogin)
        set(config.showProgressAnimation, for: .showProgressAnimation)
    }

    /// Load excluded apps
    func loadExcludedApps() -> [ManagedApp] {
        object(for: .excludedApps, type: [ManagedApp].self) ?? ManagedApp.systemDefaults
    }

    /// Save excluded apps
    func saveExcludedApps(_ apps: [ManagedApp]) {
        set(apps, for: .excludedApps)
    }
}
