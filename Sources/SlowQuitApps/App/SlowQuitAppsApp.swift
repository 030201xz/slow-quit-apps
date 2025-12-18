import SwiftUI

/// Slow Quit Apps 主入口
/// 一个防止 Cmd+Q 误触的 macOS 工具
@main
struct SlowQuitAppsApp: App {
    /// 应用代理
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 菜单栏应用，不需要主窗口
        Settings {
            SettingsWindowView()
        }
    }
}
