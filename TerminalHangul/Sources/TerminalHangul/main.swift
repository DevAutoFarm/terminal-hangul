import Cocoa
import InputMethodKit

/// TerminalHangul Input Method 앱
/// 이 앱은 백그라운드에서 실행되며 입력기로 동작합니다.

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {

    private var server: IMKServer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // IMKServer 생성
        // connectionName은 Info.plist의 InputMethodConnectionName과 일치해야 함
        let connectionName = Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String ?? "TerminalHangul_Connection"
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.terminalhangul.inputmethod"

        // IMKServer 초기화
        server = IMKServer(name: connectionName, bundleIdentifier: bundleIdentifier)

        if server == nil {
            NSLog("TerminalHangul: Failed to create IMKServer with connection name: \(connectionName)")
        } else {
            NSLog("TerminalHangul: IMKServer created successfully")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSLog("TerminalHangul: Application terminating")
    }
}

// MARK: - Main Entry Point

// NSApplication 기반 앱 실행
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 입력기는 activation policy를 prohibited로 설정 (Dock에 표시 안 됨)
app.setActivationPolicy(.prohibited)

// 이벤트 루프 시작
app.run()
