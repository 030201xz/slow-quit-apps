import Cocoa

/// Quit progress controller
/// Core logic: keyDown starts the timer, keyUp cancels it, completion triggers quit or close
@MainActor
final class QuitProgressController: KeyEventDelegate {
    static let shared = QuitProgressController()

    /// Progress update timer
    private var timer: Timer?

    /// Time when the key was pressed
    private var startTime: Date?

    /// Target application
    private var targetApp: NSRunningApplication?

    /// Whether the timer is running
    private var isRunning = false

    /// Key code that triggered the current long press
    private var triggeredKeyCode: UInt16 = 0

    /// Modifiers held when the long press started (used to replay the exact combination)
    private var triggeredModifiers: CGEventFlags = []

    /// Safety timeout (seconds) — prevents timer leaks
    /// Force-stops if no keyUp received within holdDuration + this value
    private let safetyTimeout: TimeInterval = 1.0

    private let appState = AppState.shared
    private let overlayWindow = QuitOverlayWindow.shared

    private init() {}

    // MARK: - Public

    func start() {
        KeyEventMonitor.shared.delegate = self
        observeExcludedApps()
        KeyEventMonitor.shared.startMonitoring()
    }

    private func observeExcludedApps() {
        withObservationTracking {
            let ids = Set(appState.excludedApps.filter(\.isExcluded).map(\.bundleIdentifier))
            KeyEventMonitor.shared.setExcludedApps(ids)
            KeyEventMonitor.shared.setCloseWindowOnLongPress(appState.closeWindowOnLongPress)
        } onChange: {
            Task { @MainActor [weak self] in
                self?.observeExcludedApps()
            }
        }
    }

    func stop() {
        KeyEventMonitor.shared.stopMonitoring()
        stopTimer()
    }

    // MARK: - KeyEventDelegate

    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyDown event: KeyEvent) {
        // Already timing — ignore key repeat
        guard !isRunning else { return }

        // quitOnLongPress only governs Cmd+Q
        if event.isCmdQDown {
            guard appState.quitOnLongPress else {
                NSWorkspace.shared.frontmostApplication?.terminate()
                return
            }
        }

        guard let app = NSWorkspace.shared.frontmostApplication,
              let bundleId = app.bundleIdentifier else { return }

        print("🔍 Detected Cmd+\(event.isWKey ? "W" : "Q"): \(app.localizedName ?? "Unknown") [\(bundleId)]")
        print("⏱️ Timer started")
        triggeredKeyCode = event.keyCode
        triggeredModifiers = CGEventFlags(rawValue: UInt64(event.modifiers))
        startTimer(for: app)
    }

    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyUp event: KeyEvent) {
        stopTimer()
    }

    // MARK: - Timer

    private func startTimer(for app: NSRunningApplication) {
        // Clear any leftover timer
        stopTimer()

        isRunning = true
        startTime = Date()
        targetApp = app

        let appName = app.localizedName ?? "Unknown"
        let keyLabel = triggeredKeyCode == Constants.Keyboard.wKeyCode ? "W" : "Q"
        overlayWindow.show(appName: appName, keyLabel: keyLabel)
        appState.startQuitProgress(for: app.bundleIdentifier ?? "")

        // Update at 60 fps
        let newTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
        timer = newTimer
        RunLoop.main.add(newTimer, forMode: .common)
    }

    private func tick() {
        // Safety check: stop if state is inconsistent
        guard isRunning,
              let start = startTime,
              let app = targetApp else {
            stopTimer()
            return
        }

        // Stop if the target app has already quit
        guard !app.isTerminated else {
            stopTimer()
            return
        }

        let elapsed = Date().timeIntervalSince(start)

        // Safety timeout: prevent timer leaks
        let maxDuration = appState.holdDuration + safetyTimeout
        if elapsed > maxDuration {
            print("⚠️ Safety timeout — force-stopping timer")
            stopTimer()
            return
        }

        let progress = min(1.0, elapsed / appState.holdDuration)

        appState.updateQuitProgress(progress)
        overlayWindow.updateProgress(progress)

        if progress >= 1.0 {
            let keyCode = triggeredKeyCode
            let modifiers = triggeredModifiers
            stopTimer()
            appState.completeQuit()
            synthesizeAndPost(keyCode: keyCode, modifiers: modifiers)
        }
    }

    /// Synthesize and post a key event with the original modifiers to the frontmost app
    private func synthesizeAndPost(keyCode: UInt16, modifiers: CGEventFlags) {
        // Set passthrough flag so our tap doesn't re-intercept the synthesized event
        KeyEventMonitorWrapper.shared.passthroughKeyCode = keyCode
        // Also release the real keyUp (user is still holding the key)
        KeyEventMonitorWrapper.shared.isIntercepting = false

        let src = CGEventSource(stateID: .hidSystemState)
        let evt = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(keyCode), keyDown: true)
        evt?.flags = modifiers
        evt?.post(tap: .cghidEventTap)
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
