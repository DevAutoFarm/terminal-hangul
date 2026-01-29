import Cocoa
import CoreGraphics

/// Intercepts keyboard events using CGEvent tap
class EventInterceptor {

    // MARK: - Properties

    /// The CGEvent tap for intercepting keyboard events
    fileprivate var eventTap: CFMachPort?

    /// Run loop source for the event tap
    private var runLoopSource: CFRunLoopSource?

    /// Decision engine that processes events
    private let decisionEngine: DecisionEngine

    /// Whether the interceptor is currently running
    private(set) var isRunning: Bool = false

    // MARK: - Initialization

    init(decisionEngine: DecisionEngine) {
        self.decisionEngine = decisionEngine
    }

    deinit {
        stop()
    }

    // MARK: - Public Methods

    /// Start intercepting keyboard events
    func start() -> Bool {
        guard !isRunning else {
            print("[EventInterceptor] Already running")
            return true
        }

        // Define events to intercept
        let eventMask: CGEventMask = (
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)
        )

        // Create the event tap
        // We need to use a C function pointer, so we'll use a static method approach
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("[EventInterceptor] Failed to create event tap - check Input Monitoring permission")
            return false
        }

        eventTap = tap

        // Create a run loop source and add it to the current run loop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        guard let source = runLoopSource else {
            print("[EventInterceptor] Failed to create run loop source")
            cleanup()
            return false
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)

        // Enable the event tap
        CGEvent.tapEnable(tap: tap, enable: true)

        isRunning = true
        print("[EventInterceptor] Started successfully")

        return true
    }

    /// Stop intercepting keyboard events
    func stop() {
        guard isRunning else {
            return
        }

        cleanup()
        isRunning = false
        print("[EventInterceptor] Stopped")
    }

    // MARK: - Private Methods

    private func cleanup() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
    }

    /// Process an intercepted event
    fileprivate func processEvent(_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent) -> CGEvent? {
        // Pass to decision engine for processing
        return decisionEngine.processEvent(proxy, type, event)
    }
}

// MARK: - Event Tap Callback

/// C-compatible callback function for CGEvent tap
private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {

    // Handle tap disabled event (system may disable tap if it's too slow)
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        print("[EventInterceptor] Event tap was disabled, re-enabling...")

        if let userInfo = userInfo {
            let interceptor = Unmanaged<EventInterceptor>.fromOpaque(userInfo).takeUnretainedValue()
            if let tap = interceptor.eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
        }

        return Unmanaged.passUnretained(event)
    }

    // Get the interceptor instance
    guard let userInfo = userInfo else {
        return Unmanaged.passUnretained(event)
    }

    let interceptor = Unmanaged<EventInterceptor>.fromOpaque(userInfo).takeUnretainedValue()

    // Process the event
    if let processedEvent = interceptor.processEvent(proxy, type, event) {
        return Unmanaged.passUnretained(processedEvent)
    } else {
        // nil means the event should be consumed (not passed through)
        return nil
    }
}
