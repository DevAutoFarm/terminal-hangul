import Foundation

/// 한글 조합 결과
enum CompositionResult {
    /// 조합 중 (마킹 텍스트로 표시)
    case composing(String)
    /// 확정 문자 + 새 조합 시작
    case committed(committed: String, composing: String?)
    /// 한글 입력이 아님 - 시스템에 전달
    case passthrough
}

/// 한글 조합 상태
private enum CompositionState {
    case empty                              // 아무것도 없음
    case choseongOnly(Int)                  // 초성만 (예: ㄱ)
    case choseongJungseong(Int, Int)        // 초성+중성 (예: 가)
    case complete(Int, Int, Int)            // 초성+중성+종성 (예: 각)
}

/// 두벌식 한글 조합기
final class HangulComposer {

    // MARK: - Properties

    private var state: CompositionState = .empty

    /// 현재 조합 중인 문자가 있는지
    var hasComposition: Bool {
        switch state {
        case .empty:
            return false
        default:
            return true
        }
    }

    /// 현재 조합 중인 문자열 (마킹 텍스트용)
    var composingText: String {
        return composeCurrentState() ?? ""
    }

    // MARK: - Public Methods

    /// 키 입력 처리
    /// - Parameter key: QWERTY 키보드 문자
    /// - Returns: 조합 결과
    func process(key: Character) -> CompositionResult {
        // QWERTY 키를 자모로 변환
        guard let jamo = JamoTable.qwertyToJamo[key] else {
            // 한글 키가 아니면 현재 조합 확정 후 passthrough
            if hasComposition {
                let committed = finishComposition()
                return .committed(committed: committed, composing: nil)
            }
            return .passthrough
        }

        // 자모 처리
        if JamoTable.isConsonant(jamo) {
            return processConsonant(jamo)
        } else {
            return processVowel(jamo)
        }
    }

    /// 조합 완료 (확정)
    /// - Returns: 확정된 문자열 (없으면 빈 문자열)
    func finishComposition() -> String {
        let result = composeCurrentState() ?? ""
        state = .empty
        return result
    }

    /// 조합 취소 (백스페이스 처리)
    /// - Returns: 취소 후 남은 조합 문자열 (완전히 취소되면 nil)
    func deleteBackward() -> String? {
        switch state {
        case .empty:
            return nil

        case .choseongOnly:
            state = .empty
            return nil

        case .choseongJungseong(let cho, let jung):
            // 복합 모음인지 확인
            if let (base, _) = findBaseVowel(jung) {
                // 복합 모음 -> 기본 모음으로 (예: ㅘ -> ㅗ)
                state = .choseongJungseong(cho, base)
                return composeCurrentState()
            } else {
                // 단일 모음 -> 초성만
                state = .choseongOnly(cho)
                return composeCurrentState()
            }

        case .complete(let cho, let jung, let jong):
            // 복합 종성인지 확인
            if let (remaining, _) = JamoTable.splitJongseong(jong) {
                // 복합 종성 -> 단일 종성으로 (예: ㄳ -> ㄱ)
                state = .complete(cho, jung, remaining)
                return composeCurrentState()
            } else {
                // 단일 종성 -> 초성+중성만
                state = .choseongJungseong(cho, jung)
                return composeCurrentState()
            }
        }
    }

    /// 상태 초기화
    func reset() {
        state = .empty
    }

    // MARK: - Private Methods - Consonant Processing

    private func processConsonant(_ jamo: Character) -> CompositionResult {
        switch state {
        case .empty:
            // 빈 상태 -> 초성 입력
            if let choIndex = JamoTable.jamoToChoseongIndex[jamo] {
                state = .choseongOnly(choIndex)
                return .composing(composeCurrentState()!)
            }
            // 초성이 될 수 없는 자음 (없어야 하지만 안전장치)
            return .committed(committed: String(jamo), composing: nil)

        case .choseongOnly(let cho):
            // 초성만 있는 상태에서 또 자음
            // 쌍자음 처리: ㄱ + ㄱ = ㄲ 등
            if let doubleChoseong = tryMakeDoubleChoseong(current: cho, adding: jamo) {
                state = .choseongOnly(doubleChoseong)
                return .composing(composeCurrentState()!)
            }
            // 쌍자음이 안 되면 기존 자음 확정 + 새 초성
            let committed = composeCurrentState()!
            if let newCho = JamoTable.jamoToChoseongIndex[jamo] {
                state = .choseongOnly(newCho)
                return .committed(committed: committed, composing: composeCurrentState())
            }
            state = .empty
            return .committed(committed: committed + String(jamo), composing: nil)

        case .choseongJungseong(let cho, let jung):
            // 초성+중성 상태에서 자음 -> 종성 추가
            if let jongIndex = JamoTable.jamoToJongseongIndex[jamo] {
                state = .complete(cho, jung, jongIndex)
                return .composing(composeCurrentState()!)
            }
            // 종성이 될 수 없는 자음은 없지만, 안전장치
            let committed = composeCurrentState()!
            if let newCho = JamoTable.jamoToChoseongIndex[jamo] {
                state = .choseongOnly(newCho)
                return .committed(committed: committed, composing: composeCurrentState())
            }
            state = .empty
            return .committed(committed: committed + String(jamo), composing: nil)

        case .complete(let cho, let jung, let jong):
            // 완전한 글자 상태에서 자음
            // 1. 복합 종성 가능한지 확인
            if let compoundJong = JamoTable.canCombineJongseong(current: jong, adding: jamo) {
                state = .complete(cho, jung, compoundJong)
                return .composing(composeCurrentState()!)
            }
            // 2. 복합 종성 불가능 -> 현재 글자 확정 + 새 초성
            let committed = composeCurrentState()!
            if let newCho = JamoTable.jamoToChoseongIndex[jamo] {
                state = .choseongOnly(newCho)
                return .committed(committed: committed, composing: composeCurrentState())
            }
            state = .empty
            return .committed(committed: committed + String(jamo), composing: nil)
        }
    }

