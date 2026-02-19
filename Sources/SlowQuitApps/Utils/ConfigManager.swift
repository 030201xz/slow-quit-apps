import Foundation

/// Full app configuration model
struct Config: Codable, Sendable {
    var quitOnLongPress: Bool = true
    var holdDuration: Double = 1.0
    var launchAtLogin: Bool = false
    var showProgressAnimation: Bool = true
    var closeWindowOnLongPress: Bool = true
    var excludedApps: [ManagedApp] = ManagedApp.systemDefaults
    var language: Language = .en

    static let `default` = Config()

    // Custom decoder to support older config files missing fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quitOnLongPress = try container.decodeIfPresent(Bool.self, forKey: .quitOnLongPress) ?? true
        holdDuration = try container.decodeIfPresent(Double.self, forKey: .holdDuration) ?? 1.0
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        showProgressAnimation = try container.decodeIfPresent(Bool.self, forKey: .showProgressAnimation) ?? true
        closeWindowOnLongPress = try container.decodeIfPresent(Bool.self, forKey: .closeWindowOnLongPress) ?? true
        excludedApps = try container.decodeIfPresent([ManagedApp].self, forKey: .excludedApps) ?? ManagedApp.systemDefaults
        language = try container.decodeIfPresent(Language.self, forKey: .language) ?? .en
    }

    init(
        quitOnLongPress: Bool = true,
        holdDuration: Double = 1.0,
        launchAtLogin: Bool = false,
        showProgressAnimation: Bool = true,
        closeWindowOnLongPress: Bool = true,
        excludedApps: [ManagedApp] = ManagedApp.systemDefaults,
        language: Language = .en
    ) {
        self.quitOnLongPress = quitOnLongPress
        self.holdDuration = holdDuration
        self.launchAtLogin = launchAtLogin
        self.showProgressAnimation = showProgressAnimation
        self.closeWindowOnLongPress = closeWindowOnLongPress
        self.excludedApps = excludedApps
        self.language = language
    }
}

/// JSON config file manager
final class ConfigManager: Sendable {
    static let shared = ConfigManager()

    /// Path to the config file
    private let configURL: URL

    private init() {
        // Config file stored at ~/Library/Application Support/SlowQuitApps/config.json
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("SlowQuitApps", isDirectory: true)

        // Ensure the directory exists
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        configURL = appFolder.appendingPathComponent("config.json")
    }

    // MARK: - Load / Save

    func load() -> Config {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            return .default
        }

        do {
            let data = try Data(contentsOf: configURL)
            return try JSONDecoder().decode(Config.self, from: data)
        } catch {
            print("⚠️ Failed to load config: \(error)")
            return .default
        }
    }

    func save(_ config: Config) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(config)
            try data.write(to: configURL, options: .atomic)
        } catch {
            print("❌ Failed to save config: \(error)")
        }
    }

    // MARK: - Import / Export

    func exportConfig(to url: URL) throws {
        let config = load()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        try data.write(to: url, options: .atomic)
    }

    func importConfig(from url: URL) throws -> Config {
        let data = try Data(contentsOf: url)
        let config = try JSONDecoder().decode(Config.self, from: data)
        save(config)
        return config
    }

    func getConfigURL() -> URL {
        configURL
    }

    func reset() -> Config {
        let config = Config.default
        save(config)
        return config
    }
}
