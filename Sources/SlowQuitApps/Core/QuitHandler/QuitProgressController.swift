import Cocoa
import Combine

/// 退出进度控制器
/// 负责协调键盘事件监听和退出进度显示
@MainActor
final class QuitProgressController: KeyEventDelegate {
    /// 单例实例
    static let shared = QuitProgressController()
    
    /// 进度更新定时器
    private var progressTimer: Timer?
    
    /// 按键开始时间
    private var keyDownStartTime: Date?
    
    /// 应用状态
    private let appState = AppState.shared
    
    /// 覆盖窗口
    private let overlayWindow = QuitOverlayWindow.shared
    
    private init() {}
    
    // MARK: - 公开方法
    
    /// 启动控制器
    func start() {
        KeyEventMonitor.shared.delegate = self
        KeyEventMonitor.shared.startMonitoring()
    }
    
    /// 停止控制器
    func stop() {
        KeyEventMonitor.shared.stopMonitoring()
        cancelProgress()
    }
    
    // MARK: - KeyEventDelegate
    
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyDown event: KeyEvent) {
        handleKeyDown(event)
    }
    
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyUp event: KeyEvent) {
        handleKeyUp(event)
    }
    
    // MARK: - 私有方法
    
    /// 处理按键按下
    private func handleKeyDown(_ event: KeyEvent) {
        guard appState.isEnabled else {
            // 功能禁用时，直接退出前台应用
            quitFrontmostApp()
            return
        }
        
        // 获取前台应用
        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              let bundleId = frontApp.bundleIdentifier else {
            return
        }
        
        // 检查是否在排除列表中
        if appState.isAppExcluded(bundleId) {
            quitApp(frontApp)
            return
        }
        
        // 开始进度计时
        startProgress(for: frontApp)
    }
    
    /// 处理按键释放
    private func handleKeyUp(_ event: KeyEvent) {
        cancelProgress()
    }
    
    /// 开始进度计时
    private func startProgress(for app: NSRunningApplication) {
        let appName = app.localizedName ?? "未知应用"
        let bundleId = app.bundleIdentifier ?? ""
        
        keyDownStartTime = Date()
        appState.startQuitProgress(for: bundleId)
        
        // 显示覆盖窗口
        overlayWindow.show(appName: appName)
        
        // 创建进度更新定时器
        progressTimer = Timer.scheduledTimer(withTimeInterval: Constants.Progress.updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress(for: app)
            }
        }
    }
    
    /// 更新进度
    private func updateProgress(for app: NSRunningApplication) {
        guard let startTime = keyDownStartTime else {
            cancelProgress()
            return
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let progress = elapsed / appState.holdDuration
        
        appState.updateQuitProgress(progress)
        overlayWindow.updateProgress(progress)
        
        // 达到目标时间，执行退出
        if progress >= 1.0 {
            completeQuit(for: app)
        }
    }
    
    /// 取消进度
    private func cancelProgress() {
        progressTimer?.invalidate()
        progressTimer = nil
        keyDownStartTime = nil
        
        appState.cancelQuitProgress()
        overlayWindow.hide()
    }
    
    /// 完成退出
    private func completeQuit(for app: NSRunningApplication) {
        progressTimer?.invalidate()
        progressTimer = nil
        keyDownStartTime = nil
        
        appState.completeQuit()
        overlayWindow.hide()
        
        quitApp(app)
    }
    
    /// 退出指定应用
    private func quitApp(_ app: NSRunningApplication) {
        app.terminate()
    }
    
    /// 退出前台应用
    private func quitFrontmostApp() {
        guard let app = NSWorkspace.shared.frontmostApplication else { return }
        quitApp(app)
    }
}
