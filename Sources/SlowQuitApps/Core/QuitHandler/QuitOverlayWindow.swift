import Cocoa
import SwiftUI

/// 退出进度覆盖窗口
/// 浮动在屏幕中央显示退出进度
@MainActor
final class QuitOverlayWindow {
    /// 单例实例
    static let shared = QuitOverlayWindow()
    
    /// 窗口实例
    private var window: NSPanel?
    
    /// 托管视图控制器
    private var hostingController: NSHostingController<QuitOverlayView>?
    
    /// 当前进度
    private var currentProgress: Double = 0
    
    /// 当前应用名称
    private var currentAppName: String = ""
    
    private init() {}
    
    // MARK: - 公开方法
    
    /// 显示进度窗口
    func show(appName: String) {
        currentAppName = appName
        currentProgress = 0
        
        // 创建或更新窗口
        if window == nil {
            createWindow()
        }
        
        updateView()
        
        guard let window = window else { return }
        
        // 定位到屏幕中央
        centerWindow(window)
        
        // 显示窗口
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
    }
    
    /// 更新进度
    func updateProgress(_ progress: Double) {
        currentProgress = progress
        updateView()
    }
    
    /// 隐藏窗口
    func hide() {
        window?.orderOut(nil)
        currentProgress = 0
    }
    
    // MARK: - 私有方法
    
    /// 创建窗口
    private func createWindow() {
        let panel = NSPanel(
            contentRect: NSRect(
                x: 0, y: 0,
                width: Constants.Window.overlayWidth,
                height: Constants.Window.overlayHeight + 40
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        // 配置窗口属性
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false
        
        // 创建 SwiftUI 视图
        let view = QuitOverlayView(
            progress: currentProgress,
            appName: currentAppName,
            animated: AppState.shared.showProgressAnimation
        )
        
        let hostingController = NSHostingController(rootView: view)
        panel.contentViewController = hostingController
        
        self.window = panel
        self.hostingController = hostingController
    }
    
    /// 更新视图
    private func updateView() {
        let view = QuitOverlayView(
            progress: currentProgress,
            appName: currentAppName,
            animated: AppState.shared.showProgressAnimation
        )
        hostingController?.rootView = view
    }
    
    /// 将窗口居中到屏幕
    private func centerWindow(_ window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowFrame = window.frame
        
        let x = screenFrame.midX - windowFrame.width / 2
        let y = screenFrame.midY - windowFrame.height / 2
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
