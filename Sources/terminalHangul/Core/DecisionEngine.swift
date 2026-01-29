import Cocoa
import CoreGraphics

/// Coordinates all components to decide when to force Hangul composition completion
class DecisionEngine {

    // MARK: - Properties

    private let compositionTracker: CompositionTracker
    private let appContextDetector: AppContextDetector
    private let keyEventSynthesizer: KeyEventSynthesizer

    /// Time of last composition commit to debounce
    private var lastCommitTime: Date = .distantPast

    /// Minimum interval between forced commits (ms)
    private let commitDebounceInterval: TimeInterval = 0.05 // 50ms

    /// Whether we're currently in the middle of forcing a commit
    private var isForceCommitting: Bool = false

    /// Debug mode
    #if DEBUG
    var debugEnabled: Bool = false
    #endif

    // MARK: - Initialization

    init(
        compositionTracker: CompositionTracker,
        appContextDetector: AppContextDetector,
        keyEventSynthesizer: KeyEventSynthesizer
    ) {
        self.compositionTracker = compositionTracker
        self.appContextDetector = appContextDetector
        self.keyEventSynthesizer = keyEventSynthesizer

        setupCallbacks()
    }

    // MARK: - Public Methods

    /// Process an intercepted keyboard event
    /// Returns the event to pass through, or nil to consume it
    func processEvent(_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent) -> CGEvent? {

        // Always pass through synthesized events to prevent infinite loops
        if KeyEventSynthesizer.isSynthesizedEvent(event) {
            debugLog("Passing through synthesized event")
            return event
        }

        // Log all events for debugging
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let isTerminal = appContextDetector.isTerminalActive()
        let isHangul = compositionTracker.isHangulInputActive()
        debugLog("Event received - type: \(type.rawValue), keyCode: \(keyCode), terminal: \(isTerminal), hangul: \(isHangul)")

        // Only process if in a supported terminal with Hangul input
        guard shouldProcessEvents() else {
            debugLog("Skipping - conditions not met")
            return event
        }

        // Handle different event types
        switch type {
        case .keyDown:
            return handleKeyDown(event)

        case .keyUp:
            return handleKeyUp(event)

        case .flagsChanged:
            return handleFlagsChanged(event)

        default:
            return event
        }
    }

    // MARK: - Private Methods

    private func setupCallbacks() {
        // React to terminal activation changes
        appContextDetector.onTerminalStateChanged = { [weak self] isActive in
            self?.debugLog("Terminal active: \(isActive)")
            if !isActive {
                self?.compositionTracker.clearComposition()
            }
        }

        // React to input source changes
        compositionTracker.onInputSourceChanged = { [weak self] isHangul in
            self?.debugLog("Hangul input active: \(isHangul)")
        }
    }

    private func shouldProcessEvents() -> Bool {
        // Only intercept when:
        // 1. A supported terminal is active
        // 2. Hangul input source is active
        return appContextDetector.isTerminalActive() && compositionTracker.isHangulInputActive()
    }

    private func handleKeyDown(_ event: CGEvent) -> CGEvent? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        debugLog("Key down: \(keyCode) (\(KeyCodes.keyName(for: keyCode)))")

        // Check if this is a Hangul jamo key (letter keys used for typing Korean)
        if KeyCodes.isHangulJamoKey(keyCode) {
            // Track the key for composition
            compositionTracker.addToComposition(keyCode: UInt16(keyCode))
        }

        // For Shift+Enter: handle specially for multi-line input in prompts
        // This ensures composition is committed AND newline is inserted
        let isShiftEnter = keyCode == KeyCodes.enter && flags.contains(.maskShift)

        if isShiftEnter {
            debugLog("Shift+Enter intercepted - handling for multi-line input")

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                // Space commits the composition
                _ = self.keyEventSynthesizer.synthesizeKeyPress(keyCode: UInt16(KeyCodes.space))
                usleep(10000) // 10ms

                // Backspace removes the space
                _ = self.keyEventSynthesizer.synthesizeKeyPress(keyCode: UInt16(KeyCodes.delete))
                usleep(10000) // 10ms

                // Shift+Enter for newline within prompt
                _ = self.keyEventSynthesizer.synthesizeKeyPress(
                    keyCode: UInt16(KeyCodes.enter),
                    flags: .maskShift
                )

                self.compositionTracker.clearComposition()
                self.debugLog("Shift+Enter sequence completed")
            }

            // Return nil to consume the original Shift+Enter
            return nil
        }

        // For other commit trigger keys, just clear our tracking
        if shouldCommitOnKey(keyCode) {
            debugLog("Commit trigger key detected")
            compositionTracker.clearComposition()
        }

        return event
    }

    private func handleKeyUp(_ event: CGEvent) -> CGEvent? {
        // Generally pass through key up events
        return event
    }

    private func handleFlagsChanged(_ event: CGEvent) -> CGEvent? {
        // Modifier key changes - might indicate user wants to commit
        let flags = event.flags

        // If Command, Control, or Option is pressed, user likely wants to execute a command
        // Force commit any pending composition
        if flags.contains(.maskCommand) || flags.contains(.maskControl) || flags.contains(.maskAlternate) {
            if compositionTracker.isComposing() {
                debugLog("Modifier pressed while composing, forcing commit")
                forceCommitIfNeeded()
            }
        }

        return event
    }

    private func shouldCommitOnKey(_ keyCode: Int64) -> Bool {
        // These keys naturally end composition
        let commitTriggerKeys: Set<Int64> = [
            KeyCodes.space,
            KeyCodes.enter,
            KeyCodes.tab,
            KeyCodes.escape,
            KeyCodes.leftArrow,
            KeyCodes.rightArrow,
            KeyCodes.upArrow,
            KeyCodes.downArrow,
        ]

        return commitTriggerKeys.contains(keyCode)
    }

    private func forceCommitIfNeeded() {
        // Debounce rapid commits
        let now = Date()
        guard now.timeIntervalSince(lastCommitTime) >= commitDebounceInterval else {
            debugLog("Debouncing commit")
            return
        }

        // Prevent re-entrancy
        guard !isForceCommitting else {
            debugLog("Already committing, skipping")
            return
        }

        isForceCommitting = true
        lastCommitTime = now

        // Small delay to let the IME process the key first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { [weak self] in
            guard let self = self else { return }

            self.debugLog("Forcing composition commit with Right Arrow")

            // Method: Send Right Arrow to move cursor out of composition
            // This forces the IME to commit the current composing text
            let success = self.keyEventSynthesizer.synthesizeKeyPress(
                keyCode: UInt16(KeyCodes.rightArrow)
            )

            self.debugLog("Right Arrow sent: \(success)")

            // Clear our tracking since we've committed
            self.compositionTracker.clearComposition()

            self.isForceCommitting = false
        }
    }

    #if DEBUG
    private func debugLog(_ message: String) {
        if debugEnabled {
            print("[DecisionEngine] \(message)")
        }
    }
    #else
    private func debugLog(_ message: String) {
        // No-op in release builds
    }
    #endif
}
