<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-01-29 | Updated: 2026-01-29 -->

# Sources

## Purpose

This directory contains the main **terminalHangul** macOS menu bar application implementation. It uses a CGEvent tap approach to globally intercept keyboard events and detect when Korean (Hangul) input composition needs to be completed in supported terminal applications.

The app runs in the menu bar and provides system-level keyboard interception without relying on InputMethodKit, making it work consistently across all terminal applications.

## Key Files

| File | Description |
|------|-------------|
| `main.swift` | Application entry point; initializes NSApplication and AppDelegate |
| `AppDelegate.swift` | Menu bar UI setup, component initialization, permission checking, enable/disable toggle |
| `Core/EventInterceptor.swift` | CGEvent tap implementation; manages keyboard event interception and life cycle |
| `Core/DecisionEngine.swift` | Event processing logic; determines when to synthesize composition-forcing sequence |
| `Core/CompositionTracker.swift` | Monitors current keyboard input source via Text Input Services (TIS) |
| `Core/AppContextDetector.swift` | Detects active application and monitors supported terminal status |
| `Core/KeyEventSynthesizer.swift` | Synthesizes keyboard events to force Hangul composition commit |
| `Utils/Permissions.swift` | Manages Input Monitoring permission checks and requests |
| `Utils/KeyCodes.swift` | macOS virtual key codes (QWERTY layout) and Hangul jamo key detection |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `terminalHangul/Core/` | Core event interception and composition logic |
| `terminalHangul/Utils/` | Utility functions (permissions, key codes) |

## For AI Agents

### Working In This Directory

1. **Understand the Architecture:**
   - The app intercepts keyboard events globally via CGEvent tap
   - When Shift+Enter is pressed in a supported terminal with active Hangul input, a composition-forcing sequence is synthesized
   - The composition-forcing sequence: Space (commits) → Backspace (removes space) → Shift+Enter (newline)

2. **Component Interaction Flow:**
   ```
   Keyboard Event
        ↓
   EventInterceptor (tap callback)
        ↓
   DecisionEngine.processEvent()
        ↓
   AppContextDetector.isTerminalActive()? + CompositionTracker.isHangulInputActive()?
        ↓
   If Shift+Enter detected:
     KeyEventSynthesizer.synthesizeCompositionForcingSequence()
        ↓
   Return nil (consume original event)
   ```

3. **Key Components and Responsibilities:**

   **EventInterceptor.swift**
   - Creates and manages CGEvent tap (must request Input Monitoring permission)
   - Runs tap callback on private dispatch queue to avoid blocking
   - Delegates all event processing to DecisionEngine
   - Handles tap re-enablement if system disables it
   - Methods: `start()`, `stop()`, `isRunning`

   **DecisionEngine.swift**
   - Receives all keyboard events from EventInterceptor
   - Checks terminal status via AppContextDetector
   - Checks Hangul input status via CompositionTracker
   - Tracks modifier keys (shift, control, option, command)
   - Synthesizes key sequences via KeyEventSynthesizer
   - Implements debouncing (50ms) to prevent rapid repeated commits
   - Methods: `processEvent()`, returns CGEvent or nil (to consume)

   **CompositionTracker.swift**
   - Monitors current keyboard input source via TIS APIs
   - Recognizes macOS built-in Korean (2-set, 3-set, Sebulshik) and Gureum input method
   - Tracks individual Hangul jamo keys during composition
   - Updates when input source changes or input method switches
   - Methods: `isHangulInputActive()`, `currentInputSourceID()`, `currentInputSourceName()`, `clearCompositionState()`

   **AppContextDetector.swift**
   - Monitors active application via NSWorkspace and NSWorkspaceDidActivateApplicationNotification
   - Maintains hardcoded set of supported terminal bundle IDs (Terminal.app, iTerm2, Warp, Kitty, Alacritty, Hyper, WezTerm)
   - Caches current app name for logging
   - Methods: `isTerminalActive()`, `currentAppName()`, `refresh()`, property `onTerminalStateChanged`

   **KeyEventSynthesizer.swift**
   - Wraps CGEvent creation and posting for keyboard events
   - Synthesizes keyDown, keyUp, and complete key presses (down + up)
   - Marks synthesized events with a special tag to prevent infinite interception loops
   - Supports multiple composition-forcing strategies
   - Methods: `synthesizeKeyPress()`, static method `isSynthesizedEvent()`

4. **Development Workflow:**

   ```bash
   # Build the Swift executable
   swift build

   # Run the app (appears in menu bar)
   swift run

   # Run with terminal logs visible
   swift run 2>&1 | grep -i "hangul\|composition\|interceptor"

   # Test manual flow:
   # 1. Enable app from menu bar
   # 2. Grant Input Monitoring permission if prompted
   # 3. Open Terminal.app (or iTerm2)
   # 4. Switch keyboard input to Korean (한글)
   # 5. Type some Korean text
   # 6. Press Shift+Enter
   # 7. Verify: Text should be completed and newline inserted in single key press
   ```

