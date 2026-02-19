import Cocoa
import SwiftUI

/// App delegate
/// Manages app lifecycle and the menu bar icon
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Status bar item
    private var statusItem: NSStatusItem?

    /// Settings window
    private var settingsWindow: NSWindow?

    /// ⌘Q menu item
    private var enableQItem: NSMenuItem?

    /// ⌘W menu item
    private var enableWItem: NSMenuItem?

    /// App state
    private let appState = AppState.shared

    /// Accessibility check timer
    private var accessibilityCheckTimer: Timer?

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up menu bar icon
        setupStatusItem()

        // Hide Dock icon (runs as menu bar app)
        NSApp.setActivationPolicy(.accessory)

        // Check accessibility permission and start monitoring
        startMonitoringWithAccessibilityCheck()

        print("✅ \(Constants.App.name) launched")
    }

    func applicationWillTerminate(_ notification: Notification) {
        accessibilityCheckTimer?.invalidate()
        QuitProgressController.shared.stop()
        print("🛑 \(Constants.App.name) terminated")
    }

    // MARK: - Accessibility

    /// Start monitoring and check accessibility permission
    private func startMonitoringWithAccessibilityCheck() {
        if AccessibilityManager.shared.isAccessibilityEnabled {
            // Permission granted, start immediately
            print("✅ Accessibility permission granted")
            QuitProgressController.shared.start()
        } else {
            // Request permission and start polling
            print("⚠️ Waiting for accessibility permission...")
            AccessibilityManager.shared.requestAccessibility()
            startAccessibilityPolling()
        }
    }

    /// Poll for accessibility permission
    private func startAccessibilityPolling() {
        accessibilityCheckTimer?.invalidate()
        accessibilityCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if AccessibilityManager.shared.isAccessibilityEnabled {
                    self.accessibilityCheckTimer?.invalidate()
                    self.accessibilityCheckTimer = nil
                    print("✅ Accessibility granted, starting monitor...")
                    QuitProgressController.shared.start()
                }
            }
        }
    }

    // MARK: - Menu Bar

    /// Set up status bar item
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }

        // Set icon
        button.image = NSImage(systemSymbolName: "hand.raised.fill", accessibilityDescription: "Slow Quit Apps")
        button.image?.size = NSSize(width: 18, height: 18)

        // Build menu
        let menu = NSMenu()

        // ⌘Q toggle
        let enableItem = NSMenuItem(
            title: appState.quitOnLongPress ? t("menu.disable") : t("menu.enable"),
            action: #selector(toggleQuitOnLongPress),
            keyEquivalent: ""
        )
        enableItem.target = self
        menu.addItem(enableItem)
        enableQItem = enableItem

        // ⌘W toggle
        let enableWItem = NSMenuItem(
            title: appState.closeWindowOnLongPress ? t("menu.disableW") : t("menu.enableW"),
            action: #selector(toggleCloseWindow),
            keyEquivalent: ""
        )
        enableWItem.target = self
        menu.addItem(enableWItem)
        self.enableWItem = enableWItem

        menu.addItem(.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: t("menu.settings"),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "\(t("menu.quit")) \(Constants.App.name)",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    // MARK: - Menu Actions

    /// Toggle ⌘Q interception
    @objc private func toggleQuitOnLongPress() {
        appState.toggleQuitOnLongPress()
        enableQItem?.title = appState.quitOnLongPress ? t("menu.disable") : t("menu.enable")
    }

    /// Toggle ⌘W interception
    @objc private func toggleCloseWindow() {
        appState.closeWindowOnLongPress.toggle()
        enableWItem?.title = appState.closeWindowOnLongPress ? t("menu.disableW") : t("menu.enableW")
    }

    /// Open settings window
    @objc private func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create settings window
        let contentView = SettingsWindowView()
        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "\(Constants.App.name) \(t("menu.settings").replacingOccurrences(of: "...", with: ""))"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(
            width: Constants.Window.settingsWidth,
            height: Constants.Window.settingsHeight
        ))
        window.center()

        // Clear reference when window closes
        window.isReleasedWhenClosed = false

        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Quit the app
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
