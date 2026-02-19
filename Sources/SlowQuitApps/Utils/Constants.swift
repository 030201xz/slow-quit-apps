import Foundation

/// App-wide constants
enum Constants {
    /// App info
    enum App {
        static let name = "Slow Quit Apps"
        static let bundleIdentifier = "com.slowquitapps.app"
        static let version = "1.1.0"
    }

    /// Keyboard shortcuts
    enum Keyboard {
        /// Virtual key code for Q
        static let qKeyCode: UInt16 = 12
        /// Virtual key code for W
        static let wKeyCode: UInt16 = 13
        /// Command modifier flag
        static let commandModifier: UInt = 1 << 20
    }

    /// Progress configuration
    enum Progress {
        /// Default hold duration (seconds)
        static let defaultHoldDuration: Double = 1.0
        /// Minimum hold duration
        static let minHoldDuration: Double = 0.3
        /// Maximum hold duration
        static let maxHoldDuration: Double = 3.0
        /// Timer update interval (seconds)
        static let updateInterval: Double = 1.0 / 60.0
    }

    /// Window sizes
    enum Window {
        /// Overlay window width
        static let overlayWidth: CGFloat = 200
        /// Overlay window height
        static let overlayHeight: CGFloat = 60
        /// Settings window width
        static let settingsWidth: CGFloat = 500
        /// Settings window height
        static let settingsHeight: CGFloat = 350
    }
}
