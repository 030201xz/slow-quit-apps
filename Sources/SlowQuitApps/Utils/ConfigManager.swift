import Foundation

/// 完整配置模型
struct Config: Codable, Sendable {
    var isEnabled: Bool = true
    var holdDuration: Double = 1.0
    var launchAtLogin: Bool = false
    var showProgressAnimation: Bool = true
    var excludedApps: [ManagedApp] = ManagedApp.systemDefaults
    
    static let `default` = Config()
}

/// JSON 配置文件管理器
final class ConfigManager: Sendable {
    static let shared = ConfigManager()
    
    /// 配置文件路径
    private let configURL: URL
    
    private init() {
        // 配置文件保存在 ~/Library/Application Support/SlowQuitApps/config.json
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("SlowQuitApps", isDirectory: true)
        
        // 确保目录存在
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        
        configURL = appFolder.appendingPathComponent("config.json")
    }
    
    // MARK: - 加载/保存
    
    func load() -> Config {
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            return .default
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            return try JSONDecoder().decode(Config.self, from: data)
        } catch {
            print("⚠️ 加载配置失败: \(error)")
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
            print("❌ 保存配置失败: \(error)")
        }
    }
    
    // MARK: - 导入/导出
    
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