5. **Adding Support for New Terminals:**
   - Edit `Core/AppContextDetector.swift`
   - Find the `supportedTerminals` property (Set of bundle IDs)
   - Add new terminal's bundle ID to the set
   - Bundle IDs can be discovered via: `mdls -name kMDItemCFBundleIdentifier -r /Applications/TerminalApp.app`

6. **Debugging Composition Tracking:**
   - Edit `Core/DecisionEngine.swift`
   - Set `debugEnabled = true` (typically near top of class)
   - Run: `swift run 2>&1`
   - Observe logs for: Hangul input source detection, jamo keys pressed, composition state changes

7. **File Organization Conventions:**
   - Core logic lives in `Core/` subdirectory
   - Reusable utilities live in `Utils/` subdirectory
   - Main app setup in root of `terminalHangul/`
   - One class per file (Swift convention)
   - Use `// MARK: -` sections for code organization

### Testing Requirements

1. **Functional Testing (Manual):**
   - Start app: `swift run`
   - Enable from menu bar
   - Verify Input Monitoring permission prompt (first run)
   - Grant permission in System Settings > Privacy & Security > Input Monitoring
   - Open supported terminal application
   - Switch input method to Korean (macOS Korean or Gureum)
   - Type Korean text: 한글
   - Press Shift+Enter
   - Expected result: Composition commits and newline inserted in single key press

2. **Terminal Compatibility Testing:**
   - Test in each supported terminal: Terminal.app, iTerm2, Warp, Kitty, Alacritty, Hyper, WezTerm
   - Verify Shift+Enter works correctly in each
   - Test multi-line shell input (e.g., `cat <<EOF`)
   - Test in shell prompts and text editors within terminals

3. **Input Method Testing:**
   - Test with macOS Korean (2-set layout)
   - Test with macOS Korean (3-set layout)
   - Test with macOS Korean (Sebulshik layout)
   - Test with Gureum input method
   - Verify composition detection works for each

4. **Edge Cases:**
   - Switch between terminals while app is running → AppContextDetector should update
   - Switch input methods while app is running → CompositionTracker should detect change
   - Rapid Shift+Enter presses → Debouncing should prevent multiple commits
   - Other modifier combinations (Cmd+Enter, Ctrl+Enter, Option+Enter) → Should pass through unchanged
   - App background/foreground transition → Event tap should remain active

5. **Permission & Lifecycle:**
   - First run without Input Monitoring permission → Should show alert
   - Click "Open System Preferences" → Should open System Settings
   - Grant permission → App should function
   - Revoke permission → App should gracefully stop and alert user

### Common Patterns

**Checking Hangul Input Status:**
```swift
// In DecisionEngine or any component with compositionTracker
if compositionTracker.isHangulInputActive() {
    let inputID = compositionTracker.currentInputSourceID()
    let inputName = compositionTracker.currentInputSourceName()
    debugLog("Hangul input active: \(inputName)")
}
```

**Checking Terminal Status:**
```swift
// In DecisionEngine or any component with appContextDetector
if appContextDetector.isTerminalActive() {
    let appName = appContextDetector.currentAppName()
    debugLog("Active terminal: \(appName)")
} else {
    appContextDetector.refresh()
}
```

**Handling Shift+Enter Composition:**
```swift
// In DecisionEngine.processEvent()
if keyCode == KeyCodes.enter && flags.contains(.maskShift) {
    if appContextDetector.isTerminalActive() && compositionTracker.isHangulInputActive() {
        // Force composition: Space → Backspace → Shift+Enter
        keyEventSynthesizer.synthesizeKeyPress(keyCode: UInt16(KeyCodes.space))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.keyEventSynthesizer.synthesizeKeyPress(keyCode: UInt16(KeyCodes.backspace))
            self.keyEventSynthesizer.synthesizeKeyPress(
                keyCode: UInt16(KeyCodes.enter),
                flags: .maskShift
            )
        }
        return nil  // Consume original event
    }
}
```

**Preventing Infinite Loops with Synthesized Events:**
```swift
// In EventInterceptor callback or DecisionEngine
if KeyEventSynthesizer.isSynthesizedEvent(event) {
    return event  // Don't re-process our own synthesized events
}
```

**Checking Input Monitoring Permission:**
```swift
// In AppDelegate.checkPermissions()
if !Permissions.hasInputMonitoringPermission() {
    showPermissionAlert()
    return false
}
// Safe to set up EventInterceptor
```

