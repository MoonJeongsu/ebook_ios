# TestFlight 배포 가이드

무료 한국문학집 iOS 앱을 App Store Connect TestFlight에 올리는 절차입니다.

## 사전 준비

| 항목 | 상태 | 비고 |
|------|------|------|
| Apple Developer Program | **필수** | $99/년 |
| Mac + Xcode 15+ | **필수** | Archive는 Mac에서만 가능 |
| Firebase iOS 앱 등록 | 완료 | `com.moons.ebook` |
| GoogleService-Info.plist | 완료 | `EbookApp/` 포함 |
| App Icon 1024×1024 | 완료 | `Assets.xcassets/AppIcon` |
| Privacy Manifest | 완료 | `PrivacyInfo.xcprivacy` |
| Export Compliance | 완료 | `ITSAppUsesNonExemptEncryption = NO` |

## 1. App Store Connect 앱 등록

1. [App Store Connect](https://appstoreconnect.apple.com) 로그인
2. **My Apps** → **+** → **New App**
3. 아래 정보 입력 (`store-assets/` 파일 참고):

| 필드 | 값 |
|------|-----|
| Platform | iOS |
| Name | 무료 한국문학집 |
| Primary Language | Korean |
| Bundle ID | `com.moons.ebook` |
| SKU | `com.moons.ebook` (임의 고유값) |
| User Access | Full Access |

## 2. 개인정보처리방침 URL 호스팅

App Store Connect에 **Privacy Policy URL**이 필요합니다.

1. `store-assets/privacy-ios.html`을 웹 서버에 업로드
2. 권장 URL: `https://moons.pe.kr/privacy-ios.html`
3. App Store Connect → App Information → Privacy Policy URL 입력

> URL이 아직 없으면 Firebase Hosting 또는 GitHub Pages 등에 먼저 배포하세요.

## 3. Xcode 서명 설정

1. `ios-app/EbookApp.xcodeproj` 열기
2. Target **EbookApp** → **Signing & Capabilities**
3. **Team** 선택 (Apple Developer 계정)
4. **Bundle Identifier**: `com.moons.ebook` 확인
5. **Automatically manage signing** 체크

또는 `Config/Release.xcconfig.example`을 `Release.xcconfig`로 복사 후 Team ID 입력.

## 4. Archive & Upload

### 방법 A: Xcode GUI (권장)

1. 상단 디바이스 → **Any iOS Device (arm64)** 선택
2. **Product** → **Archive**
3. Organizer 창 → **Distribute App**
4. **App Store Connect** → **Upload**
5. 옵션 기본값 유지 → Upload

### 방법 B: 터미널 스크립트

```bash
cd ios-app
chmod +x scripts/archive-testflight.sh
./scripts/archive-testflight.sh
```

Archive만 만들려면:

```bash
./scripts/archive-only.sh
```

## 5. App Store Connect 메타데이터 입력

**App Store** 탭 → 버전 **1.0.0** 생성 후 `store-assets/` 내용 복사:

| 항목 | 파일 |
|------|------|
| 설명 (한국어) | `description-ko.txt` |
| 부제 | `subtitle-ko.txt` |
| 키워드 | `keywords-ko.txt` |
| 지원 URL | `support-url.txt` |
| 마케팅 URL | `marketing-url.txt` |
| 개인정보처리방침 URL | `privacy-policy-url.txt` |

### 스크린샷 (필수)

TestFlight **외부** 테스터는 스크린샷 없이도 **내부** 테스트 가능합니다.  
**내부 테스트** (최대 100명, Team 멤버): 스크린샷 불필요.

| 기기 | 크기 |
|------|------|
| iPhone 6.7" | 1290 × 2796 |
| iPhone 6.5" | 1284 × 2778 또는 1242 × 2688 |

시뮬레이터에서 Cmd+S로 캡처 후 업로드.

### App Privacy (데이터 수집 설명)

App Store Connect → **App Privacy**:

| 데이터 | 수집 | 용도 |
|--------|------|------|
| 연락처 정보 | ❌ | - |
| 위치 | ❌ | - |
| 식별자 | ❌ | - |
| 사용 데이터 | ❌ | - |
| 진단 | ❌ | - |

Firebase SDK가 기술적 접속 정보를 생성할 수 있으나, 앱이 사용자 개인정보를 직접 수집하지 않으므로 **Data Not Collected** 또는 Firebase 관련 **기술 데이터만** 해당 항목에 명시.

`privacy-ios.html` 2절 내용과 일치시키세요.

### 연령 등급

설문에서: 무제한 웹 접근 ❌, 사용자 생성 콘텐츠 ❌, 가격 없음 → **4+**

### Export Compliance

업로드 후 "Does your app use encryption?" → **No**  
(Info.plist에 `ITSAppUsesNonExemptEncryption = false` 설정됨)

## 6. TestFlight 설정

1. App Store Connect → **TestFlight** 탭
2. 빌드 처리 완료 대기 (5~30분, "Processing" → "Ready to Submit")
3. **Missing Compliance** 표시 시 → **Manage** → Export Compliance **No** 선택
4. **Internal Testing** 그룹 생성 → 테스터 추가
5. 빌드 선택 → **TestFlight 릴리스 노트** (`testflight-release-notes-ko.txt` 내용)

### 내부 vs 외부 테스트

| 구분 | 내부 | 외부 |
|------|------|------|
| 인원 | 100명 (Team) | 10,000명 |
| 심사 | 없음 | Apple Beta Review (1~2일) |
| 스크린샷 | 불필요 | App Store 메타데이터 필요 |

초기 테스트는 **Internal Testing** 권장.

## 7. 테스터 초대

- **Internal**: App Store Connect Users and Access에 등록된 계정
- **External**: 이메일 초대 또는 공개 링크

## 8. 빌드 번호 올리기

재업로드 시 `CURRENT_PROJECT_VERSION` 증가:

Xcode → Target → General → **Build** (예: 1 → 2)

또는 `project.pbxproj`의 `CURRENT_PROJECT_VERSION`.

## 체크리스트

```
[ ] App Store Connect 앱 생성 (com.moons.ebook)
[ ] privacy-ios.html 웹 호스팅
[ ] Xcode Team 서명 설정
[ ] Archive & Upload 성공
[ ] Export Compliance 처리
[ ] TestFlight Internal 그룹 + 테스터 추가
[ ] 실기기에서 설치·작가 목록·검색·읽기·서재 테스트
```

## 문제 해결

| 오류 | 해결 |
|------|------|
| No accounts with App Store Connect access | Xcode → Settings → Accounts에 Apple ID 추가 |
| Failed to register bundle identifier | Developer Portal에서 Bundle ID 등록 확인 |
| Missing compliance | TestFlight → Manage Export Compliance |
| Firebase 연결 실패 | GoogleService-Info.plist Target 포함 확인 |
| Invalid Icon | 1024×1024 PNG, 알파 채널 없음 확인 |
