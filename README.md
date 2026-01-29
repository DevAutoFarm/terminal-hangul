# terminalHangul

![macOS](https://img.shields.io/badge/macOS-12%2B-blue?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-5.7%2B-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20me%20a%20coffee-%23FFDD00?style=flat-square)](https://buymeacoffee.com/devautofarm)

> macOS 터미널에서 한글 입력 시 자동으로 조합을 완성시켜주는 메뉴바 애플리케이션

## 🌍 Language

[English](#english-version) | [한국어](#한국어-버전)

---

## 한국어 버전

### 문제 상황

macOS 터미널에서 한글을 입력할 때, 특수 키(Space, Enter, Tab, Ctrl+C 등)를 누르면 다음과 같은 불편함이 발생합니다:

```
사용자: "안녕" 입력 후 Enter
문제: 한글 조합이 완료되지 않아 "Shift+Enter"를 두 번 눌러야 함
결과: 😞 생산성 저하
```

이는 다음 모든 터미널에서 발생합니다:
- Terminal.app, iTerm2, Alacritty, Kitty, Hyper, Warp, WezTerm

### 해결책: terminalHangul

terminalHangul은 시스템 레벨의 키보드 이벤트 감시를 통해 이 문제를 **자동으로 해결**합니다.

#### 작동 원리

```
[사용자 키 입력]
       ↓
[CGEventTap으로 모든 키 감시]
       ↓
[터미널이 활성? + 한글 입력? 확인]
       ↓
[특수 키 감지 → 한글 조합 상태 분석]
       ↓
[필요 시 우측 화살표 키 자동 전송]
       ↓
[한글 조합 자동 완성! + 원래 키 처리]
```

**결과**: "안녕" + Enter = 완료! ✅

---

## 🚀 빠른 시작

### 요구사항

- **macOS 12.0** 이상
- **Swift 5.7** 이상 (Xcode에 포함됨)

### 설치 및 실행

#### 1. 소스 빌드

```bash
# 저장소 클론
git clone https://github.com/your-org/terminalHangul.git
cd terminalHangul

# 릴리스 버전으로 빌드
swift build -c release

# 실행 파일 위치
.build/release/terminalHangul
```

#### 2. 직접 실행

```bash
# 개발 모드로 실행 (즉시 테스트)
swift run
```

### 사용 방법

#### 1단계: 권한 설정

앱을 처음 실행하면 **Input Monitoring** 권한을 요청합니다.

```
📋 시스템 대화상자 표시:
  "terminalHangul needs Input Monitoring permission..."
  → [Open System Preferences] 클릭
```

또는 수동 설정:
```
시스템 설정 → 보안 및 개인 정보
  → 입력 모니터링 → terminalHangul 추가
```

#### 2단계: 활성화

메뉴바에서 "한" 아이콘을 클릭하고 **Enable terminalHangul** 선택:

```
메뉴바: [한] → Enable terminalHangul
        ↓
메뉴바: [한✓] (활성화됨)
```

#### 3단계: 사용

터미널을 열고 한글을 입력하세요:

```bash
# 터미널에 한글 입력
입력: "안녕하세요"
키 입력: Enter

# 결과
출력: 안녕하세요 (자동 조합 완성!)
```

---

## 📋 지원 목록

### 지원 터미널

✅ Terminal.app (기본 터미널)
✅ iTerm2
✅ WezTerm
✅ Kitty
✅ Alacritty
✅ Hyper
✅ Warp Terminal
✅ Tabby Terminal
✅ Rio Terminal
✅ Wave Terminal

### 지원 입력기

✅ macOS 기본 한글 입력기 (두벌식, 세벌식)
✅ 구름입력기 (Gureum)
✅ 기타 한글 입력 소스

### 처리하는 키

| 카테고리 | 키 |
|---------|-----|
| **일반 특수 키** | Enter, Space, Tab, ESC, Delete, Forward Delete |
| **터미널 제어** | Ctrl+C, Ctrl+D, Ctrl+Z, Ctrl+L, Ctrl+A, Ctrl+E |
| **명령어** | Ctrl+K, Ctrl+U, Ctrl+W, Ctrl+R, Ctrl+P, Ctrl+N |
| **네비게이션** | ↑, ↓, ←, → |
| **특수** | Shift+Enter (다중 라인 프롬프트) |

---

## 🏗️ 아키텍처

### 프로젝트 구조

```
terminalHangul/
├── Package.swift                    # Swift Package 정의
├── README.md                        # 이 파일
│
└── Sources/terminalHangul/
    ├── main.swift                   # 애플리케이션 진입점
    ├── AppDelegate.swift            # 메뉴바 앱 설정
    │
    ├── Core/
    │   ├── EventInterceptor.swift    # ⚙️ CGEventTap 래퍼
    │   │                              # • 시스템 키보드 이벤트 감시
    │   │                              # • 다중 이벤트 타입 처리
    │   │
    │   ├── DecisionEngine.swift      # 🧠 핵심 결정 로직
    │   │                              # • 이벤트 분석
    │   │                              # • 터미널 + 한글 조건 확인
    │   │                              # • 조합 완성 시점 판단
    │   │
    │   ├── CompositionTracker.swift  # 📊 한글 조합 상태 추적
    │   │                              # • 한글 자모 키 감지
    │   │                              # • 타임아웃 기반 상태 관리
    │   │                              # • 입력 소스 변경 감지
    │   │
    │   ├── AppContextDetector.swift  # 🔍 터미널/입력기 감지
    │   │                              # • 활성 애플리케이션 확인
    │   │                              # • 입력 소스 ID 매칭
    │   │                              # • 한글 입력기 판별
    │   │
    │   └── KeyEventSynthesizer.swift # ⌨️ 조합 완성 키 생성
    │                                  # • 우측 화살표 키 합성
    │                                  # • 합성 이벤트 추적
    │
    └── Utils/
        ├── KeyCodes.swift            # 🔑 macOS 키 코드 상수
        │                              # • 문자 키 (a-z, 0-9)
        │                              # • 특수 키 (Enter, Space, etc)
        │                              # • 수정자 키 (Cmd, Ctrl, etc)
        │
        └── Permissions.swift         # 🔒 권한 관리
                                       # • Input Monitoring 확인
                                       # • 시스템 환경설정 연동
```

### 핵심 컴포넌트

#### 1️⃣ EventInterceptor
CGEventTap을 사용하여 모든 키보드 이벤트를 감시합니다.

```swift
// 감시하는 이벤트
- .keyDown      // 키 누름
- .keyUp        // 키 떨어짐
- .flagsChanged // 수정자 키 (Cmd, Ctrl 등)
```

#### 2️⃣ DecisionEngine
수신한 이벤트를 분석하고 조합 완성 여부를 결정합니다.

```swift
shouldProcessEvents?
  → 터미널 활성 + 한글 입력기 활성

shouldCommitOnKey?
  → Space, Enter, Tab 등 특수 키 여부

isComposing?
  → 한글 조합 상태 추적
```

#### 3️⃣ CompositionTracker
한글 조합 상태를 시간 기반 휴리스틱으로 추적합니다.

```
타이밍:
- 한글 자모 키 입력 → 조합 시작 표시
- 마지막 입력 + 1초 경과 → 조합 완료로 판정
- 특수 키 입력 → 조합 즉시 완료

결과:
- 조합 중인 한글이 있으면 우측 화살표 전송
- 자동으로 조합 완성
```

#### 4️⃣ AppContextDetector
현재 활성 터미널과 입력 소스를 감지합니다.

```swift
// 터미널 감지
NSWorkspace.shared.frontmostApplication?.bundleIdentifier
// "com.apple.Terminal", "com.iterm2.iterm", 등 매칭

// 입력기 감지
TISCopyCurrentKeyboardInputSource()
// "korean", "hangul", "gureum.gureum-core" 등 패턴 매칭
```

---

## 🔧 기술 스택

| 기술 | 버전 | 용도 |
|------|------|------|
| **Swift** | 5.7+ | 주 개발 언어 |
| **macOS** | 12.0+ | 타겟 운영 체제 |
| **CoreGraphics** | - | CGEventTap (이벤트 감시) |
| **Cocoa** | - | 메뉴바 앱 UI |
| **Carbon** | - | 입력 소스 감지 (TIS) |

---

## ⚠️ 알려진 제한사항

1. **휴리스틱 기반 감지**: 한글 조합 상태 감지는 100% 정확하지 않을 수 있습니다
   - 타임아웃 기반이므로 매우 빠른 입력에서 오진 가능

2. **시스템 권한 필수**: Input Monitoring 권한이 반드시 필요합니다
   - 시스템 보안 때문에 필수적임

3. **지원 터미널 제한**: 등록되지 않은 터미널은 작동하지 않습니다
   - 새로운 터미널 추가 시 코드 수정 필요

4. **호환성 문제**: 다른 키보드 이벤트 인터셉터와 충돌 가능
   - Alfred, Karabiner 등 다른 도구와 상충 가능

5. **성능 오버헤드**: 전역 키보드 이벤트 감시로 약간의 오버헤드 발생
   - 일반적으로 무시할 수 있는 수준

---

## 🐛 문제 해결

### 권한 요청이 표시되지 않음

**해결책**:
```bash
# 1. 수동으로 시스템 설정 확인
시스템 설정 → 보안 및 개인 정보 → 입력 모니터링

# 2. 목록에 없으면 "+" 클릭하여 terminalHangul 추가

# 3. Mac 재부팅
```

### 앱이 실행되지 않음

**해결책**:
```bash
# 1. 터미널에서 직접 실행하여 에러 확인
swift run

# 2. 권한 확인
# 시스템 설정에서 terminalHangul의 권한 확인

# 3. 재빌드
swift build -c release
```

### 한글 조합이 완성되지 않음

**체크리스트**:
- ✅ 메뉴바에서 "한✓" 표시 확인 (활성화 상태)
- ✅ 터미널이 지원 목록에 있는지 확인
- ✅ 한글 입력기 활성화 확인 (Command+Space)
- ✅ 다시 시도 (타임아웃 기반이므로 1초 이상 필요)

### 특정 터미널/입력기에서 작동하지 않음

**해결책**:
```swift
// 1. AppContextDetector.swift 확인
// isTerminalActive() 함수에서 터미널 번들 ID 매칭

// 2. 새 터미널 추가
private let supportedTerminals = [
    "com.apple.Terminal",
    "com.iterm2.iterm",
    "com.your.newterminal"  // ← 추가
]

// 3. 입력기 ID 확인 (필요 시)
TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID)
```

---

## 📝 개발 가이드

### 빌드

```bash
# 개발 버전 (디버그 심볼 포함)
swift build

# 릴리스 버전 (최적화됨)
swift build -c release

# 출력 위치
.build/debug/terminalHangul
.build/release/terminalHangul
```

### 실행

```bash
# 개발 버전 실행
swift run terminalHangul

# 직접 실행
.build/debug/terminalHangul &
```

### 디버깅

```swift
// DecisionEngine 클래스에서 디버그 로그 활성화
decisionEngine.debugEnabled = true

// 그러면 다음 메시지가 출력됨:
// [DecisionEngine] Event received - type: 10, keyCode: 36
// [DecisionEngine] Hangul input active: true
// [DecisionEngine] Key down: 36 (Return)
```

### 새 터미널 추가

```swift
// 1. 터미널의 번들 ID 확인
// Terminal.app 예: com.apple.Terminal

// 2. AppContextDetector.swift 수정
private let supportedTerminals = [
    "com.apple.Terminal",
    "com.iterm2.iterm",
    // ... 기존 항목들 ...
    "com.my.newterminal"  // ← 추가
]

// 3. 빌드 및 테스트
swift build -c release
```

---

## 🚦 상태 및 로드맵

### ✅ 완료됨

- ✅ CGEventTap 기반 이벤트 감시
- ✅ 터미널 자동 감지
- ✅ 한글 입력기 감지
- ✅ 메뉴바 토글
- ✅ 권한 관리

### 🚧 진행 중

- 🚧 설정 창 (UI)
- 🚧 로깅 및 모니터링
- 🚧 성능 최적화

### 📋 계획 중

- 📋 앱별 활성화/비활성화
- 📋 자동 실행 옵션
- 📋 메뉴바 아이콘 개선
- 📋 Homebrew 배포
- 📋 테스트 슈트 작성

---

## 🤝 기여 방법

버그 리포트, 기능 제안, PR을 환영합니다!

### 이슈 제출

```
1. GitHub Issues 페이지 방문
2. 자세한 설명과 함께 이슈 작성
3. 지원 정보:
   - macOS 버전
   - 사용 중인 터미널
   - 재현 단계
```

### PR 제출

```bash
# 1. Fork 및 클론
git clone https://github.com/your-fork/terminalHangul.git

# 2. 기능 브랜치 생성
git checkout -b feature/your-feature

# 3. 커밋
git commit -am 'Add your feature'

# 4. Push
git push origin feature/your-feature

# 5. Pull Request 작성
```

### 코드 스타일

- Swift: 기본 스타일 (4칸 들여쓰기)
- 함수: 명확한 이름과 주석
- 에러 처리: guard와 nil-coalescing 활용

---

## 📜 라이선스

MIT License - [LICENSE](LICENSE) 파일 참조

```
Copyright (c) 2024 terminalHangul Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

---

## ☕ 지원

이 프로젝트가 도움이 되었다면 커피 한 잔으로 후원해주세요!

[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20me%20a%20coffee-%23FFDD00?style=for-the-badge)](https://buymeacoffee.com/devautofarm)

---

## 📚 참고 자료

### macOS 개발

- [Apple CoreGraphics Documentation](https://developer.apple.com/documentation/coregraphics/)
- [CGEventTap Reference](https://developer.apple.com/documentation/coregraphics/1572097-virtual_key_codes)
- [Cocoa Event Handling](https://developer.apple.com/documentation/appkit/event_handling)
- [Text Input Source (Carbon)](https://developer.apple.com/documentation/carbon/text_input_source_management)

### 한글 처리

- [macOS 기본 한글 입력기](https://support.apple.com/ko-KR/HT201215)
- [Gureum 입력기 GitHub](https://github.com/gureum/gureum)
- [Unicode 한글 정규화](http://www.unicode.org/reports/tr15/)

---

## 🙏 크레딧

한글을 사용하는 터미널 사용자들의 불편함을 해결하기 위해 개발되었습니다.

**감사의 말씀**:
- macOS 커뮤니티의 피드백
- CoreGraphics와 Cocoa 프레임워크 팀
- 한글 입력 메커니즘 분석에 도움을 준 개발자들

---

## 📧 문의

문제가 있거나 질문이 있으신가요?

1. **FAQ**: README의 "문제 해결" 섹션 참고
2. **Issues**: GitHub Issues 페이지에서 검색
3. **토론**: GitHub Discussions에서 질문 (준비 중)

---

<br>

# English Version

> Automatically completes Hangul (Korean) composition when typing in macOS terminal

### The Problem

When typing Korean in macOS terminal, incomplete Hangul composition causes issues with special keys:

```
User: Type "안녕" (annyeong) + press Enter
Problem: Hangul not composed → must press Shift+Enter twice
Result: 😞 Frustrating!
```

Affects all these terminals:
- Terminal.app, iTerm2, Alacritty, Kitty, Hyper, Warp, WezTerm

### The Solution: terminalHangul

terminalHangul automatically completes Hangul composition by monitoring system keyboard events.

```
[User types Korean]
       ↓
[CGEventTap monitors all keys]
       ↓
[Check: Terminal active? + Korean input?]
       ↓
[Detect special key → analyze Hangul state]
       ↓
[If needed: send Right Arrow key automatically]
       ↓
[Hangul auto-completed! + original key processed]
```

**Result**: "안녕" + Enter = Done! ✅

---

## Quick Start

### Requirements

- **macOS 12.0** or later
- **Swift 5.7** or later (included in Xcode)

### Installation

```bash
# Clone repository
git clone https://github.com/your-org/terminalHangul.git
cd terminalHangul

# Build release version
swift build -c release

# Run
.build/release/terminalHangul
```

### Setup

1. **Grant Permission**: Click "Open System Preferences" when prompted
2. **Enable**: Click "한" in menu bar → "Enable terminalHangul"
3. **Use**: Type Korean in terminal - it just works!

---

## Supported Terminals

✅ Terminal.app | ✅ iTerm2 | ✅ WezTerm | ✅ Kitty | ✅ Alacritty | ✅ Hyper | ✅ Warp | ✅ And more...

## Supported Input Methods

✅ macOS built-in Korean (Dubeolsik, Sebeolsik) | ✅ Gureum | ✅ Other Korean inputs

---

## License

MIT - See [LICENSE](LICENSE)

---

**Made with ❤️ for Korean terminal users**
