import Cocoa
import CoreGraphics

/// Synthesizes key events to force Hangul composition completion
class KeyEventSynthesizer {

    // MARK: - Properties

    /// Flag to mark synthesized events to prevent infinite loops
    private static let synthesizedEventMarker: Int64 = 0xDEAD_BEEF

    /// Delay between synthesized events in microseconds
    private let eventDelay: useconds_t = 1000 // 1ms

    // MARK: - Public Methods

    /// Check if an event was synthesized by this class
    static func isSynthesizedEvent(_ event: CGEvent) -> Bool {
        return event.getIntegerValueField(.eventSourceUserData) == synthesizedEventMarker
    }

    /// Synthesize a key down event
    func synthesizeKeyDown(keyCode: UInt16, flags: CGEventFlags = []) -> Bool {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            return false
        }

        event.flags = flags
        event.setIntegerValueField(.eventSourceUserData, value: KeyEventSynthesizer.synthesizedEventMarker)
        event.post(tap: .cghidEventTap)

        return true
    }

    /// Synthesize a key up event
    func synthesizeKeyUp(keyCode: UInt16, flags: CGEventFlags = []) -> Bool {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            return false
        }

        event.flags = flags
        event.setIntegerValueField(.eventSourceUserData, value: KeyEventSynthesizer.synthesizedEventMarker)
        event.post(tap: .cghidEventTap)

        return true
    }

    /// Synthesize a complete key press (down + up) with optional delay
    func synthesizeKeyPress(keyCode: UInt16, flags: CGEventFlags = [], withDelay: Bool = true) -> Bool {
        guard synthesizeKeyDown(keyCode: keyCode, flags: flags) else {
            return false
        }

        if withDelay {
            usleep(eventDelay)
        }

        return synthesizeKeyUp(keyCode: keyCode, flags: flags)
    }

    /// Force Hangul composition completion by sending Right Arrow + Left Arrow
    /// This moves the cursor right and back, which forces the IME to commit
    func forceCompositionCommit() -> Bool {
        // Method 1: Right arrow then left arrow
        // This nudges the cursor to commit the composition

        let rightArrow = UInt16(KeyCodes.rightArrow)
        let leftArrow = UInt16(KeyCodes.leftArrow)

        // Send right arrow
        guard synthesizeKeyPress(keyCode: rightArrow) else {
            return false
        }

        usleep(eventDelay)

        // Send left arrow to restore cursor position
        guard synthesizeKeyPress(keyCode: leftArrow) else {
            return false
        }

        return true
    }

    /// Alternative: Force composition completion by sending Escape
    /// Some input methods respond to this
    func forceCompositionCommitWithEscape() -> Bool {
        let escapeKey = UInt16(KeyCodes.escape)
        return synthesizeKeyPress(keyCode: escapeKey)
    }

    /// Alternative: Send a space followed by backspace
    /// This is more reliable but leaves a visible artifact briefly
    func forceCompositionCommitWithSpaceBackspace() -> Bool {
        let spaceKey = UInt16(KeyCodes.space)
        let deleteKey = UInt16(KeyCodes.delete)

        guard synthesizeKeyPress(keyCode: spaceKey) else {
            return false
        }

        usleep(eventDelay * 2)

        return synthesizeKeyPress(keyCode: deleteKey)
    }

    /// Commit composition using Shift key press
    /// This is often the most reliable method
    func forceCompositionCommitWithShift() -> Bool {
        let shiftKey = UInt16(KeyCodes.shift)

        guard synthesizeKeyDown(keyCode: shiftKey) else {
            return false
        }

        usleep(eventDelay)

        return synthesizeKeyUp(keyCode: shiftKey)
    }
}
