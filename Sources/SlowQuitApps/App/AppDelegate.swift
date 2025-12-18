import Cocoa
import SwiftUI

/// 应用代理
/// 管理应用生命周期和菜单栏图标
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// 状态栏图标
    private var statusItem: NSStatusItem?
    
    /// 设置窗口
    private var settingsWindow: NSWindow?
    
    /// 应用状态
    private let appState = AppState.shared
    
    // MARK: - 生命周期
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 检查无障碍权限
        if !AccessibilityManager.shared.checkAndRequestIfNeeded() {
            print("⚠️ 请先授予无障碍权限")
        }
        
        // 设置菜单栏图标
        setupStatusItem()
        
        // 启动键盘监听
        QuitProgressController.shared.start()
        
        // 隐藏 Dock 图标（作为菜单栏应用运行）
        NSApp.setActivationPolicy(.accessory)
        
        print("✅ \(Constants.App.name) 已启动")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        QuitProgressController.shared.stop()
        print("🛑 \(Constants.App.name) 已退出")
    }
    
    // MARK: - 菜单栏图标
    
    /// 设置状态栏图标
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else { return }
        
        // 设置图标
        button.image = NSImage(systemSymbolName: "hand.raised.fill", accessibilityDescription: "Slow Quit Apps")
        button.image?.size = NSSize(width: 18, height: 18)
        
        // 创建菜单
        let menu = NSMenu()
        
        // 启用/禁用
        let enableItem = NSMenuItem(
            title: appState.isEnabled ? "禁用" : "启用",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        enableItem.target = self
        menu.addItem(enableItem)
        
        menu.addItem(.separator())
        
        // 设置
        let settingsItem = NSMenuItem(
            title: "设置...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(.separator())
        
        // 退出
        let quitItem = NSMenuItem(
            title: "退出 \(Constants.App.name)",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    // MARK: - 菜单动作
    
    /// 切换启用状态
    @objc private func toggleEnabled() {
        appState.toggleEnabled()
        // 更新菜单标题
        if let menu = statusItem?.menu,
           let enableItem = menu.items.first {
            enableItem.title = appState.isEnabled ? "禁用" : "启用"
        }
    }
    
    /// 打开设置窗口
    @objc private func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // 创建设置窗口
        let contentView = SettingsWindowView()
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "\(Constants.App.name) 设置"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(
            width: Constants.Window.settingsWidth,
            height: Constants.Window.settingsHeight
        ))
        window.center()
        
        // 窗口关闭时清理引用
        window.isReleasedWhenClosed = false
        
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// 退出应用
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
