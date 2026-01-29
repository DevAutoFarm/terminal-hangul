<!-- Generated: 2026-01-29 -->

# terminalHangul AI Agent Documentation

## Purpose

This document describes the AI agent teams that maintain and develop terminalHangul. The project is organized into two complementary teams: **Dev Team** (for development) and **Biz Team** (for distribution and monetization).

## Project Overview

**terminalHangul** is a macOS menu bar application that solves the double Shift+Enter problem when typing Korean (Hangul) in terminal applications. In macOS terminals, after typing Korean, users need to press Shift+Enter twice. This app makes it work with a single Shift+Enter.

**Key Facts:**
- Platform: macOS 12.0+, Swift 5.7+
- License: MIT
- Status: v1.0.0 complete
- Supported Terminals: Terminal.app, iTerm2, Warp, Kitty, Alacritty, Hyper, WezTerm
- Supported Input Methods: macOS Korean, Gureum

## Team Structure

```
terminalHangul/
├── Sources/terminalHangul/           # Main event interception implementation
├── TerminalHangul/                   # Alternative InputMethodKit approach
├── agents/
│   ├── AGENTS.md                     # Team overview (in agents/ directory)
│   ├── dev-team/                     # Development agent team
│   └── biz-team/                     # Business/monetization agent team
└── homebrew/                         # Homebrew packaging for distribution
```

## Dev Team

**Location:** `/agents/dev-team/TEAM.md`

**Purpose:** Develop and maintain the terminalHangul application.

### Responsibilities

- Architecture and system design
- Feature implementation and bug fixes
- Code review and quality assurance
- Build system management
- Performance optimization

### Components Maintained

| Component | Description |
|-----------|-------------|
| **EventInterceptor** | CGEvent tap for global keyboard interception |
| **DecisionEngine** | Logic to decide when to force Hangul composition commit |
| **CompositionTracker** | Tracks Korean input state and detects composition |
| **AppContextDetector** | Detects active application and supported terminals |
| **KeyEventSynthesizer** | Synthesizes keyboard events to force composition |
| **Permissions** | Manages Input Monitoring permission handling |

## Biz Team

**Location:** `/agents/biz-team/TEAM.md`

**Purpose:** Handle distribution, marketing, and monetization.

### Responsibilities

- Create GitHub releases
- Manage Homebrew distribution
- Marketing and community engagement
- User feedback and issue triage
- Analytics and performance tracking

## Key Files

| File | Purpose |
|------|---------|
| `Package.swift` | SPM configuration for main executable |
| `Sources/terminalHangul/AppDelegate.swift` | Menu bar app entry point |
| `Sources/terminalHangul/Core/EventInterceptor.swift` | CGEvent tap implementation |
| `Sources/terminalHangul/Core/DecisionEngine.swift` | Event processing logic |
| `Sources/terminalHangul/Core/CompositionTracker.swift` | Hangul state tracking |
| `Sources/terminalHangul/Core/AppContextDetector.swift` | Terminal detection |
| `Sources/terminalHangul/Core/KeyEventSynthesizer.swift` | Keyboard event synthesis |
| `Sources/terminalHangul/Utils/Permissions.swift` | Permission handling |
| `Sources/terminalHangul/Utils/KeyCodes.swift` | macOS virtual key codes |
| `TerminalHangul/Package.swift` | Alternative InputMethodKit approach |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `Sources/` | Main event interception implementation (menu bar app) |
| `TerminalHangul/` | Alternative InputMethodKit-based input method |
| `agents/` | AI agent team documentation and coordination |
| `homebrew/` | Homebrew formula and distribution scripts |
| `.github/` | GitHub templates (issues, pull requests) |

## For AI Agents

### Working In This Directory

1. **Understand the Architecture:**
   - Menu bar app approach: Uses CGEvent tap to intercept Shift+Enter globally
   - Detects when terminal is active and Hangul input is in use
   - Synthesizes a composition-forcing sequence (Space → Backspace → Shift+Enter)

