# terminalHangul

[![macOS](https://img.shields.io/badge/macOS-12.0+-blue)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.7+-orange)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Support-Buy%20me%20a%20coffee-FFDD00)](https://buymeacoffee.com/devautofarm)

macOS 터미널에서 한글 입력 후 **Shift+Enter를 두 번** 눌러야 하는 문제를 해결합니다.

---

## 문제

터미널에서 한글 입력 후 Shift+Enter로 줄바꿈 시:
- ❌ **기존**: Shift+Enter 두 번 필요 (첫 번째는 조합 완료, 두 번째가 줄바꿈)
- ✅ **해결**: Shift+Enter **한 번**으로 줄바꿈

---

## 다운로드

<p align="center">
  <a href="https://github.com/DevAutoFarm/terminal-hangul/releases/latest">
    <img src="https://img.shields.io/badge/Download-DMG-blue?style=for-the-badge&logo=apple" alt="Download DMG">
  </a>
</p>

### 설치 방법

1. 위 버튼 클릭 → **TerminalHangul-vX.X.X.dmg** 다운로드
2. DMG 파일 열기
3. **TerminalHangul.app**을 **Applications** 폴더로 드래그
4. Applications에서 앱 실행

> ⚠️ 처음 실행 시 "확인되지 않은 개발자" 경고가 뜰 수 있습니다.
> **우클릭 → 열기**를 선택하세요.

### 권한 설정

첫 실행 시 **입력 모니터링 권한**이 필요합니다:
- `시스템 설정` → `개인정보 보호 및 보안` → `입력 모니터링`
- **TerminalHangul** 체크 ✓

### 사용법

1. 메뉴바 **"한"** 클릭 → **"▶️ Enable terminalHangul"** 선택
2. 터미널에서 한글 입력 후 **Shift+Enter 한 번**으로 줄바꿈!

---

<details>
<summary><b>개발자용: 소스에서 빌드</b></summary>

```bash
git clone https://github.com/DevAutoFarm/terminal-hangul.git
cd terminal-hangul
swift build -c release
swift run
```

</details>

---

## 지원 환경

**터미널**: Terminal.app, iTerm2, Warp, Kitty, Alacritty, Hyper, WezTerm

**입력기**: macOS 기본 한글, Gureum

---

## Support

이 프로젝트가 도움이 되셨다면 ☕

<p align="center">
  <a href="https://buymeacoffee.com/devautofarm">
    <img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee">
  </a>
</p>

---

## License

[MIT](LICENSE)
