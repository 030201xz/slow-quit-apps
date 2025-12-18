import Foundation

/// UserDefaults 键名定义
enum DefaultsKey: String {
    case isEnabled = "isEnabled"
    case holdDuration = "holdDuration"
    case showMenuBarIcon = "showMenuBarIcon"
    case launchAtLogin = "launchAtLogin"
    case showProgressAnimation = "showProgressAnimation"
    case excludedApps = "excludedApps"
}

/// UserDefaults 存储管理器
/// 提供类型安全的配置读写
@MainActor
final class Defaults {
    /// 单例实例
    static let shared = Defaults()
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {}
    
    // MARK: - 基础类型读写
    
    /// 读取布尔值
    func bool(for key: DefaultsKey, default defaultValue: Bool = false) -> Bool {
        guard defaults.object(forKey: key.rawValue) != nil else {
            return defaultValue
        }
        return defaults.bool(forKey: key.rawValue)
    }
    
    /// 写入布尔值
    func set(_ value: Bool, for key: DefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    /// 读取浮点数
    func double(for key: DefaultsKey, default defaultValue: Double = 0) -> Double {
        guard defaults.object(forKey: key.rawValue) != nil else {
            return defaultValue
        }
        return defaults.double(forKey: key.rawValue)
    }
    
    /// 写入浮点数
    func set(_ value: Double, for key: DefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    // MARK: - Codable 对象读写
    
    /// 读取可编码对象
    func object<T: Decodable>(for key: DefaultsKey, type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            return nil
        }
        return try? decoder.decode(type, from: data)
    }
    
    /// 写入可编码对象
    func set<T: Encodable>(_ value: T, for key: DefaultsKey) {
        guard let data = try? encoder.encode(value) else {
            return
        }
        defaults.set(data, forKey: key.rawValue)
    }
    
    // MARK: - 便捷方法
    
    /// 加载完整配置
    func loadConfig() -> AppConfig {
        AppConfig(
            isEnabled: bool(for: .isEnabled, default: true),
            holdDuration: double(for: .holdDuration, default: Constants.Progress.defaultHoldDuration),
            showMenuBarIcon: bool(for: .showMenuBarIcon, default: true),
            launchAtLogin: bool(for: .launchAtLogin, default: false),
            showProgressAnimation: bool(for: .showProgressAnimation, default: true)
        )
    }
    
    /// 保存完整配置
    func saveConfig(_ config: AppConfig) {
        set(config.isEnabled, for: .isEnabled)
        set(config.holdDuration, for: .holdDuration)
        set(config.showMenuBarIcon, for: .showMenuBarIcon)
        set(config.launchAtLogin, for: .launchAtLogin)
        set(config.showProgressAnimation, for: .showProgressAnimation)
    }
    
    /// 加载排除应用列表
    func loadExcludedApps() -> [ManagedApp] {
        object(for: .excludedApps, type: [ManagedApp].self) ?? ManagedApp.systemDefaults
    }
    
    /// 保存排除应用列表
    func saveExcludedApps(_ apps: [ManagedApp]) {
        set(apps, for: .excludedApps)
    }
}
