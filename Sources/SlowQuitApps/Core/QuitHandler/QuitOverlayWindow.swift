import Cocoa
import SwiftUI

/// Quit progress overlay window
/// Floats at screen center showing quit progress
@MainActor
final class QuitOverlayWindow {
    /// Shared instance
    static let shared = QuitOverlayWindow()

    /// Window panel
    private var window: NSPanel?

    /// Hosting controller
    private var hostingController: NSHostingController<QuitOverlayView>?

    /// Current progress
    private var currentProgress: Double = 0

    /// Current app name
    private var currentAppName: String = ""

    /// Current key label
    private var currentKeyLabel: String = "Q"

    private init() {}

    // MARK: - Public

    /// Show the progress window
    func show(appName: String, keyLabel: String) {
        currentAppName = appName
        currentKeyLabel = keyLabel
        currentProgress = 0

        // Create or refresh the window
        if window == nil {
            createWindow()
        }

        updateView()

        guard let window = window else { return }

        // Position at screen center
        centerWindow(window)

        // Show the window
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
    }

    /// Update progress
    func updateProgress(_ progress: Double) {
        currentProgress = progress
        updateView()
    }

    /// Hide the window
    func hide() {
        window?.orderOut(nil)
        currentProgress = 0
    }

    // MARK: - Private

    /// Create the window panel
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

        // Configure window
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = false

        // Create SwiftUI view
        let view = QuitOverlayView(
            progress: currentProgress,
            appName: currentAppName,
            animated: AppState.shared.showProgressAnimation,
            keyLabel: currentKeyLabel
        )

        let hostingController = NSHostingController(rootView: view)
        panel.contentViewController = hostingController

        self.window = panel
        self.hostingController = hostingController
    }

    /// Refresh the SwiftUI view
    private func updateView() {
        let view = QuitOverlayView(
            progress: currentProgress,
            appName: currentAppName,
            animated: AppState.shared.showProgressAnimation,
            keyLabel: currentKeyLabel
        )
        hostingController?.rootView = view
    }

    /// Center the window on screen
    private func centerWindow(_ window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowFrame = window.frame

        let x = screenFrame.midX - windowFrame.width / 2
        let y = screenFrame.midY - windowFrame.height / 2

        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
