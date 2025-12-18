import Foundation

/// 应用配置模型
/// 存储用户的所有偏好设置
struct AppConfig: Codable, Sendable {
    /// 是否启用长按退出功能
    var isEnabled: Bool
    
    /// 长按持续时间（秒）
    var holdDuration: Double
    
    /// 是否在菜单栏显示图标
    var showMenuBarIcon: Bool
    
    /// 是否开机自启动
    var launchAtLogin: Bool
    
    /// 是否显示进度条动画
    var showProgressAnimation: Bool
    
    /// 默认配置
    static let `default` = AppConfig(
        isEnabled: true,
        holdDuration: 1.0,
        showMenuBarIcon: true,
        launchAtLogin: false,
        showProgressAnimation: true
    )
}
