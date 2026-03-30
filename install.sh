#!/bin/bash
set -e

echo "==> mac-hangul: 한글 파일명 자소분리(NFD→NFC) 자동 변환 설치"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_BIN="/opt/homebrew/bin/nfc-rename"
OUTBOX="$HOME/Outbox"
AGENT_PLIST="$HOME/Library/LaunchAgents/com.hanlim.nfc-rename.plist"

# nfc-rename 스크립트 설치
cp "$SCRIPT_DIR/nfc-rename" "$INSTALL_BIN"
chmod +x "$INSTALL_BIN"
echo "  설치: $INSTALL_BIN"

# Outbox 폴더 생성
mkdir -p "$OUTBOX"
echo "  생성: $OUTBOX"

# LaunchAgent 생성
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$AGENT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.hanlim.nfc-rename</string>
    <key>ProgramArguments</key>
    <array>
        <string>${INSTALL_BIN}</string>
        <string>${OUTBOX}</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>${OUTBOX}</string>
    </array>
    <key>ThrottleInterval</key>
    <integer>3</integer>
    <key>StandardOutPath</key>
    <string>/tmp/nfc-rename.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/nfc-rename.log</string>
</dict>
</plist>
PLIST
echo "  설치: $AGENT_PLIST"

# LaunchAgent 로드
launchctl bootout gui/$(id -u)/com.hanlim.nfc-rename 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$AGENT_PLIST"

echo ""
echo "완료: mac-hangul 설치됨"
echo "  - ~/Outbox 폴더에 파일을 넣으면 자동으로 한글 파일명이 NFC로 변환됩니다."
echo "  - 변환된 파일을 이메일에 첨부하면 Windows에서 정상 표시됩니다."
echo ""
echo "사용법:"
echo "  1. 첨부할 파일을 ~/Outbox 폴더에 복사"
echo "  2. 자동 변환 완료 (3초 이내)"
echo "  3. ~/Outbox 에서 메일에 첨부"
echo ""
echo "※ 수동 실행: nfc-rename ~/Outbox"
echo "※ 제거: ./uninstall.sh"
