import Cocoa
import Carbon.HIToolbox

/// Keyboard event type
enum KeyEventType: Sendable {
    case keyDown
    case keyUp
    case flagsChanged  // modifier key change
}

/// Keyboard event data
struct KeyEvent: Sendable {
    let keyCode: UInt16
    let modifiers: UInt
    let type: KeyEventType
    let timestamp: Date

    /// Whether Command is held
    var hasCommandModifier: Bool {
        (modifiers & NSEvent.ModifierFlags.command.rawValue) != 0
    }

    /// Whether the key is Q
    var isQKey: Bool {
        keyCode == Constants.Keyboard.qKeyCode
    }

    /// Whether the key is W
    var isWKey: Bool {
        keyCode == Constants.Keyboard.wKeyCode
    }

    /// Whether Cmd+Q is pressed (any additional modifiers are allowed)
    var isCmdQDown: Bool {
        type == .keyDown && isQKey && hasCommandModifier
    }

    /// Whether Cmd+W is pressed (any additional modifiers are allowed)
    var isCmdWDown: Bool {
        type == .keyDown && isWKey && hasCommandModifier
    }
}

/// Keyboard event delegate protocol
@MainActor
protocol KeyEventDelegate: AnyObject {
    /// Key down event
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyDown event: KeyEvent)
    /// Key up event
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyUp event: KeyEvent)
}

/// Global keyboard event monitor
/// Uses CGEvent tap to intercept global keyboard events
@MainActor
final class KeyEventMonitor {
    /// Shared instance
    static let shared = KeyEventMonitor()

    /// Event delegate
    weak var delegate: KeyEventDelegate?

    /// Event tap reference
    private var eventTap: CFMachPort?

    /// Run loop source
    private var runLoopSource: CFRunLoopSource?

    /// Whether the monitor is active
    private(set) var isMonitoring: Bool = false

    /// Key code currently being intercepted (nil = none)
    private var interceptingKeyCode: UInt16? = nil

    private init() {}

    // MARK: - Public

    /// Start monitoring keyboard events
    func startMonitoring() {
        guard !isMonitoring else {
            print("⚠️ Monitor is already running")
            return
        }

        // Track the frontmost app
        KeyEventMonitorWrapper.shared.frontmostBundleID =
            NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeAppChanged(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )

        // Event mask: key down, key up, flags changed
        let eventMask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)

        // Set up wrapper
        let wrapper = KeyEventMonitorWrapper.shared
        wrapper.monitor = self

        print("🔧 Creating event tap...")

        // Create event tap
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: keyEventCallback,
            userInfo: Unmanaged.passUnretained(wrapper).toOpaque()
        ) else {
            print("❌ Failed to create event tap — check accessibility permission")
            return
        }

        eventTap = tap

        // Add run loop source
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let source = runLoopSource else {
            print("❌ Failed to create run loop source")
            return
        }

        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        isMonitoring = true
        print("✅ Keyboard monitor started, intercepting Cmd+Q / Cmd+W")
    }

    /// Stop monitoring keyboard events
    func stopMonitoring() {
        guard isMonitoring else { return }

        NSWorkspace.shared.notificationCenter.removeObserver(
            self,
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isMonitoring = false
        interceptingKeyCode = nil

        print("🛑 Keyboard monitor stopped")
    }

    @objc private func activeAppChanged(_ notification: Notification) {
        let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
        KeyEventMonitorWrapper.shared.frontmostBundleID = app?.bundleIdentifier ?? ""
    }

    /// Update excluded app bundle IDs
    func setExcludedApps(_ bundleIDs: Set<String>) {
        KeyEventMonitorWrapper.shared.excludedBundleIDs = bundleIDs
    }

    /// Update the close-window-on-long-press flag
    func setCloseWindowOnLongPress(_ enabled: Bool) {
        KeyEventMonitorWrapper.shared.closeWindowOnLongPress = enabled
    }

    /// Re-enable the event tap after timeout
    func reenableTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    /// Handle a keyboard event
    func handleKeyEvent(_ keyEvent: KeyEvent) {
        switch keyEvent.type {
        case .keyDown:
            if keyEvent.isCmdQDown || keyEvent.isCmdWDown {
                interceptingKeyCode = keyEvent.keyCode
                delegate?.keyEventMonitor(self, didReceiveKeyDown: keyEvent)
            }

        case .keyUp:
            if let code = interceptingKeyCode, keyEvent.keyCode == code {
                interceptingKeyCode = nil
                delegate?.keyEventMonitor(self, didReceiveKeyUp: keyEvent)
            }

        case .flagsChanged:
            if !keyEvent.hasCommandModifier && interceptingKeyCode != nil {
                interceptingKeyCode = nil
                delegate?.keyEventMonitor(self, didReceiveKeyUp: keyEvent)
            }
        }
    }
}

