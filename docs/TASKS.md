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
- [x] **Privacy Policy** <!-- completed: 2026-02-03 -->
  - [x] PRIVACY_POLICY.md作成（日英両対応）
  - [x] アプリ内Privacy Policy画面実装
- [ ] **Store Submission**
  - [ ] TestFlight配布
  - [ ] TestFlight配布
  - [ ] App Store申請

## 🎨 Phase 5: UI/UX Modernization (HIG & Material 3 & OOUI)
- [ ] **Design System Update**
  - [ ] Adopt Material 3 (Material You) for Android
  - [ ] Refine iOS Human Interface Guidelines (HIG) compliance (Cupertino widgets where appropriate)
  - [x] Apply OOUI (Object-Oriented UI) principles (Navigation, Object lists) <!-- completed: 2026-02-07 -->
- [x] **Data & Logic Modernization** <!-- completed: 2026-02-07 -->
  - [x] **Multi-LLM Support:** Gemini / ChatGPT / Claude の3プロバイダー対応完了。LlmService抽象基底クラス、プロバイダーセレクターUI実装済み。 <!-- completed: 2026-02-07 -->
  - [x] **Tag Localization:** ML Kit fallback labels now match system language (JP/EN). Added 37-entry ambient label maps for both languages. <!-- completed: 2026-02-07 -->
  - [x] **Atmospheric Time Logic:** Added `atmosphericTime`, `atmosphericTimeJa`, `atmosphericTimeForLanguage()` to TraceLog model. 8 time zones: Late Night, Dawn, Morning, Midday, Afternoon, Dusk, Evening, Late Night. <!-- completed: 2026-02-07 -->
- [x] **Screen Refactoring** <!-- completed: 2026-02-07 -->
  - [ ] **Trace Card Redesign:**
    -   **Priority Update:** "Ambient Meaning" (Tags) should be the **Main Content** (Hero).
    -   **Hierarchy:** Tags/Meaning > Atmospheric Time > Exact Time > Metadata.
    -   **Visuals:** Use the most prominent extracted tag as the card title. 11px corner, ambient label pills, metadata row. <!-- completed: 2026-02-07 -->
  - [x] **Home Screen:** CustomScrollView+Slivers, refined header, weather filter chips, double-ring FAB, atmospheric time in search. <!-- completed: 2026-02-07 -->
  - [x] **Capture Screen:** Immersive fullscreen, gradient overlay, double-ring capture button with pulse animation, minimal gallery button. <!-- completed: 2026-02-07 -->
  - [x] **Detail Screen:** Color gradient hero banner (120px), atmospheric time as 36px heading, bottom sheet delete confirmation, improved layout. <!-- completed: 2026-02-07 -->
  - [x] **Shareable Trace Card:** Atmospheric time as hero, exact time+date as subtitle. <!-- completed: 2026-02-07 -->
  - [ ] **Settings:** Standard platform-specific layout.
- [x] **Data Model拡張** <!-- completed: 2026-02-07 -->
  - [x] タイムスタンプ分離: `capturedAt`（写真撮影日時）と `createdAt`（カード生成日時）を分離
  - [x] Reconstructed Memoryには `capturedAt` を使用
  - [x] ホーム画面ソートは `createdAt` で実行
- [x] **Reconstructed Memory改善** <!-- completed: 2026-02-07 -->
  - [x] プロンプト最適化（2文・明示的な文字数制限）
  - [x] トークン使用量削減（Gemini: 500, OpenAI/Claude: 200）
  - [x] 文章の途中切れ防止
- [ ] **Visuals**
  - [ ] Typography and Color refinement (Contrast, Hierarchy)
  - [ ] Micro-interactions and Haptics tune-up
