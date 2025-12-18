import SwiftUI

/// 全局应用状态（Zustand 理念）
/// 单一数据源，简洁直观的状态管理
@MainActor
@Observable
final class AppState {
    /// 单例实例
    static let shared = AppState()
    
    // MARK: - 状态属性
    
    /// 是否启用长按退出功能
    var isEnabled: Bool {
        didSet { Defaults.shared.set(isEnabled, for: .isEnabled) }
    }
    
    /// 长按持续时间（秒）
    var holdDuration: Double {
        didSet { Defaults.shared.set(holdDuration, for: .holdDuration) }
    }
    
    /// 是否显示菜单栏图标
    var showMenuBarIcon: Bool {
        didSet { Defaults.shared.set(showMenuBarIcon, for: .showMenuBarIcon) }
    }
    
    /// 是否开机自启
    var launchAtLogin: Bool {
        didSet { Defaults.shared.set(launchAtLogin, for: .launchAtLogin) }
    }
    
    /// 是否显示进度条动画
    var showProgressAnimation: Bool {
        didSet { Defaults.shared.set(showProgressAnimation, for: .showProgressAnimation) }
    }
    
    /// 排除应用列表（不需要长按即可退出）
    var excludedApps: [ManagedApp] {
        didSet { Defaults.shared.saveExcludedApps(excludedApps) }
    }
    
    /// 当前正在退出的进度（0.0 - 1.0）
    var quitProgress: Double = 0.0
    
    /// 是否正在显示退出进度
    var isShowingQuitProgress: Bool = false
    
    /// 当前目标应用的 Bundle ID
    var targetAppBundleId: String?
    
    // MARK: - 初始化
    
    private init() {
        // 从持久化存储加载状态
        let config = Defaults.shared.loadConfig()
        self.isEnabled = config.isEnabled
        self.holdDuration = config.holdDuration
        self.showMenuBarIcon = config.showMenuBarIcon
        self.launchAtLogin = config.launchAtLogin
        self.showProgressAnimation = config.showProgressAnimation
        self.excludedApps = Defaults.shared.loadExcludedApps()
    }
    
    // MARK: - Actions（动作方法）
    
    /// 切换启用状态
    func toggleEnabled() {
        isEnabled.toggle()
    }
    
    /// 设置长按持续时间
    func setHoldDuration(_ duration: Double) {
        // 确保在有效范围内
        holdDuration = max(
            Constants.Progress.minHoldDuration,
            min(duration, Constants.Progress.maxHoldDuration)
        )
    }
    
    /// 添加排除应用
    func addExcludedApp(_ app: ManagedApp) {
        guard !excludedApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) else {
            return
        }
        excludedApps.append(app)
    }
    
    /// 移除排除应用
    func removeExcludedApp(_ app: ManagedApp) {
        excludedApps.removeAll { $0.bundleIdentifier == app.bundleIdentifier }
    }
    
    /// 检查应用是否在排除列表中
    func isAppExcluded(_ bundleId: String) -> Bool {
        excludedApps.contains { $0.bundleIdentifier == bundleId && $0.isExcluded }
    }
    
    /// 开始退出进度
    func startQuitProgress(for bundleId: String) {
        targetAppBundleId = bundleId
        quitProgress = 0.0
        isShowingQuitProgress = true
    }
    
    /// 更新退出进度
    func updateQuitProgress(_ progress: Double) {
        quitProgress = min(1.0, max(0.0, progress))
    }
    
    /// 取消退出进度
    func cancelQuitProgress() {
        quitProgress = 0.0
        isShowingQuitProgress = false
        targetAppBundleId = nil
    }
    
    /// 完成退出
    func completeQuit() {
        quitProgress = 1.0
        isShowingQuitProgress = false
    }
    
    /// 重置为默认设置
    func resetToDefaults() {
        let config = AppConfig.default
        isEnabled = config.isEnabled
        holdDuration = config.holdDuration
        showMenuBarIcon = config.showMenuBarIcon
        launchAtLogin = config.launchAtLogin
        showProgressAnimation = config.showProgressAnimation
        excludedApps = ManagedApp.systemDefaults
    }
}