2. **Core Flow:**
   ```
   Keyboard Event
        ↓
   EventInterceptor (CGEvent tap)
        ↓
   DecisionEngine
        ↓
   Check: Terminal active? + Hangul input?
        ↓
   If Shift+Enter:
     - Synthesize Space (commits composition)
     - Synthesize Backspace (removes space)
     - Synthesize Shift+Enter (newline)
        ↓
   Consume original event (return nil)
   ```

3. **Key Classes:**

   **EventInterceptor.swift**
   - Manages CGEvent tap creation and lifecycle
   - Intercepts keyDown, keyUp, and flagsChanged events
   - Delegates processing to DecisionEngine
   - Handles tap re-enablement if system disables it

   **DecisionEngine.swift**
   - Receives events from EventInterceptor
   - Checks if terminal is active (AppContextDetector)
   - Checks if Hangul input is active (CompositionTracker)
   - Handles special cases (Shift+Enter, modifier keys)
   - Synthesizes key sequences via KeyEventSynthesizer

   **CompositionTracker.swift**
   - Monitors current keyboard input source via TIS (Text Input Services)
   - Recognizes macOS Korean (2-set, 3-set, Sebulshik) and Gureum
   - Tracks Hangul jamo keys pressed during composition
   - Clears composition state when input source changes

   **AppContextDetector.swift**
   - Monitors active application via NSWorkspace
   - Maintains list of supported terminal bundle IDs
   - Notifies DecisionEngine when terminal becomes active/inactive
   - Supports: Terminal.app, iTerm2, Warp, Kitty, Alacritty, Hyper, WezTerm

   **KeyEventSynthesizer.swift**
   - Wraps CGEvent creation and posting
   - Synthesizes keyDown, keyUp, and complete key presses
   - Marks synthesized events to prevent infinite loops
   - Multiple composition-forcing methods (arrow keys, space+backspace, escape)

4. **Development Workflow:**

   ```bash
   # Build
   swift build

   # Run (appears in menu bar)
   swift run

   # Test if terminal is detected
   # Open any supported terminal and switch input to Korean/Hangul
   # Type some Korean text and press Shift+Enter
   # Should complete composition and insert newline in one press
   ```

5. **Adding Support for New Terminals:**
   - Edit `AppContextDetector.swift`
   - Add bundle ID to `supportedTerminals` set
   - Bundle IDs can be found via: `mdls -name kMDItemCFBundleIdentifier -r /Applications/TerminalApp.app`

6. **Testing Composition Tracking:**
   - Edit `DecisionEngine.swift`, set `debugEnabled = true`
   - Run: `swift run | grep -i "hangul\|composition"`
   - Observe when Hangul input source is detected and jamo keys logged

### Testing Requirements

1. **Manual Testing:**
   - Start app: `swift run`
   - Enable in menu bar
   - Grant Input Monitoring permission
   - Open Terminal.app (or iTerm2, etc.)
   - Switch input method to Korean
   - Type Korean text, then Shift+Enter
   - Verify: Composition completes and newline inserted in single key press

2. **Terminal Support Testing:**
   - Test in each supported terminal (Terminal.app, iTerm2, Warp, etc.)
   - Verify Shift+Enter works correctly in each
   - Test multi-line input in shell prompts

3. **Input Method Testing:**
   - Test with macOS built-in Korean (2-set, 3-set, Sebulshik)
   - Test with Gureum input method
   - Verify composition tracking works for each

4. **Edge Cases:**
   - Switching terminals (check AppContextDetector updates)
   - Switching input methods (check CompositionTracker updates)
   - Rapid Shift+Enter presses (check debouncing)
   - Other modifier combinations (Cmd+Enter, Ctrl+Enter, etc.)

### Common Patterns

**Hangul Input Detection:**
```swift
// CompositionTracker provides these methods
let isHangul = compositionTracker.isHangulInputActive()
let inputSourceID = compositionTracker.currentInputSourceID()
let inputSourceName = compositionTracker.currentInputSourceName()
```

**Terminal Detection:**
```swift
// AppContextDetector provides these methods
let isTerminal = appContextDetector.isTerminalActive()
let appName = appContextDetector.currentAppName()
appContextDetector.refresh()
```

