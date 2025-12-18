import Cocoa
import ApplicationServices

/// 无障碍权限管理器
/// 负责检查和请求无障碍权限
@MainActor
final class AccessibilityManager {
    /// 单例实例
    static let shared = AccessibilityManager()
    
    private init() {}
    
    // MARK: - 权限检查
    
    /// 检查是否已获取无障碍权限
    var isAccessibilityEnabled: Bool {
        AXIsProcessTrusted()
    }
    
    /// 请求无障碍权限
    /// 会弹出系统对话框引导用户授权
    nonisolated func requestAccessibility() {
        // 使用字符串字面量避免并发安全问题
        // kAXTrustedCheckOptionPrompt 的值为 "AXTrustedCheckOptionPrompt"
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
    
    /// 打开系统偏好设置的无障碍页面
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        guard let settingsUrl = url else { return }
        NSWorkspace.shared.open(settingsUrl)
    }
    
    /// 检查权限并在需要时请求
    /// - Returns: 当前权限状态
    @discardableResult
    func checkAndRequestIfNeeded() -> Bool {
        if isAccessibilityEnabled {
            return true
        }
        requestAccessibility()
        return false
    }
}
