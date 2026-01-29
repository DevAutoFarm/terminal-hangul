#!/bin/bash

# TerminalHangul 빌드 및 설치 스크립트
# macOS InputMethodKit 기반 한글 입력기

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 스크립트 디렉토리
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

echo -e "${BLUE}=== TerminalHangul 빌드 시작 ===${NC}"

# 빌드 디렉토리 설정
BUILD_DIR="$SCRIPT_DIR/.build"
APP_NAME="TerminalHangul"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
INSTALL_DIR="$HOME/Library/Input Methods"

# 기존 빌드 정리
echo -e "${YELLOW}기존 빌드 정리 중...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 소스 파일 수집
SOURCES=(
    "Sources/TerminalHangul/main.swift"
    "Sources/TerminalHangul/InputController.swift"
    "Sources/TerminalHangul/HangulEngine/JamoTable.swift"
    "Sources/TerminalHangul/HangulEngine/HangulComposer.swift"
)

# 모든 소스 파일 존재 확인
echo -e "${YELLOW}소스 파일 확인 중...${NC}"
for src in "${SOURCES[@]}"; do
    if [[ ! -f "$src" ]]; then
        echo -e "${RED}오류: 소스 파일 없음: $src${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}[OK]${NC} $src"
done

# 앱 번들 디렉토리 구조 생성
echo -e "${YELLOW}앱 번들 구조 생성 중...${NC}"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# swiftc로 컴파일
echo -e "${YELLOW}Swift 소스 컴파일 중...${NC}"
swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    -target arm64-apple-macos12.0 \
    -sdk $(xcrun --show-sdk-path) \
    -framework Cocoa \
    -framework InputMethodKit \
    -Osize \
    "${SOURCES[@]}"

# x86_64도 지원하려면 Universal Binary 생성 (선택사항)
# Intel Mac 지원이 필요한 경우 아래 주석 해제
# echo -e "${YELLOW}Intel 바이너리 컴파일 중...${NC}"
# swiftc \
#     -o "$BUILD_DIR/${APP_NAME}_x86_64" \
#     -target x86_64-apple-macos12.0 \
#     -sdk $(xcrun --show-sdk-path) \
#     -framework Cocoa \
#     -framework InputMethodKit \
#     -Osize \
#     "${SOURCES[@]}"
#
# echo -e "${YELLOW}Universal Binary 생성 중...${NC}"
# lipo -create \
#     "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
#     "$BUILD_DIR/${APP_NAME}_x86_64" \
#     -output "$APP_BUNDLE/Contents/MacOS/${APP_NAME}_universal"
# mv "$APP_BUNDLE/Contents/MacOS/${APP_NAME}_universal" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
# rm "$BUILD_DIR/${APP_NAME}_x86_64"

echo -e "  ${GREEN}[OK]${NC} 컴파일 완료"

# Info.plist 복사
echo -e "${YELLOW}Info.plist 복사 중...${NC}"
cp "Sources/terminalHangul/Resources/Info.plist" "$APP_BUNDLE/Contents/"
echo -e "  ${GREEN}[OK]${NC} Info.plist 복사 완료"

# 아이콘 파일 복사
echo -e "${YELLOW}아이콘 파일 복사 중...${NC}"
cp Sources/terminalHangul/Resources/*.png "$APP_BUNDLE/Contents/Resources/" 2>/dev/null || true
echo -e "  ${GREEN}[OK]${NC} 아이콘 파일 복사 완료"

# 실행 권한 설정
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo -e "${GREEN}=== 빌드 완료 ===${NC}"
echo -e "앱 번들 위치: $APP_BUNDLE"

# 설치 여부 확인
echo ""
read -p "입력기를 설치하시겠습니까? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}기존 입력기 제거 중...${NC}"

    # 기존 프로세스 종료
    pkill -f "$APP_NAME.app" 2>/dev/null || true

    # 기존 앱 제거
    if [[ -d "$INSTALL_DIR/$APP_NAME.app" ]]; then
        rm -rf "$INSTALL_DIR/$APP_NAME.app"
        echo -e "  ${GREEN}[OK]${NC} 기존 앱 제거 완료"
    fi

    # 새 앱 복사
    echo -e "${YELLOW}새 입력기 설치 중...${NC}"
    mkdir -p "$INSTALL_DIR"
    cp -R "$APP_BUNDLE" "$INSTALL_DIR/"
    echo -e "  ${GREEN}[OK]${NC} 설치 완료: $INSTALL_DIR/$APP_NAME.app"

    # 입력 소스 등록
    echo -e "${YELLOW}입력 소스 등록 중...${NC}"

    # TIS 등록 시도 (시스템이 자동으로 감지할 때까지 대기)
    sleep 1

    echo -e "${GREEN}=== 설치 완료 ===${NC}"
    echo ""
    echo -e "${BLUE}다음 단계:${NC}"
    echo "1. 시스템 환경설정 > 키보드 > 입력 소스로 이동"
    echo "2. '+' 버튼 클릭"
    echo "3. 'TerminalHangul' 검색 및 추가"
    echo "4. 입력기 전환하여 사용"
    echo ""
    echo -e "${YELLOW}참고:${NC}"
    echo "- 처음 설치 시 로그아웃/로그인이 필요할 수 있습니다."
    echo "- 문제가 있으면 다음 명령으로 로그 확인: log stream --predicate 'process == \"TerminalHangul\"'"
else
    echo -e "${YELLOW}설치가 취소되었습니다.${NC}"
    echo "수동 설치: cp -R $APP_BUNDLE ~/Library/Input\\ Methods/"
fi
