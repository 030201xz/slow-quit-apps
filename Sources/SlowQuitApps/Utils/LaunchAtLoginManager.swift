import ServiceManagement

/// 开机自启管理器
/// 使用 SMAppService (macOS 13+) 管理登录项
/// 注意：仅在签名的 .app 包中有效，swift run 开发模式下无效
enum LaunchAtLoginManager {
    
    /// 是否在有效的应用包环境中运行
    private static var isValidAppBundle: Bool {
        Bundle.main.bundleIdentifier != nil && Bundle.main.bundleURL.pathExtension == "app"
    }
    
    /// 当前是否已设置开机启动
    static var isEnabled: Bool {
        guard isValidAppBundle else { return false }
        return SMAppService.mainApp.status == .enabled
    }
    
    /// 设置开机启动状态
    /// - Parameter enabled: 是否启用
    /// - Returns: 操作是否成功
    @discardableResult
    static func setEnabled(_ enabled: Bool) -> Bool {
        guard isValidAppBundle else {
            print("⚠️ 非应用包环境，跳过开机启动设置（开发模式）")
            return false
        }
        
        do {
            if enabled {
                // 注册开机启动
                if SMAppService.mainApp.status == .enabled {
                    print("✅ 已设置开机启动")
                    return true
                }
                try SMAppService.mainApp.register()
                print("✅ 开机启动已启用")
            } else {
                // 取消开机启动
                if SMAppService.mainApp.status != .enabled {
                    print("✅ 开机启动未启用")
                    return true
                }
                try SMAppService.mainApp.unregister()
                print("✅ 开机启动已禁用")
            }
            return true
        } catch {
            print("❌ 设置开机启动失败: \(error)")
            return false
        }
    }
    
    /// 获取当前状态描述
    static var statusDescription: String {
        guard isValidAppBundle else {
            return "开发模式（不可用）"
        }
        switch SMAppService.mainApp.status {
        case .notRegistered:
            return "未注册"
        case .enabled:
            return "已启用"
        case .requiresApproval:
            return "需要用户批准"
        case .notFound:
            return "应用未找到"
        @unknown default:
            return "未知状态"
        }
    }
}
