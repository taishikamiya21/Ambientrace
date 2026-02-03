# Ambientrace Project Tasks

## ✅ Completed
- [x] Phase 1: Core Functionality (Camera, Gemini, Location, Weather) <!-- id: 10 -->
- [x] Phase 2: "Less is More" (Remove AI Sketch/Step Count) <!-- id: 11 -->
- [x] GitHub Backup (`taishikamiya21/Ambientrace`) <!-- id: 12 -->

## 🚀 Phase 3: Productization (App Polish)
- [x] **Splash Screen** <!-- completed: 2026-02-03 -->
  - [x] Configure `flutter_native_splash` with brand color (#0A0A0F)
- [x] **Onboarding Tutorial** <!-- completed: 2026-02-03 -->
  - [x] Implement "First Launch" check (`shared_preferences`)
  - [x] Create `OnboardingScreen` (3 slides: Capture, Dissolve, Remain)
- [x] **Information Page** <!-- completed: 2026-02-03 -->
  - [x] Add "About" section in Settings (`package_info_plus`)
  - [x] Add License page (`showLicensePage`)
  - [x] Add Privacy Policy placeholder
- [x] **App Icon** <!-- completed: 2026-02-03 -->
  - [x] Configure `flutter_launcher_icons` in pubspec.yaml
  - [x] Generate assets for iOS/Android

## 🚀 Phase 3.5: UI/UX Polish
- [x] **Error Feedback** <!-- completed: 2026-02-03 -->
  - [x] Styled error snackbars in capture_screen.dart
  - [x] Styled error snackbars in trace_detail_screen.dart
- [x] **Store Metadata** <!-- completed: 2026-02-03 -->
  - [x] Created STORE_METADATA.md with descriptions and keywords

## 🔍 Phase 4: Verification & Store Prep
- [x] **App Icon Generated** <!-- completed: 2026-02-03 -->
  - [x] App icon image created (1024x1024 PNG)
  - [x] iOS/Android icons generated via flutter_launcher_icons
- [x] **Build Verification** <!-- completed: 2026-02-03 -->
  - [x] iOS build successful
  - [x] Android build successful (fixed v1 embedding issue)
- [x] **Real Device Testing (iOS)** <!-- completed: 2026-02-03 -->
  - [x] ML Kit有効化（Gemini未設定時のフォールバック）
  - [x] Share機能修正（sharePositionOrigin追加）
  - [x] 動作確認完了
- [ ] **Real Device Testing (Android)**
  - [ ] Android実機での動作確認
- [ ] **Store Assets**
  - [ ] Screenshots (Home, Capture, Detail)
- [ ] **Store Submission**
  - [ ] Privacy Policy URL
  - [ ] TestFlight / Internal Testing
