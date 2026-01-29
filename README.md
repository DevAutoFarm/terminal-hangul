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

## 설치

```bash
git clone https://github.com/DevAutoFarm/terminal-hangul.git
cd terminal-hangul
swift build -c release
```

---

## 실행

### 1. 앱 시작
```bash
swift run
```
> 메뉴바에 **"한"** 아이콘이 나타납니다.

### 2. 권한 허용
첫 실행 시 **입력 모니터링 권한**을 요청합니다.
- `시스템 설정` → `개인정보 보호 및 보안` → `입력 모니터링`
- **terminalHangul** 체크 ✓

### 3. 활성화
메뉴바 **"한"** 클릭 → **"▶️ Enable terminalHangul"** 선택

### 4. 완료!
터미널에서 한글 입력 후 **Shift+Enter 한 번**으로 줄바꿈!

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
