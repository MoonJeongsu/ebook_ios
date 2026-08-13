# 무료 한국문학집 (iOS)

Android 앱과 동일한 Firebase 백엔드를 사용하는 iOS 전자책 앱입니다.

## 기능

- **작가**: Firestore `authors` 목록
- **작품**: 작가 선택 시 해당 작품 목록
- **검색**: 작가명/작품명 로컬 검색
- **읽기**: Storage에서 txt 다운로드 후 뷰어 표시
- **내 서재**: 다운로드한 작품 목록, 마지막 읽은 위치부터 이어 읽기

## 요구 사항

- macOS + Xcode 15 이상
- iOS 16.0 이상
- Firebase 프로젝트 `ebook-bfaab` (iOS 앱 등록 완료)

## 실행

1. Mac에서 Xcode로 `ios-app/EbookApp.xcodeproj` 열기
2. Signing & Capabilities에서 Team 선택 (Bundle ID: `com.moons.ebook`)
3. `EbookApp/GoogleService-Info.plist`가 Target에 포함되어 있는지 확인
4. Run ▶ (시뮬레이터 또는 실기기)

> Firebase iOS SDK는 Swift Package Manager로 연결되어 있습니다. 첫 빌드 시 패키지 다운로드에 시간이 걸릴 수 있습니다.

## Firebase

- Project: `ebook-bfaab`
- Bundle ID: `com.moons.ebook`
- 사용 SDK: FirebaseCore, FirebaseFirestore, FirebaseStorage

## 프로젝트 구조

```
EbookApp/
├── EbookAppApp.swift          # 앱 진입점, Firebase 초기화
├── ContentView.swift          # 탭 네비게이션
├── Data/                      # Firestore, Storage, 로컬 서재
├── Models/
├── ViewModels/
├── Views/
├── Theme/
└── GoogleService-Info.plist
```

## Android 앱과의 대응

| Android | iOS |
|---------|-----|
| Jetpack Compose | SwiftUI |
| Room | JSON 파일 기반 LibraryStore |
| Navigation Compose | NavigationStack + TabView |
| ViewModel + StateFlow | ObservableObject + @Published |

## TestFlight 배포

TestFlight 업로드 절차·체크리스트·App Store Connect 메타데이터는 **[TESTFLIGHT.md](TESTFLIGHT.md)** 와 **`store-assets/`** 폴더를 참고하세요.

```bash
# Mac에서 Archive & Upload
chmod +x scripts/archive-testflight.sh
./scripts/archive-testflight.sh
```
