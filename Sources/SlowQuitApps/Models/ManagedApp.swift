import Foundation

/// 受管理的应用模型
/// 表示被排除（白名单）或特别处理的应用
struct ManagedApp: Codable, Identifiable, Hashable, Sendable {
    /// 应用的 Bundle Identifier
    let bundleIdentifier: String
    
    /// 应用显示名称
    let name: String
    
    /// 应用图标路径（可选）
    let iconPath: String?
    
    /// 是否排除（不需要长按即可退出）
    var isExcluded: Bool
    
    // MARK: - Identifiable
    
    var id: String { bundleIdentifier }
    
    // MARK: - 便捷初始化
    
    /// 从运行中的应用创建
    init(bundleIdentifier: String, name: String, iconPath: String? = nil, isExcluded: Bool = true) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.iconPath = iconPath
        self.isExcluded = isExcluded
    }
}

// MARK: - 常用应用预设

extension ManagedApp {
    /// 系统默认排除的应用列表
    static let systemDefaults: [ManagedApp] = [
        ManagedApp(bundleIdentifier: "com.apple.finder", name: "Finder"),
        ManagedApp(bundleIdentifier: "com.apple.Terminal", name: "终端"),
    ]
}
