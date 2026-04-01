# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

macOS 한글 파일명 자소분리(NFD→NFC) 자동 변환 도구. macOS APFS/HFS+가 파일명을 NFD로 저장하여 Windows에서 한글이 풀어져 보이는 문제를 해결한다. `~/Outbox` 폴더에 파일을 넣으면 launchd가 감지하여 자동으로 NFC 변환.

## Architecture

3개의 스크립트로 구성된 단순 구조:

- **`nfc-rename`** — Python 3 스크립트. 핵심 변환 로직. `unicodedata.normalize("NFC")`로 파일명 정규화. APFS 정규화 비민감 특성 때문에 임시이름 경유 2단계 rename (`원본→임시→NFC`) 사용. bottom-up `os.walk`로 하위 디렉토리부터 처리.
- **`install.sh`** — nfc-rename을 `/opt/homebrew/bin/`에 복사하고, `~/Outbox` 생성, launchd plist(`com.hanlim.nfc-rename`) 등록/로드.
- **`uninstall.sh`** — launchd 해제, plist/스크립트 삭제. `~/Outbox`는 유지.

## Key Technical Details

- APFS는 NFC와 NFD를 같은 이름으로 취급(normalization-insensitive)하므로 단순 rename은 no-op → 반드시 임시파일 경유 필요
- 실패 시 자동 원복 (임시이름 → 원본)
- launchd `WatchPaths`로 폴더 감시, `ThrottleInterval: 3`초
- 로그: `/tmp/nfc-rename.log`
- Intel Mac은 `/opt/homebrew/bin` 대신 `/usr/local/bin`으로 수정 필요

## Commands

```bash
# 설치
./install.sh

# 제거
./uninstall.sh

# 수동 실행
nfc-rename ~/Outbox
nfc-rename ~/Desktop/특정폴더

# 로그 확인
cat /tmp/nfc-rename.log
```

## Language

이 프로젝트의 코드 주석, 커밋 메시지, 문서는 한국어로 작성한다.