// MARK: - Wrapper (for C callback)

/// Wrapper for accessing KeyEventMonitor from the C callback
final class KeyEventMonitorWrapper: @unchecked Sendable {
    static let shared = KeyEventMonitorWrapper()

    weak var monitor: KeyEventMonitor?

    /// Excluded bundle IDs (written on main thread, read on C callback thread)
    nonisolated(unsafe) var excludedBundleIDs: Set<String> = []

    /// Bundle ID of the frontmost app (written on main thread, read on C callback thread)
    nonisolated(unsafe) var frontmostBundleID: String = ""

    /// Whether a key press is currently being intercepted
    nonisolated(unsafe) var isIntercepting: Bool = false

    /// Key code currently being intercepted
    nonisolated(unsafe) var interceptedKeyCode: UInt16 = 0

    /// Whether long-press-to-close-window (Cmd+W) is enabled
    nonisolated(unsafe) var closeWindowOnLongPress: Bool = true

    /// Key code to pass through after long press (prevents re-intercepting synthesized events)
    nonisolated(unsafe) var passthroughKeyCode: UInt16 = 0

    private init() {}
}

// MARK: - C Callback

/// CGEvent tap callback
private func keyEventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let info = userInfo else {
        return Unmanaged.passRetained(event)
    }

    let wrapper = Unmanaged<KeyEventMonitorWrapper>.fromOpaque(info).takeUnretainedValue()

    // Handle tap disabled notifications
    guard type == .keyDown || type == .keyUp || type == .flagsChanged else {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            DispatchQueue.main.async {
                wrapper.monitor?.reenableTap()
            }
        }
        return Unmanaged.passRetained(event)
    }

    // Extract key code and modifiers
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    let modifiers = UInt(event.flags.rawValue)

    // Map CGEventType to KeyEventType
    let eventType: KeyEventType
    switch type {
    case .keyDown: eventType = .keyDown
    case .keyUp: eventType = .keyUp
    case .flagsChanged: eventType = .flagsChanged
    default: return Unmanaged.passRetained(event)
    }

    let keyEvent = KeyEvent(
        keyCode: keyCode,
        modifiers: modifiers,
        type: eventType,
        timestamp: Date()
    )

    // Decide whether to intercept
    // 1. Cmd+Q keyDown should be intercepted
    // 2. keyUp for an intercepted key should also be intercepted
    // 3. flagsChanged is never intercepted

    let shouldIntercept: Bool
    switch eventType {
    case .keyDown:
        // Passthrough check: let synthesized events through after long press
        if wrapper.passthroughKeyCode != 0 && keyCode == wrapper.passthroughKeyCode {
            wrapper.passthroughKeyCode = 0
            shouldIntercept = false
        } else {
            let excluded = wrapper.excludedBundleIDs.contains(wrapper.frontmostBundleID)
            if keyEvent.isCmdQDown && !excluded {
                wrapper.interceptedKeyCode = keyCode
                wrapper.isIntercepting = true
                shouldIntercept = true
            } else if keyEvent.isCmdWDown && wrapper.closeWindowOnLongPress && !excluded {
                wrapper.interceptedKeyCode = keyCode
                wrapper.isIntercepting = true
                shouldIntercept = true
            } else {
                shouldIntercept = false
            }
        }
    case .keyUp:
        if keyCode == wrapper.interceptedKeyCode && wrapper.isIntercepting {
            wrapper.isIntercepting = false
            shouldIntercept = true
        } else {
            shouldIntercept = false
        }
    case .flagsChanged:
        shouldIntercept = false
    }

    // Notify delegate only for intercepted events
    if shouldIntercept {
        DispatchQueue.main.async {
            wrapper.monitor?.handleKeyEvent(keyEvent)
        }
    }

    // Return nil to suppress the event, otherwise pass it through
    return shouldIntercept ? nil : Unmanaged.passRetained(event)
}
