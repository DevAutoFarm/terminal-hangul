import Cocoa

/// Detects which application is currently active and whether it's a supported terminal
class AppContextDetector {

    // MARK: - Properties

    /// Bundle identifiers for supported terminal applications
    private let supportedTerminals: Set<String> = [
        "com.apple.Terminal",           // Terminal.app
        "com.googlecode.iterm2",        // iTerm2
        "org.alacritty",                // Alacritty
        "net.kovidgoyal.kitty",         // Kitty
        "co.zeit.hyper",                // Hyper
        "dev.warp.Warp-Stable",         // Warp
        "org.wezfurlong.wezterm"        // WezTerm
    ]

    /// Currently active application bundle identifier
    private(set) var currentAppBundleId: String?

    /// Observer for app activation notifications
    private var appActivationObserver: NSObjectProtocol?

    /// Callback when terminal activation state changes
    var onTerminalStateChanged: ((Bool) -> Void)?

    // MARK: - Initialization

    init() {
        updateCurrentApp()
        setupObservers()
    }

    deinit {
        removeObservers()
    }

    // MARK: - Public Methods

    /// Returns true if a supported terminal is currently the frontmost application
    func isTerminalActive() -> Bool {
        guard let bundleId = currentAppBundleId else {
            return false
        }
        return supportedTerminals.contains(bundleId)
    }

    /// Returns the name of the currently active application
    func currentAppName() -> String? {
        return NSWorkspace.shared.frontmostApplication?.localizedName
    }

    /// Manually refresh the current app state
    func refresh() {
        updateCurrentApp()
    }

    // MARK: - Private Methods

    private func updateCurrentApp() {
        let previouslyActive = isTerminalActive()
        currentAppBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        let nowActive = isTerminalActive()

        if previouslyActive != nowActive {
            onTerminalStateChanged?(nowActive)
        }
    }

    private func setupObservers() {
        // Observe when a different app becomes active
        appActivationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleAppActivation(notification)
        }
    }

    private func removeObservers() {
        if let observer = appActivationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            appActivationObserver = nil
        }
    }

    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }

        let previouslyActive = isTerminalActive()
        currentAppBundleId = app.bundleIdentifier
        let nowActive = isTerminalActive()

        if previouslyActive != nowActive {
            onTerminalStateChanged?(nowActive)
        }
    }
}
