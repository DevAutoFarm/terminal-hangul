import Cocoa

// Entry point for the terminalHangul macOS menu bar app
// This utility shows composing Hangul characters in real-time in macOS Terminal
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Prevent app from appearing in Dock
app.setActivationPolicy(.accessory)

// Run the application
app.run()
