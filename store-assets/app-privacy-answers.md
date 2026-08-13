# App Store Connect → App Privacy 설문 답변 가이드

앱이 사용자 개인정보를 직접 수집하지 않습니다. Firebase SDK 연동으로 기술적 접속 정보가 Google 서버로 전송될 수 있습니다.

## 권장 답변 (Data Not Collected에 가깝게)

**Does your app collect data?**
→ 앱 자체는 회원가입·이름·이메일 등을 수집하지 않음

Firebase 사용 시 Apple은 "서드파티 SDK" Privacy Manifest를 Firebase SDK가 제공하므로, 앱 레벨 설문에서는:

### Option A: Data Not Collected (앱이 직접 수집하지 않는 경우)

앱이 사용자로부터 이름, 이메일, 위치 등을 입력받지 않으면 **Data Not Collected** 선택 가능.

Firebase SDK의 자동 수집은 SDK Privacy Manifest로 처리됩니다.

### Option B: 일부 데이터 명시 (보수적 접근)

| Data Type | Collected | Linked to User | Tracking | Purpose |
|-----------|-----------|----------------|----------|---------|
| Other Diagnostic Data | Optional | No | No | App Functionality (Firebase SDK 기술 로그) |

## 참고

- `privacy-ios.html` 3절·4절 내용과 일치해야 합니다.
- TestFlight 내부 테스트만 할 경우 App Privacy 설문을 나중에 완료해도 Internal Testing은 가능한 경우가 많으나, **Export Compliance**는 빌드마다 처리 필요.

## Export Compliance

업로드 후 TestFlight에서:
- **Is your app designed to use cryptography?** → No (HTTPS만 사용, 자체 암호화 없음)
- 또는 Info.plist `ITSAppUsesNonExemptEncryption = false`로 자동 처리
