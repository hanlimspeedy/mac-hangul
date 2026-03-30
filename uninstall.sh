#!/bin/bash
set -e

echo "==> mac-hangul 제거"

launchctl bootout gui/$(id -u)/com.hanlim.nfc-rename 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.hanlim.nfc-rename.plist"
rm -f /opt/homebrew/bin/nfc-rename

echo "완료: mac-hangul 제거됨"
echo "  - ~/Outbox 폴더는 유지됩니다. 필요 없으면 직접 삭제하세요."
