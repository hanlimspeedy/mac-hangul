# mac-hangul

macOS에서 한글 파일명의 자소 분리(NFD) 문제를 자동으로 해결합니다.

## 문제

macOS(APFS/HFS+)는 파일명을 Unicode NFD(Normalization Form Decomposed, 분해형)로 저장합니다.
NFD에서 한글 `가`는 초성 `ㄱ`(U+1100) + 중성 `ㅏ`(U+1161)로 분해됩니다.

이 파일을 이메일에 첨부하거나 클라우드로 공유하면,
Windows(NFC 기반)에서 `ㅎㅏㄴㄱㅡㄹ`처럼 자소가 풀어져 보입니다.

이 문제는 macOS 파일시스템의 근본적인 설계이므로, OS 레벨에서는 해결할 수 없습니다.

## 해결 방식

`~/Outbox` 폴더를 첨부 전용 폴더로 사용합니다.

1. 파일을 `~/Outbox`에 복사/이동
2. `launchd`가 폴더 변경을 감지하여 자동으로 파일명을 NFC(조합형)로 변환
3. 변환된 파일을 이메일에 첨부하면 Windows에서 정상 표시

파일명만 변환하며, 파일 내용은 변경하지 않습니다.

### 왜 이 방식인가

| 대안 | 문제점 |
|---|---|
| 파일시스템 전체를 상시 NFC 변환 | 링크/참조 깨짐, 앱 충돌 위험 |
| 메일 앱 설정 변경 | 앱이 전송 중 다시 NFD로 바꿀 수 있음 |
| 크롬 확장 (Gmail 전용) | Gmail만 지원, 다른 메일/메신저 미지원 |
| ZIP으로 묶어서 전송 | 수신자가 압축 해제해야 하는 불편 |
| BetterDisplay 등 유료 앱 | 유료 |

**"첨부 전용 폴더 + 자동 NFC 변환"이 가장 안전하고 범용적입니다.**

## 설치

```bash
git clone https://github.com/hanlimspeedy/mac-hangul.git
cd mac-hangul
./install.sh
```

설치되는 것:
- `/opt/homebrew/bin/nfc-rename` — NFC 변환 스크립트
- `~/Outbox` — 첨부 전용 폴더
- `~/Library/LaunchAgents/com.hanlim.nfc-rename.plist` — 폴더 감시 데몬

## 사용법

```
1. 첨부할 파일을 ~/Outbox 폴더에 복사
2. 자동 변환 완료 (3초 이내)
3. ~/Outbox 에서 메일에 첨부
```

수동 실행도 가능합니다:

```bash
nfc-rename ~/Outbox
nfc-rename ~/Desktop/특정폴더
```

## 제거

```bash
./uninstall.sh
```

## 구조

```
mac-hangul/
  nfc-rename       # NFD→NFC 파일명 변환 스크립트 (Python 3)
  install.sh       # 설치 스크립트
  uninstall.sh     # 제거 스크립트
  README.md
```

## 동작 원리

### 폴더 감시
- `launchd`의 `WatchPaths`로 `~/Outbox` 폴더 변경을 감지
- 파일이 추가/변경되면 `nfc-rename` 자동 실행
- `ThrottleInterval: 3`초로 과도 실행 방지

### NFC 변환
- `unicodedata.normalize("NFC", filename)`으로 파일명 정규화
- bottom-up 순회 (하위 디렉토리 먼저 처리하여 경로 깨짐 방지)
- APFS는 정규화 비민감(NFC와 NFD를 같은 이름으로 취급)이므로,
  단순 rename이 no-op이 될 수 있음
- 이를 우회하기 위해 **임시이름 경유 2단계 rename** 사용:
  `원본(NFD) → 임시이름 → 최종이름(NFC)`
- 실패 시 자동 원복 (임시이름 → 원본으로 복구)

### 한계

- `~/Outbox` 폴더에 넣는 수작업은 필요 (Finder에서 드래그)
- 일부 앱이 전송 과정에서 다시 NFD로 바꾸면 효과 없음
- HFS+ 포맷 외장 디스크에서는 NFC 유지가 안 될 수 있음 (APFS에서만 안정적)
- `launchd` WatchPaths는 이벤트 누락 가능성 있음 (드물지만 발생 가능, 수동 `nfc-rename` 실행으로 보완)

## 요구사항

- macOS (Apple Silicon / Intel 모두 가능)
- Python 3 (macOS 기본 포함)
- `/opt/homebrew/bin` 경로 (Homebrew 설치 기준, Intel Mac은 `/usr/local/bin`으로 수정 필요)

## 참고

- [Unicode Normalization Forms (UAX #15)](https://unicode.org/reports/tr15/)
- [Apple APFS FAQ - Filename Normalization](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/APFS_Guide/FAQ/FAQ.html)
- [macOS launchd WatchPaths](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