**Monitoring Input Source Changes:**
```swift
// In AppDelegate.setupCore()
compositionTracker.onInputSourceChanged = { isHangul in
    debugLog("Input source changed - Hangul: \(isHangul)")
    // Update UI or state as needed
}
```

**Monitoring Terminal Changes:**
```swift
// In AppDelegate.setupCore()
appContextDetector.onTerminalStateChanged = { isActive in
    debugLog("Terminal state changed - Active: \(isActive)")
    // Update UI or state as needed
}
```

**Using Key Codes:**
```swift
// Check specific keys
let enterCode = KeyCodes.enter      // 36
let spaceCode = KeyCodes.space      // 49
let shiftCode = KeyCodes.shift      // 56

// Check if a key is a Hangul jamo
if KeyCodes.isHangulJamoKey(keyCode) {
    let keyName = KeyCodes.keyName(for: keyCode)
    debugLog("Hangul key pressed: \(keyName)")
}
```

**Debug Logging Pattern:**
```swift
// In DecisionEngine or any component
private func debugLog(_ message: String) {
    if debugEnabled {
        print("[DecisionEngine] \(message)")
    }
}

// Usage
debugLog("Event type: \(type), keyCode: \(keyCode), Hangul: \(compositionTracker.isHangulInputActive())")
```

**Deferred Composition Forcing with Timing:**
```swift
// Force composition with proper timing
func forceComposition() {
    let debounceInterval = 0.05  // 50ms

    keyEventSynthesizer.synthesizeKeyPress(keyCode: UInt16(KeyCodes.space))

    DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval) {
        self.keyEventSynthesizer.synthesizeKeyPress(keyCode: UInt16(KeyCodes.backspace))
        self.keyEventSynthesizer.synthesizeKeyPress(
            keyCode: UInt16(KeyCodes.enter),
            flags: .maskShift
        )
    }
}
```

## Dependencies

### External

- **Cocoa** - macOS UI framework (NSApplication, NSMenu, NSStatusBar, NSWorkspace, NSAlert)
- **CoreGraphics** - Event handling (CGEvent, CGEventTap, CGEventType, CGEventFlags, CFMachPort, CFRunLoopSource)
- **Carbon** - Text Input Services (TIS) for input source enumeration and detection
- **AppKit** - System integration and accessibility features

### Internal

- `EventInterceptor` - Manages CGEvent tap creation and keyboard event interception
- `DecisionEngine` - Orchestrates event processing and decision logic
- `CompositionTracker` - Tracks keyboard input source and Hangul composition state
- `AppContextDetector` - Monitors active application and terminal detection
- `KeyEventSynthesizer` - Creates and posts synthesized keyboard events
- `Permissions` - Handles Input Monitoring permission checks and requests
- `KeyCodes` - Key code constants and Hangul jamo detection utilities

## Architecture Notes

### Event Tap Design

- Uses global CGEvent tap at kCGHIDEventTap location (requires Input Monitoring permission)
- Tap callback runs on private dispatch queue to avoid blocking system
- Event tap can be disabled by system; app monitors for this and re-enables
- Synthesized events are marked to prevent re-interception (infinite loop prevention)

### Composition Forcing Strategy

The app uses a three-step approach to force Hangul composition:

1. **Synthesize Space**: Commits the pending composition to the app
2. **Synthesize Backspace**: Removes the space character (visible artifact)
3. **Synthesize Shift+Enter**: Inserts the newline

Alternative strategies (arrow keys, escape) are supported but space+backspace is most reliable.

### Debouncing

50ms debounce interval prevents rapid repeated composition commits when user holds Shift+Enter.

### Terminal Detection

Supported terminals are hardcoded as a static Set of bundle IDs in AppContextDetector for performance. This can be made user-configurable if needed.

## Development Guidelines

1. **Before Making Changes:**
   - Understand the current event flow in DecisionEngine
   - Check if change affects multiple components
   - Review existing test scenarios

2. **Code Organization:**
   - One Swift file per class/struct
   - Use `// MARK: -` to organize code sections
   - Keep Core logic separate from Utils
   - Keep Utils independent (no dependencies on Core)

3. **Error Handling:**
   - Permission failures: Show NSAlert to user
   - Event tap failures: Log error and return false from start()
   - Synthesized event failures: Log but don't crash
   - Input source failures: Degrade gracefully, assume input is not Hangul

4. **Performance Considerations:**
   - Event tap callback must not block (use background dispatch queue)
   - Debounce rapid operations (50ms minimum)
   - Cache app bundle IDs (no repeated file system lookups)
   - Use weak self in closures to prevent retain cycles

5. **Testing Changes:**
   - Always test in at least Terminal.app and iTerm2
   - Test with both macOS Korean and Gureum
   - Verify debouncing works (no repeated commits)
   - Check permission flow (first run, denied, revoked)

<!-- MANUAL: Last updated by [agent name] on [date] -->
