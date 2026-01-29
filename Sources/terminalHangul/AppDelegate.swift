import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private var isEnabled: Bool = false
    private var launchAtLoginItem: NSMenuItem?
    private let launchAgentIdentifier = "com.devautofarm.terminalhangul"

    private var eventInterceptor: EventInterceptor?
    private var compositionTracker: CompositionTracker?
    private var appContextDetector: AppContextDetector?
    private var keyEventSynthesizer: KeyEventSynthesizer?
    private var decisionEngine: DecisionEngine?

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupCore()
        checkPermissions()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopInterception()
    }

    // MARK: - Setup

    private func setupMenuBar() {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        guard let button = statusItem?.button else {
            print("Failed to create status bar button")
            return
        }

        // TODO: Add icon or text to button
        button.title = "한"

        // Create menu
        menu = NSMenu()

        // Toggle menu item
        let toggleItem = NSMenuItem(
            title: "▶️ Enable terminalHangul",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        menu?.addItem(toggleItem)

        // Launch at Login menu item
        launchAtLoginItem = NSMenuItem(
            title: "🔄 로그인 시 열기",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem?.state = isLaunchAtLoginEnabled() ? .on : .off
        menu?.addItem(launchAtLoginItem!)

        menu?.addItem(NSMenuItem.separator())

        // Support Development menu item
        let supportItem = NSMenuItem(
            title: "☕ Support Development",
            action: #selector(openSupportPage),
            keyEquivalent: ""
        )
        menu?.addItem(supportItem)

        // About menu item
        let aboutItem = NSMenuItem(
            title: "ℹ️ About terminalHangul",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        menu?.addItem(aboutItem)

        menu?.addItem(NSMenuItem.separator())

        // Quit menu item
        let quitItem = NSMenuItem(
            title: "🚪 Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu?.addItem(quitItem)

        statusItem?.menu = menu
    }

    private func setupCore() {
        // TODO: Initialize core components
        compositionTracker = CompositionTracker()
        appContextDetector = AppContextDetector()
        keyEventSynthesizer = KeyEventSynthesizer()
        decisionEngine = DecisionEngine(
            compositionTracker: compositionTracker!,
            appContextDetector: appContextDetector!,
            keyEventSynthesizer: keyEventSynthesizer!
        )
        eventInterceptor = EventInterceptor(decisionEngine: decisionEngine!)
    }

    private func checkPermissions() {
        // TODO: Check and request Input Monitoring permission
        if !Permissions.hasInputMonitoringPermission() {
            showPermissionAlert()
        }
    }

    // MARK: - Actions

    @objc private func toggleEnabled() {
        isEnabled.toggle()

        if isEnabled {
            startInterception()
            updateMenuTitle(to: "⏹️ Disable terminalHangul")
            updateStatusIcon(enabled: true)
        } else {
            stopInterception()
            updateMenuTitle(to: "▶️ Enable terminalHangul")
            updateStatusIcon(enabled: false)
        }
    }

    @objc private func openSupportPage() {
        if let url = URL(string: "https://buymeacoffee.com/devautofarm") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "About terminalHangul"
        alert.informativeText = """
        terminalHangul
        Version 1.2.1

        A macOS menu bar app that enables proper Korean input composition in terminal applications.

        © 2026 terminalHangul
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func startInterception() {
        _ = eventInterceptor?.start()
    }

    private func stopInterception() {
        // TODO: Stop event tap
        eventInterceptor?.stop()
    }

    @objc private func toggleLaunchAtLogin() {
        if isLaunchAtLoginEnabled() {
            disableLaunchAtLogin()
            launchAtLoginItem?.state = .off
        } else {
            enableLaunchAtLogin()
            launchAtLoginItem?.state = .on
        }
    }

    private func isLaunchAtLoginEnabled() -> Bool {
        let launchAgentPath = getLaunchAgentPath()
        return FileManager.default.fileExists(atPath: launchAgentPath)
    }

    private func enableLaunchAtLogin() {
        let launchAgentPath = getLaunchAgentPath()
        let launchAgentsDir = (launchAgentPath as NSString).deletingLastPathComponent

        // Create LaunchAgents directory if needed
        try? FileManager.default.createDirectory(atPath: launchAgentsDir, withIntermediateDirectories: true)

        // Get app path
        guard let appPath = Bundle.main.bundlePath as String? else { return }

        let plistContent: [String: Any] = [
            "Label": launchAgentIdentifier,
            "ProgramArguments": ["\(appPath)/Contents/MacOS/TerminalHangul"],
            "RunAtLoad": true,
            "KeepAlive": false
        ]

        let plistData = try? PropertyListSerialization.data(fromPropertyList: plistContent, format: .xml, options: 0)
        try? plistData?.write(to: URL(fileURLWithPath: launchAgentPath))
    }

    private func disableLaunchAtLogin() {
        let launchAgentPath = getLaunchAgentPath()
        try? FileManager.default.removeItem(atPath: launchAgentPath)
    }

    private func getLaunchAgentPath() -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/Library/LaunchAgents/\(launchAgentIdentifier).plist"
    }

    // MARK: - UI Updates

    private func updateMenuTitle(to title: String) {
        if let toggleItem = menu?.item(at: 0) {
            toggleItem.title = title
        }
    }

    private func updateStatusIcon(enabled: Bool) {
        // TODO: Update status bar icon to reflect enabled state
        statusItem?.button?.title = enabled ? "✔" : "한"
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Input Monitoring Permission Required"
        alert.informativeText = "terminalHangul needs Input Monitoring permission to intercept keyboard events. Please grant permission in System Preferences > Security & Privacy > Privacy > Input Monitoring."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            Permissions.openInputMonitoringPreferences()
        }
    }
}
