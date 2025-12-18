import Foundation

/// 应用常量定义
enum Constants {
    /// 应用信息
    enum App {
        static let name = "Slow Quit Apps"
        static let bundleIdentifier = "com.slowquitapps.app"
        static let version = "1.0.0"
    }
    
    /// 快捷键相关
    enum Keyboard {
        /// Command + Q 的按键码
        static let qKeyCode: UInt16 = 12
        /// Command 修饰键
        static let commandModifier: UInt = 1 << 20
    }
    
    /// 进度条配置
    enum Progress {
        /// 默认长按持续时间（秒）
        static let defaultHoldDuration: Double = 1.0
        /// 最小持续时间
        static let minHoldDuration: Double = 0.3
        /// 最大持续时间
        static let maxHoldDuration: Double = 3.0
        /// 进度更新频率（秒）
        static let updateInterval: Double = 1.0 / 60.0
    }
    
    /// 窗口尺寸
    enum Window {
        /// 进度条窗口宽度
        static let overlayWidth: CGFloat = 200
        /// 进度条窗口高度
        static let overlayHeight: CGFloat = 60
        /// 设置窗口宽度
        static let settingsWidth: CGFloat = 600
        /// 设置窗口高度
        static let settingsHeight: CGFloat = 400
        /// 设置侧边栏宽度
        static let sidebarWidth: CGFloat = 160
    }
}