**Key Codes:**
```swift
// Defined in Utils/KeyCodes.swift
let keyCode = KeyCodes.enter    // 36
let keyCode = KeyCodes.space    // 49
let keyCode = KeyCodes.shift    // 56

// Check key type
if KeyCodes.isHangulJamoKey(keyCode) { /* ... */ }
let keyName = KeyCodes.keyName(for: keyCode)
```

**Synthesizing Events:**
```swift
// KeyEventSynthesizer methods
synthesizer.synthesizeKeyPress(keyCode: UInt16(KeyCodes.space))
synthesizer.synthesizeKeyPress(
    keyCode: UInt16(KeyCodes.enter),
    flags: .maskShift
)

// Check if event was synthesized (prevents loops)
if KeyEventSynthesizer.isSynthesizedEvent(event) { return event }
```

**Permission Checking:**
```swift
// Permissions methods
if Permissions.hasInputMonitoringPermission() { /* ... */ }
Permissions.requestInputMonitoringPermission()
Permissions.openInputMonitoringPreferences()
```

**Callbacks and Observers:**
```swift
// EventInterceptor notifies DecisionEngine
eventInterceptor.onEvent = { proxy, type, event in
    return decisionEngine.processEvent(proxy, type, event)
}

// DecisionEngine listens to component changes
appContextDetector.onTerminalStateChanged = { isActive in
    // Handle terminal switch
}

compositionTracker.onInputSourceChanged = { isHangul in
    // Handle input source change
}
```

**Debug Logging:**
```swift
// Enable in DecisionEngine
decisionEngine.debugEnabled = true

// Use throughout:
debugLog("Event received - type: \(type.rawValue), keyCode: \(keyCode)")
```

### Architecture Decisions

1. **CGEvent Tap vs. InputMethodKit:**
   - Using CGEvent tap (current): Global interception, works across all apps
   - InputMethodKit alternative in `TerminalHangul/`: Traditional input method, OS-managed

2. **Space+Backspace Composition Forcing:**
   - Current method: Space commits, Backspace removes space, then Shift+Enter
   - Alternative: Right+Left arrow to nudge cursor
   - Trade-off: Visible artifact vs. potential text corruption

3. **Debouncing (50ms):**
   - Prevents rapid repeated commits
   - Configurable via `commitDebounceInterval` in DecisionEngine

4. **Supported Terminals List:**
   - Hardcoded in AppContextDetector for performance
   - Can be made configurable if needed

## Dependencies

### External

- **Cocoa** - macOS UI framework (NSApplication, NSMenu, NSWorkspace)
- **CoreGraphics** - Event handling (CGEvent, CGEventTap)
- **Carbon** - Text Input Services (TIS) for input source detection
- **AppKit** - Accessibility and system integration

### Internal

- `EventInterceptor` - Manages CGEvent tap
- `DecisionEngine` - Processes events and orchestrates components
- `CompositionTracker` - Tracks input state
- `AppContextDetector` - Detects active terminal
- `KeyEventSynthesizer` - Creates synthesized events
- `Permissions` - Checks and requests permissions
- `KeyCodes` - Key code constants

## Development Guidelines

1. **Before Making Changes:**
   - Understand current flow in DecisionEngine
   - Check if change affects multiple components
   - Review existing test scenarios

2. **Code Organization:**
   - Core logic: `Sources/terminalHangul/Core/`
   - Utilities: `Sources/terminalHangul/Utils/`
   - App entry point: `Sources/terminalHangul/AppDelegate.swift`

3. **Error Handling:**
   - Permission failures: Show alert to user
   - Event tap failures: Log and allow graceful degradation
   - Synthesized event failures: Log but don't crash

4. **Performance:**
   - Event tap must not block (use DispatchQueue)
   - Debounce rapid operations (50ms interval)
   - Use weak self in closures to prevent leaks

## Contact & Collaboration

For questions about the Dev Team or codebase:
- Review `/agents/dev-team/TEAM.md` for agent contact info
- Check recent git history for current context
- Consult project README.md for user-facing information

For distribution, marketing, or release coordination:
- Contact Biz Team: `/agents/biz-team/TEAM.md`

<!-- MANUAL: Last updated by [agent name] on [date] -->
