# mac-hangul

macOS에서 한글 파일명의 자소 분리(NFD) 문제를 자동으로 해결합니다.

## 문제

macOS는 파일명을 Unicode NFD(분해형)로 저장합니다.
이 파일을 이메일에 첨부하면 Windows에서 `ㅎㅏㄴㄱㅡㄹ`처럼 자소가 풀어져 보입니다.

## 해결

`~/Outbox` 폴더에 파일을 넣으면 자동으로 파일명을 NFC(조합형)로 변환합니다.
변환된 파일을 첨부하면 Windows에서 정상 표시됩니다.

## 설치

```bash
git clone https://github.com/hanlimspeedy/mac-hangul.git
cd mac-hangul
./install.sh
```

## 사용법

1. 첨부할 파일을 `~/Outbox` 폴더에 복사
2. 자동 변환 완료 (3초 이내)
3. `~/Outbox`에서 메일에 첨부

수동 실행도 가능합니다:

```bash
nfc-rename ~/Outbox
nfc-rename ~/Desktop/특정폴더
```

## 제거

```bash
./uninstall.sh
```

## 동작 원리

- `launchd`의 `WatchPaths`로 `~/Outbox` 폴더 변경을 감지
- 파일/폴더명을 Unicode NFC로 정규화하여 rename
- APFS 정규화 비민감 대응을 위해 임시이름 경유 2단계 rename 사용

## 요구사항

- macOS (Apple Silicon)
- Python 3 (macOS 기본 포함)
