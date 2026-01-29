# terminalHangul 개발 에이전트 팀

## 팀 개요

| 항목 | 내용 |
|------|------|
| **팀명** | terminalHangul Development Team |
| **목적** | macOS 터미널 한글 입력 문제 해결 유틸리티 개발 |
| **상태** | v1.0 완료 |
| **생성일** | 2025-01-29 |

## 프로젝트 요약

### 해결한 문제
macOS 터미널에서 한글 입력 시 Shift+Enter를 두 번 눌러야 줄바꿈이 되는 문제

### 해결 방법
1. CGEvent tap으로 키보드 이벤트 가로채기
2. Shift+Enter 감지 시 Space → Backspace → Shift+Enter 시퀀스 전송
3. Space가 한글 조합을 커밋하고, Backspace가 Space를 제거

### 기술 스택
- Swift 5.7+
- macOS 12+
- CoreGraphics (CGEvent)
- Carbon (TIS Input Source)
- AppKit (Menu Bar App)

---

## 에이전트 구성

### 1. Architect Agent (설계자)
**역할:** 시스템 아키텍처 설계 및 문제 분석

**수행한 작업:**
- 문제 정의 및 해결 전략 수립
- 컴포넌트 구조 설계 (5개 Core 모듈)
- 이벤트 흐름 설계
- 디버깅 전략 수립

**산출물:**
- 아키텍처 다이어그램
- 컴포넌트 책임 정의

---

### 2. Executor Agent (구현자)
**역할:** 코드 구현 및 수정

**수행한 작업:**
- Package.swift 설정
- 5개 Core 컴포넌트 구현:
  - `EventInterceptor.swift` - CGEvent tap 관리
  - `CompositionTracker.swift` - 한글 IME 상태 추적
  - `AppContextDetector.swift` - 터미널 앱 감지
  - `KeyEventSynthesizer.swift` - 키 이벤트 합성
  - `DecisionEngine.swift` - 로직 조율
- AppDelegate.swift 메뉴바 앱 구현
- 버그 수정 및 로직 개선

**구현 이력:**
1. 초기 구현: 매 자모 입력 후 Right Arrow 전송 → 실패 (조합 깨짐)
2. 2차 시도: Enter 전에 Shift 키 전송 → 실패 (Gureum IME 무시)
3. 3차 시도: Enter 후 추가 Enter 전송 → 실패 (타이밍 문제)
4. **최종 해결:** Shift+Enter 가로채기 → Space+Backspace+Shift+Enter

---

### 3. Explorer Agent (탐색자)
**역할:** 코드베이스 탐색 및 디버깅

**수행한 작업:**
- 기존 코드 구조 분석
- 디버그 로그 분석
- 이벤트 타입 확인 (type: 10=keyDown, 11=keyUp, 12=flagsChanged)
- 키코드 매핑 확인

---

### 4. Build-Fixer Agent (빌드 수정자)
**역할:** 빌드 오류 해결

**수행한 작업:**
- `private` → `fileprivate` 접근 제어자 수정
- 미사용 반환값 경고 해결

---

## 파일 구조

```
terminalHangul/
├── Package.swift
├── Sources/terminalHangul/
│   ├── main.swift
│   ├── AppDelegate.swift
│   ├── Core/
│   │   ├── EventInterceptor.swift
│   │   ├── CompositionTracker.swift
│   │   ├── AppContextDetector.swift
│   │   ├── KeyEventSynthesizer.swift
│   │   └── DecisionEngine.swift
│   └── Utils/
│       ├── KeyCodes.swift
│       └── Permissions.swift
└── agents/
    ├── dev-team/
    └── biz-team/
```

---

## 지원 터미널

- Terminal.app (com.apple.Terminal)
- iTerm2 (com.googlecode.iterm2)
- Alacritty (org.alacritty)
- Kitty (net.kovidgoyal.kitty)
- Hyper (co.zeit.hyper)
- Warp (dev.warp.Warp-Stable)
- WezTerm (org.wezfurlong.wezterm)

---

## 지원 한글 입력기

- macOS 기본 한글 (2벌식, 3벌식)
- Gureum 입력기

---

## 향후 개선 사항

- [ ] 일반 Enter 키도 같은 방식으로 처리 (옵션)
- [ ] 조합 중인 글자를 보여주는 오버레이 창
- [ ] 시스템 시작 시 자동 실행 옵션
- [ ] 설정 UI (지원 앱 커스터마이징)
- [ ] Homebrew 배포

---

## 팀 연락처

이 프로젝트는 Claude Code와 협업하여 개발되었습니다.
