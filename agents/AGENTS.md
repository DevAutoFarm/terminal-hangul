# terminalHangul 에이전트 팀 구조

## 개요

이 프로젝트는 2개의 에이전트 팀으로 운영됩니다.

```
agents/
├── AGENTS.md (이 파일)
├── dev-team/          # 개발 에이전트 팀
│   └── TEAM.md
└── biz-team/          # 수익화/경영 에이전트 팀
    └── TEAM.md
```

---

## 팀 1: 개발 에이전트 팀 (Dev Team)

**목적:** terminalHangul 앱 개발 및 유지보수

| 에이전트 | 역할 | 상태 |
|----------|------|------|
| Architect | 시스템 설계, 문제 분석 | ✅ 완료 |
| Executor | 코드 구현 | ✅ 완료 |
| Explorer | 코드 탐색, 디버깅 | ✅ 완료 |
| Build-Fixer | 빌드 오류 해결 | ✅ 완료 |

**성과:**
- v1.0 릴리즈 완료
- Shift+Enter 한글 조합 문제 해결
- 7개 터미널 앱 지원

👉 자세한 내용: [dev-team/TEAM.md](./dev-team/TEAM.md)

---

## 팀 2: 수익화/경영 에이전트 팀 (Biz Team)

**목적:** 배포, 홍보, 수익화 전략 실행

| 에이전트 | 역할 | 상태 |
|----------|------|------|
| Marketing | 홍보, 커뮤니티 마케팅 | 🔜 대기 |
| Distribution | 배포 채널 관리 | 🔜 대기 |
| Monetization | 기부/수익 채널 구축 | 🔜 대기 |
| Community | 사용자 피드백, 이슈 관리 | 🔜 대기 |
| Analytics | 성과 측정 | 🔜 대기 |

**다음 단계:**
1. README.md 작성
2. 기부 플랫폼 설정
3. GitHub Release 생성
4. 커뮤니티 홍보

👉 자세한 내용: [biz-team/TEAM.md](./biz-team/TEAM.md)

---

## 팀 간 협업

```
┌─────────────────┐     ┌─────────────────┐
│   Dev Team      │────▶│   Biz Team      │
│                 │     │                 │
│ • 기능 개발      │     │ • README 작성   │
│ • 버그 수정      │     │ • 배포          │
│ • 성능 개선      │     │ • 홍보          │
│                 │     │ • 수익화        │
└─────────────────┘     └─────────────────┘
        │                       │
        │    피드백 루프         │
        └───────────────────────┘
```

**협업 프로세스:**
1. Dev Team이 새 버전 완성
2. Biz Team이 Release 생성 및 배포
3. Community Agent가 피드백 수집
4. Dev Team이 피드백 반영하여 개선
5. 반복

---

## 현재 프로젝트 상태

| 항목 | 상태 |
|------|------|
| 코드 | ✅ v1.0 완료 |
| 테스트 | ✅ 수동 테스트 통과 |
| README | ❌ 미작성 |
| 라이선스 | ❌ 미추가 |
| GitHub Release | ❌ 미생성 |
| Homebrew | ❌ 미등록 |
| 기부 설정 | ❌ 미설정 |
| 홍보 | ❌ 미시작 |

---

## 빠른 시작

### 개발 작업
```bash
cd agents/dev-team
cat TEAM.md
```

### 비즈니스 작업
```bash
cd agents/biz-team
cat TEAM.md
```
