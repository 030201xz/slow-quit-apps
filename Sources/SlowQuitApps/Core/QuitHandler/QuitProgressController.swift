import Cocoa

/// 退出进度控制器
/// 核心逻辑：keyDown 开始计时，keyUp 停止计时，达到时间执行退出
@MainActor
final class QuitProgressController: KeyEventDelegate {
    static let shared = QuitProgressController()
    
    /// 进度更新定时器
    private var timer: Timer?
    
    /// 按下开始时间
    private var startTime: Date?
    
    /// 当前目标应用
    private var targetApp: NSRunningApplication?
    
    /// 是否正在计时
    private var isRunning = false
    
    /// 安全超时阈值（秒）- 防止定时器泄漏
    /// 如果超过 holdDuration + 此值没有收到 keyUp，强制停止
    private let safetyTimeout: TimeInterval = 1.0
    
    private let appState = AppState.shared
    private let overlayWindow = QuitOverlayWindow.shared
    
    private init() {}
    
    // MARK: - 公开方法
    
    func start() {
        KeyEventMonitor.shared.delegate = self
        KeyEventMonitor.shared.startMonitoring()
    }
    
    func stop() {
        KeyEventMonitor.shared.stopMonitoring()
        stopTimer()
    }
    
    // MARK: - KeyEventDelegate
    
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyDown event: KeyEvent) {
        // 已经在计时中，忽略重复的 keyDown（键盘重复）
        guard !isRunning else { return }
        
        guard appState.isEnabled else {
            // 禁用时直接退出
            NSWorkspace.shared.frontmostApplication?.terminate()
            return
        }
        
        guard let app = NSWorkspace.shared.frontmostApplication,
              let bundleId = app.bundleIdentifier else { return }
        
        // 调试：打印当前应用和排除状态
        let isExcluded = appState.isAppExcluded(bundleId)
        print("🔍 检测到 Cmd+Q: \(app.localizedName ?? "未知") [\(bundleId)] 排除状态: \(isExcluded)")
        print("📋 排除列表: \(appState.excludedApps.map { "\($0.bundleIdentifier):\($0.isExcluded)" })")
        
        // 白名单应用直接退出
        if isExcluded {
            print("⚡ 直接退出（已排除）")
            app.terminate()
            return
        }
        
        print("⏱️ 开始计时...")
        // 开始计时
        startTimer(for: app)
    }
    
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyUp event: KeyEvent) {
        // keyUp 立即停止
        stopTimer()
    }
    
    // MARK: - 计时器
    
    private func startTimer(for app: NSRunningApplication) {
        // 先清理可能遗留的定时器
        stopTimer()
        
        isRunning = true
        startTime = Date()
        targetApp = app
        
        let appName = app.localizedName ?? "未知应用"
        overlayWindow.show(appName: appName)
        appState.startQuitProgress(for: app.bundleIdentifier ?? "")
        
        // 60fps 更新进度
        let newTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
    }
    
    private func tick() {
        // 安全检查：如果状态不一致，立即停止
        guard isRunning,
              let start = startTime,
              let app = targetApp else {
            stopTimer()
            return
        }
        
        // 检查目标应用是否还在运行
        guard !app.isTerminated else {
            stopTimer()
            return
        }
        
        let elapsed = Date().timeIntervalSince(start)
        
        // 安全超时检查：防止定时器泄漏
        let maxDuration = appState.holdDuration + safetyTimeout
        if elapsed > maxDuration {
            print("⚠️ 安全超时，强制停止计时器")
            stopTimer()
            return
        }
        
        let progress = min(1.0, elapsed / appState.holdDuration)
        
        appState.updateQuitProgress(progress)
        overlayWindow.updateProgress(progress)
        
        if progress >= 1.0 {
            // 达到目标，执行退出
            let appToQuit = app
            stopTimer()
            appState.completeQuit()
            appToQuit.terminate()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        targetApp = nil
        isRunning = false
        
        appState.cancelQuitProgress()
        overlayWindow.hide()
    }
}
