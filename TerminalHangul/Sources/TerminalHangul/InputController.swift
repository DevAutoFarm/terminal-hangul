import Cocoa
import InputMethodKit

/// 한글 입력 컨트롤러
/// @objc 어노테이션과 클래스 이름이 Info.plist의 InputMethodServerControllerClass와 일치해야 함
@objc(InputController)
class InputController: IMKInputController {

    // MARK: - Properties

    private let composer = HangulComposer()
    private var currentClient: (any IMKTextInput)?

    // MARK: - Special Key Detection

    /// 특수 키인지 확인 (조합을 완료하고 시스템에 전달해야 하는 키들)
    private func isSpecialKey(_ event: NSEvent) -> Bool {
        let keyCode = event.keyCode
        let modifiers = event.modifierFlags

        // Enter/Return
        if keyCode == 36 || keyCode == 76 {
            return true
        }

        // Tab
        if keyCode == 48 {
            return true
        }

        // Escape
        if keyCode == 53 {
            return true
        }

        // Arrow keys (up, down, left, right)
        if keyCode == 123 || keyCode == 124 || keyCode == 125 || keyCode == 126 {
            return true
        }

        // Function keys (F1-F12)
        if keyCode >= 122 && keyCode <= 111 { // F1-F12 range varies
            return true
        }

        // Control + 키 조합
        if modifiers.contains(.control) {
            return true
        }

        // Command + 키 조합
        if modifiers.contains(.command) {
            return true
        }

        // Option/Alt + 키 조합 (한글 입력에서는 무시하고 시스템에 전달)
        // 단, Option 단독은 한글 특수 문자 입력에 사용될 수 있으므로 여기서는 제외
        // Option + Command 등은 위에서 처리됨

        // Home, End, Page Up, Page Down
        if keyCode == 115 || keyCode == 119 || keyCode == 116 || keyCode == 121 {
            return true
        }

        // Delete (Forward Delete)
        if keyCode == 117 {
            return true
        }

        return false
    }

    // MARK: - Special Key Handling

    /// 특수 키 처리: 조합 완료 후 시스템에 전달
    private func handleSpecialKey(client: any IMKTextInput) -> Bool {
        // 조합 중인 한글이 있으면 먼저 완성
        if composer.hasComposition {
            let committed = composer.finishComposition()
            if !committed.isEmpty {
                client.insertText(committed, replacementRange: NSRange(location: NSNotFound, length: 0))
            }
        }
        // 특수 키는 시스템에 전달 (false 반환)
        return false
    }

    // MARK: - IMKInputController Overrides

    override func activateServer(_ sender: Any!) {
        super.activateServer(sender)
        composer.reset()
        if let client = sender as? (any IMKTextInput) {
            currentClient = client
        }
    }

    override func deactivateServer(_ sender: Any!) {
        // 비활성화 시 조합 완료
        if let client = currentClient, composer.hasComposition {
            let committed = composer.finishComposition()
            if !committed.isEmpty {
                client.insertText(committed, replacementRange: NSRange(location: NSNotFound, length: 0))
            }
        }
        composer.reset()
        currentClient = nil
        super.deactivateServer(sender)
    }

    /// 핵심 키 이벤트 처리
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event = event, event.type == .keyDown else {
            return false
        }

        guard let client = sender as? (any IMKTextInput) else {
            return false
        }

        currentClient = client

        // 특수 키 감지 -> 조합 완료 후 시스템에 전달
        if isSpecialKey(event) {
            return handleSpecialKey(client: client)
        }

        // 백스페이스 처리
        if event.keyCode == 51 {
            return handleBackspace(client: client)
        }

        // 스페이스바 처리
        if event.keyCode == 49 {
            return handleSpace(client: client)
        }

        // 일반 문자 키 처리
        guard let characters = event.characters, let char = characters.first else {
            return false
        }

        // 한글 조합 처리
        let result = composer.process(key: char)

        switch result {
        case .composing(let text):
            // 마킹 텍스트 설정 (조합 중 표시)
            client.setMarkedText(text, selectionRange: NSRange(location: text.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
            return true

        case .committed(let committed, let composing):
            // 마킹 해제 + 확정 텍스트 입력
            client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
            client.insertText(committed, replacementRange: NSRange(location: NSNotFound, length: 0))

            // 새로운 조합이 있으면 마킹 설정
            if let newComposing = composing {
                client.setMarkedText(newComposing, selectionRange: NSRange(location: newComposing.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
            }
            return true

        case .passthrough:
            // 한글 조합과 무관한 키 -> 시스템에 전달
            return false
        }
    }

    // MARK: - Backspace Handling

    private func handleBackspace(client: any IMKTextInput) -> Bool {
        if composer.hasComposition {
            if let remaining = composer.deleteBackward() {
                // 아직 조합 중인 문자가 있음
                client.setMarkedText(remaining, selectionRange: NSRange(location: remaining.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
            } else {
                // 조합이 완전히 취소됨
                client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
            }
            return true
        }
        // 조합 중이 아니면 시스템에 전달 (일반 백스페이스 동작)
        return false
    }

    // MARK: - Space Handling

    private func handleSpace(client: any IMKTextInput) -> Bool {
        if composer.hasComposition {
            // 조합 중이면 조합 완료 + 스페이스 입력
            let committed = composer.finishComposition()
            client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
            client.insertText(committed + " ", replacementRange: NSRange(location: NSNotFound, length: 0))
            return true
        }
        // 조합 중이 아니면 시스템에 전달
        return false
    }

    // MARK: - Composition Session Management

    override func composedString(_ sender: Any!) -> Any! {
        // 확정된 문자열 반환 (보통 비어있음, 확정 시점에 insertText로 처리하므로)
        return ""
    }

    override func originalString(_ sender: Any!) -> NSAttributedString! {
        // 원본 입력 문자열
        return NSAttributedString(string: composer.composingText)
    }

    override func commitComposition(_ sender: Any!) {
        guard let client = sender as? (any IMKTextInput) else { return }

        if composer.hasComposition {
            let committed = composer.finishComposition()
            if !committed.isEmpty {
                client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
                client.insertText(committed, replacementRange: NSRange(location: NSNotFound, length: 0))
            }
        }
    }

    override func cancelComposition() {
        composer.reset()
        if let client = currentClient {
            client.setMarkedText("", selectionRange: NSRange(location: 0, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
        }
    }
}
