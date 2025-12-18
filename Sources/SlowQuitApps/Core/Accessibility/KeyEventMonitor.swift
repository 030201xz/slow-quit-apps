import Cocoa
import Carbon.HIToolbox

/// 键盘事件类型
enum KeyEventType: Sendable {
    case keyDown
    case keyUp
}

/// 键盘事件信息
struct KeyEvent: Sendable {
    let keyCode: UInt16
    let modifiers: UInt
    let type: KeyEventType
    let timestamp: Date
    
    /// 是否是 Command + Q 组合键
    var isCmdQ: Bool {
        keyCode == Constants.Keyboard.qKeyCode && (modifiers & NSEvent.ModifierFlags.command.rawValue) != 0
    }
}

/// 键盘事件回调协议
@MainActor
protocol KeyEventDelegate: AnyObject {
    /// 按键按下事件
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyDown event: KeyEvent)
    /// 按键释放事件
    func keyEventMonitor(_ monitor: KeyEventMonitor, didReceiveKeyUp event: KeyEvent)
}

/// 全局键盘事件监听器
/// 使用 CGEvent Tap 监听全局键盘事件
@MainActor
final class KeyEventMonitor {
    /// 单例实例
    static let shared = KeyEventMonitor()
    
    /// 事件代理
    weak var delegate: KeyEventDelegate?
    
    /// 事件监听器引用
    private var eventTap: CFMachPort?
    
    /// 运行循环源
    private var runLoopSource: CFRunLoopSource?
    
    /// 是否正在监听
    private(set) var isMonitoring: Bool = false
    
    private init() {}
    
    // MARK: - 公开方法
    
    /// 开始监听键盘事件
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        // 创建事件掩码：监听按键按下和释放
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        
        // 创建监听器包装器
        let wrapper = KeyEventMonitorWrapper.shared
        wrapper.monitor = self
        
        // 创建事件监听器
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: keyEventCallback,
            userInfo: Unmanaged.passUnretained(wrapper).toOpaque()
        ) else {
            print("⚠️ 无法创建事件监听器，请检查无障碍权限")
            return
        }
        
        eventTap = tap
        
        // 创建运行循环源并添加到当前运行循环
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let source = runLoopSource else { return }
        
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        isMonitoring = true
        print("✅ 键盘事件监听已启动")
    }
    
    /// 停止监听键盘事件
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        
        eventTap = nil
        runLoopSource = nil
        isMonitoring = false
        
        print("🛑 键盘事件监听已停止")
    }
    
    /// 重新启用事件监听
    func reenableTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
    
    /// 处理键盘事件
    func handleKeyEvent(_ keyEvent: KeyEvent) {
        switch keyEvent.type {
        case .keyDown:
            delegate?.keyEventMonitor(self, didReceiveKeyDown: keyEvent)
        case .keyUp:
            delegate?.keyEventMonitor(self, didReceiveKeyUp: keyEvent)
        }
    }
}

// MARK: - 监听器包装器（用于 C 回调）

/// 用于在 C 回调中访问 KeyEventMonitor 的包装器
final class KeyEventMonitorWrapper: @unchecked Sendable {
    static let shared = KeyEventMonitorWrapper()
    
    weak var monitor: KeyEventMonitor?
    
    private init() {}
}

// MARK: - C 回调函数

/// CGEvent 回调函数
/// 必须是 C 函数，不能捕获上下文
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
    
    // 处理事件禁用通知
    guard type == .keyDown || type == .keyUp else {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            // 重新启用事件监听
            DispatchQueue.main.async {
                wrapper.monitor?.reenableTap()
            }
        }
        return Unmanaged.passRetained(event)
    }
    
    // 获取按键码
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
    
    // 获取修饰键
    let flags = event.flags
    let modifiers = UInt(flags.rawValue)
    
    // 创建事件信息
    let eventType: KeyEventType = type == .keyDown ? .keyDown : .keyUp
    let keyEvent = KeyEvent(
        keyCode: keyCode,
        modifiers: modifiers,
        type: eventType,
        timestamp: Date()
    )
    
    // 只处理 Cmd+Q 事件
    guard keyEvent.isCmdQ else {
        return Unmanaged.passRetained(event)
    }
    
    // 在主线程通知代理
    DispatchQueue.main.async {
        wrapper.monitor?.handleKeyEvent(keyEvent)
    }
    
    // 拦截 Cmd+Q 事件，不传递给系统
    return nil
}
