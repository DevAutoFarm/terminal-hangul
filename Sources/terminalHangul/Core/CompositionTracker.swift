import Cocoa
import Carbon

/// Tracks the current keyboard input source and Hangul composition state
class CompositionTracker {

    // MARK: - Properties

    /// Observer for input source changes
    private var inputSourceObserver: NSObjectProtocol?

    /// Currently composing Hangul jamo sequence
    private(set) var currentComposition: [UInt16] = []

    /// Callback when input source changes
    var onInputSourceChanged: ((Bool) -> Void)?

    /// Callback when composition state changes
    var onCompositionChanged: ((String?) -> Void)?

    // MARK: - Hangul Input Source Identifiers

    /// Known Korean/Hangul input source identifiers
    private let hangulInputSources: Set<String> = [
        "com.apple.inputmethod.Korean.2SetKorean",      // 2-set Korean
        "com.apple.inputmethod.Korean.3SetKorean",      // 3-set Korean (390)
        "com.apple.inputmethod.Korean.390Sebulshik",    // 3-set Korean (390)
        "com.apple.inputmethod.Korean.GongjinCheong",   // Gong-jin Cheong
        "org.youknowone.inputmethod.Gureum",            // Gureum input method
        "org.youknowone.inputmethod.Gureum.han2",       // Gureum 2-set
        "org.youknowone.inputmethod.Gureum.han3",       // Gureum 3-set
    ]

    // MARK: - Initialization

    init() {
        setupObservers()
    }

    deinit {
        removeObservers()
    }

    // MARK: - Public Methods

    /// Returns true if a Korean/Hangul input source is currently active
    func isHangulInputActive() -> Bool {
        guard let inputSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return false
        }

        guard let inputSourceID = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else {
            return false
        }

        let sourceID = Unmanaged<CFString>.fromOpaque(inputSourceID).takeUnretainedValue() as String

        // Check if it's a known Hangul input source
        if hangulInputSources.contains(sourceID) {
            return true
        }

        // Also check for any input source containing "Korean" or "Hangul"
        let lowercased = sourceID.lowercased()
        return lowercased.contains("korean") || lowercased.contains("hangul")
    }

    /// Returns the current input source identifier
    func currentInputSourceID() -> String? {
        guard let inputSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }

        guard let inputSourceID = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else {
            return nil
        }

        return Unmanaged<CFString>.fromOpaque(inputSourceID).takeUnretainedValue() as String
    }

    /// Returns the current input source localized name
    func currentInputSourceName() -> String? {
        guard let inputSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }

        guard let namePtr = TISGetInputSourceProperty(inputSource, kTISPropertyLocalizedName) else {
            return nil
        }

        return Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String
    }

    /// Track a new key press during composition
    func addToComposition(keyCode: UInt16) {
        currentComposition.append(keyCode)
        onCompositionChanged?(compositionDescription())
    }

    /// Clear the current composition
    func clearComposition() {
        currentComposition.removeAll()
        onCompositionChanged?(nil)
    }

    /// Check if currently composing
    func isComposing() -> Bool {
        return !currentComposition.isEmpty
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Observe input source changes
        inputSourceObserver = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name(kTISNotifySelectedKeyboardInputSourceChanged as String),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleInputSourceChange()
        }
    }

    private func removeObservers() {
        if let observer = inputSourceObserver {
            DistributedNotificationCenter.default().removeObserver(observer)
            inputSourceObserver = nil
        }
    }

    private func handleInputSourceChange() {
        // Clear any ongoing composition when input source changes
        clearComposition()

        // Notify listener
        let isHangul = isHangulInputActive()
        onInputSourceChanged?(isHangul)
    }

    private func compositionDescription() -> String? {
        guard !currentComposition.isEmpty else {
            return nil
        }
        return "Composing: \(currentComposition.count) jamo"
    }
}
