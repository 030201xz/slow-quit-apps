import SwiftUI

/// 全局应用状态
/// 单一数据源，使用 JSON 文件持久化
@MainActor
@Observable
final class AppState {
    static let shared = AppState()
    
    // MARK: - 配置属性
    
    /// 是否启用长按退出功能
    var isEnabled: Bool {
        didSet { saveConfig() }
    }
    
    /// 长按持续时间（秒）
    var holdDuration: Double {
        didSet { saveConfig() }
    }
    
    /// 是否开机自启
    var launchAtLogin: Bool {
        didSet { saveConfig() }
    }
    
    /// 是否显示进度条动画
    var showProgressAnimation: Bool {
        didSet { saveConfig() }
    }
    
    /// 排除应用列表（不需要长按即可退出）
    var excludedApps: [ManagedApp] {
        didSet { saveConfig() }
    }
    
    // MARK: - 运行时状态（不持久化）
    
    /// 当前正在退出的进度（0.0 - 1.0）
    var quitProgress: Double = 0.0
    
    /// 是否正在显示退出进度
    var isShowingQuitProgress: Bool = false
    
    /// 当前目标应用的 Bundle ID
    var targetAppBundleId: String?
    
    // MARK: - 初始化
    
    private init() {
        let config = ConfigManager.shared.load()
        self.isEnabled = config.isEnabled
        self.holdDuration = config.holdDuration
        self.launchAtLogin = config.launchAtLogin
        self.showProgressAnimation = config.showProgressAnimation
        self.excludedApps = config.excludedApps
    }
    
    // MARK: - 持久化
    
    private func saveConfig() {
        let config = Config(
            isEnabled: isEnabled,
            holdDuration: holdDuration,
            launchAtLogin: launchAtLogin,
            showProgressAnimation: showProgressAnimation,
            excludedApps: excludedApps
        )
        ConfigManager.shared.save(config)
    }
    
    // MARK: - Actions
    
    func toggleEnabled() {
        isEnabled.toggle()
    }
    
    func setHoldDuration(_ duration: Double) {
        holdDuration = max(
            Constants.Progress.minHoldDuration,
            min(duration, Constants.Progress.maxHoldDuration)
        )
    }
    
    func addExcludedApp(_ app: ManagedApp) {
        guard !excludedApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) else {
            print("⚠️ 应用已存在于列表中: \(app.bundleIdentifier)")
            return
        }
        excludedApps.append(app)
        print("✅ 已添加应用: \(app.name)")
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
        isEnabled = config.isEnabled
        holdDuration = config.holdDuration
        launchAtLogin = config.launchAtLogin
        showProgressAnimation = config.showProgressAnimation
        excludedApps = config.excludedApps
    }
    
    // MARK: - 导入/导出
    
    func exportConfig(to url: URL) throws {
        try ConfigManager.shared.exportConfig(to: url)
    }
    
    func importConfig(from url: URL) throws {
        let config = try ConfigManager.shared.importConfig(from: url)
        isEnabled = config.isEnabled
        holdDuration = config.holdDuration
        launchAtLogin = config.launchAtLogin
        showProgressAnimation = config.showProgressAnimation
        excludedApps = config.excludedApps
    }
}