    // MARK: - Private Methods - Vowel Processing

    private func processVowel(_ jamo: Character) -> CompositionResult {
        guard let jungIndex = JamoTable.jamoToJungseongIndex[jamo] else {
            // 중성이 될 수 없는 모음 (없어야 하지만 안전장치)
            if hasComposition {
                let committed = finishComposition()
                return .committed(committed: committed + String(jamo), composing: nil)
            }
            return .committed(committed: String(jamo), composing: nil)
        }

        switch state {
        case .empty:
            // 빈 상태에서 모음 -> 초성 없이 모음만 표시
            // 실제로는 초성 ㅇ(11)을 사용하지 않고 독립 모음으로 처리
            // 여기서는 독립 모음 출력
            let vowelChar = JamoTable.jungseongIndexToJamo[jungIndex]!
            return .committed(committed: String(vowelChar), composing: nil)

        case .choseongOnly(let cho):
            // 초성만 있을 때 모음 -> 초성+중성
            state = .choseongJungseong(cho, jungIndex)
            return .composing(composeCurrentState()!)

        case .choseongJungseong(let cho, let jung):
            // 초성+중성 있을 때 모음 -> 복합 모음 시도
            if let compound = JamoTable.canCombineVowels(first: jung, second: jungIndex) {
                state = .choseongJungseong(cho, compound)
                return .composing(composeCurrentState()!)
            }
            // 복합 모음 불가 -> 현재 글자 확정 + 새 모음
            let committed = composeCurrentState()!
            let vowelChar = JamoTable.jungseongIndexToJamo[jungIndex]!
            state = .empty
            return .committed(committed: committed + String(vowelChar), composing: nil)

        case .complete(let cho, let jung, let jong):
            // 완전한 글자에서 모음 -> 종성을 분리하여 다음 글자의 초성으로
            // 복합 종성이면 분리
            if let (remaining, nextJamo) = JamoTable.splitJongseong(jong),
               let nextCho = JamoTable.jamoToChoseongIndex[nextJamo] {
                // 복합 종성 분리: 앞 자음은 현재 글자에 남고, 뒤 자음이 다음 초성으로
                let committed = composeHangul(cho: cho, jung: jung, jong: remaining)
                state = .choseongJungseong(nextCho, jungIndex)
                return .committed(committed: committed, composing: composeCurrentState())
            }
            // 단일 종성 -> 종성이 다음 글자 초성으로
            if let nextCho = JamoTable.jongseongToChoseongIndex(jong) {
                let committed = composeHangul(cho: cho, jung: jung, jong: 0)
                state = .choseongJungseong(nextCho, jungIndex)
                return .committed(committed: committed, composing: composeCurrentState())
            }
            // 변환 불가한 종성 (이론상 없어야 함)
            let committed = composeCurrentState()!
            let vowelChar = JamoTable.jungseongIndexToJamo[jungIndex]!
            state = .empty
            return .committed(committed: committed + String(vowelChar), composing: nil)
        }
    }

    // MARK: - Private Methods - Utilities

    /// 현재 상태를 완성형 한글 문자열로 조합
    private func composeCurrentState() -> String? {
        switch state {
        case .empty:
            return nil

        case .choseongOnly(let cho):
            // 초성만 있을 때 -> 호환 자모로 표시
            if let jamo = JamoTable.choseongIndexToJamo[cho] {
                return String(jamo)
            }
            return nil

        case .choseongJungseong(let cho, let jung):
            return composeHangul(cho: cho, jung: jung, jong: 0)

        case .complete(let cho, let jung, let jong):
            return composeHangul(cho: cho, jung: jung, jong: jong)
        }
    }

    /// Unicode 조합 공식으로 완성형 한글 생성
    /// 공식: 0xAC00 + (초성 * 21 * 28) + (중성 * 28) + 종성
    private func composeHangul(cho: Int, jung: Int, jong: Int) -> String {
        let code = 0xAC00 + (cho * 21 * 28) + (jung * 28) + jong
        guard let scalar = Unicode.Scalar(code) else {
            return ""
        }
        return String(Character(scalar))
    }

    /// 쌍자음 생성 시도 (예: ㄱ+ㄱ=ㄲ)
    private func tryMakeDoubleChoseong(current: Int, adding: Character) -> Int? {
        guard let addingIndex = JamoTable.jamoToChoseongIndex[adding] else {
            return nil
        }
        // 같은 자음이면 쌍자음 체크
        // ㄱ(0)->ㄲ(1), ㄷ(3)->ㄸ(4), ㅂ(7)->ㅃ(8), ㅅ(9)->ㅆ(10), ㅈ(12)->ㅉ(13)
        switch (current, addingIndex) {
        case (0, 0): return 1   // ㄱ+ㄱ = ㄲ
        case (3, 3): return 4   // ㄷ+ㄷ = ㄸ
        case (7, 7): return 8   // ㅂ+ㅂ = ㅃ
        case (9, 9): return 10  // ㅅ+ㅅ = ㅆ
        case (12, 12): return 13 // ㅈ+ㅈ = ㅉ
        default: return nil
        }
    }

    /// 복합 모음의 기본 모음 찾기 (역변환용)
    private func findBaseVowel(_ compound: Int) -> (base: Int, added: Int)? {
        for (base, additions) in JamoTable.compoundVowels {
            for (added, result) in additions {
                if result == compound {
                    return (base, added)
                }
            }
        }
        return nil
    }
}
