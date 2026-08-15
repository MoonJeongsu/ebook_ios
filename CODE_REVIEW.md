# 코드 리뷰 노트 — 책갈피 iOS (2026-08-15)

TestFlight 1.0.0 (2) 업로드 시점 기준.

## 확인 완료 (반영됨)

### Release 빌드 컴파일 수정 2건 — 검증 통과
- `ReaderUiState` 생성자 인자 순서 수정 (`ReaderViewModel.swift`): 구조체 memberwise init 순서와 대조하여 올바름.
- `scrollTo` AnyHashable 타입 수정 (`ReaderView.swift`): 헤더("header")·문단(Int) `.id()` 대상과 대조, 앱 내 유일한 scrollTo 호출로 부작용 없음.

### 실행 중 자체 종료 버그 — 빌드 2에서 수정됨
- `NetworkGate`가 오프라인 판정 시 알림 → `exit(0)`으로 앱을 강제 종료했음.
- `NetworkMonitor`가 `start()` 직후 `currentPath`를 동기로 읽어, 정상 네트워크에서도
  첫 콜백 전 unsatisfied 오탐 → 콜드 런치 타이밍에 따라 멀쩡한 단말에서도 종료 발생.
- 빌드 2: 자동 복구되는 오프라인 오버레이로 교체, 동기 읽기 제거.
- 참고: 프로그램적 자체 종료(`exit`)는 Apple 심사 지침상으로도 지적 대상.

## 개선 — 여유 있을 때

### 1. 업로드 시 불필요한 이중 export
`scripts/archive-and-upload.sh`의 `--upload` 경로에서 같은 아카이브로 `exportArchive`를
두 번(export → upload) 실행하는데, upload 경로는 첫 export 산출물을 쓰지 않는다.

- 영향: 릴리즈마다 재서명·패키징 2회. 첫 패스의 일시적 실패가 `set -e`로 릴리즈 중단.
- 수정: `--upload`일 때 export 패스 생략.

### 2. ExportOptions plist 중복
`ExportOptions.plist`/`ExportOptions-upload.plist`가 destination 한 줄만 다른 사본 (dream_ios에도 동일 페어).

- 수정: 단일 템플릿 + 스크립트에서 `plutil -replace destination`으로 파생.

### 3. ASC 인증 정보 하드코딩 중복
API 키 ID·Issuer·경로가 dream/ebook 두 저장소 스크립트에 동일하게 하드코딩.

- 영향: 키 회전 시 두 저장소 모두 갱신 필요, 누락 시 업로드 시점 인증 실패.
- 수정: `~/.appstoreconnect/` 아래 공유 설정 파일에서 읽도록 통합.
