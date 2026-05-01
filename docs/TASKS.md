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
  - [x] **Trace Card Redesign:** <!-- completed: 2026-02-07 -->
    -   **Priority Update:** "Ambient Meaning" (Tags) should be the **Main Content** (Hero).
    -   **Hierarchy:** Tags/Meaning > Atmospheric Time > Exact Time > Metadata.
    -   **Visuals:** Use the most prominent extracted tag as the card title. 11px corner, ambient label pills, metadata row.
  - [x] **Home Screen:** CustomScrollView+Slivers, refined header, weather filter chips, double-ring FAB, atmospheric time in search. <!-- completed: 2026-02-07 -->
  - [x] **Capture Screen:** Immersive fullscreen, gradient overlay, double-ring capture button with pulse animation, minimal gallery button. <!-- completed: 2026-02-07 -->
  - [x] **Detail Screen:** Color gradient hero banner (120px), atmospheric time as 36px heading, bottom sheet delete confirmation, improved layout. <!-- completed: 2026-02-07 -->
  - [x] **Shareable Trace Card:** Atmospheric time as hero, exact time+date as subtitle. <!-- completed: 2026-02-07 -->
  - [x] **Settings:** Standard platform-specific layout. <!-- completed: 2026-02-11, Phase 6C -->
- [x] **Data Model拡張** <!-- completed: 2026-02-07 -->
  - [x] タイムスタンプ分離: `capturedAt`（写真撮影日時）と `createdAt`（カード生成日時）を分離
  - [x] Reconstructed Memoryには `capturedAt` を使用
  - [x] ホーム画面ソートは `createdAt` で実行
- [x] **Reconstructed Memory改善** <!-- completed: 2026-02-07 -->
  - [x] プロンプト最適化（2文・明示的な文字数制限）
  - [x] トークン使用量削減（Gemini: 500, OpenAI/Claude: 200）
  - [x] 文章の途中切れ防止
- [x] **Visuals** <!-- completed: 2026-02-12 -->
  - [x] Typography and Color refinement (Contrast, Hierarchy) <!-- completed: 2026-02-11, Phase 6B/6C -->
  - [x] Micro-interactions and Haptics tune-up <!-- completed: 2026-02-12 -->

## 🚀 Phase 6: リリース準備（実行順序順）

> **参照:** 修正項目の詳細 → [BACKLOG.md](./BACKLOG.md)
> **参照:** デザインシステム → [FOOSTUDIO_DESIGN_SYSTEM_JP.md](./FOOSTUDIO_DESIGN_SYSTEM_JP.md)

### Phase 6A: バグ修正・品質改善（TestFlight Backlog） ✅ <!-- completed: 2026-02-11 -->
- [x] TestFlightテストで発見された修正項目の対応（[BACKLOG.md](./BACKLOG.md) 参照）
- [x] Critical / High 優先度の項目をすべて完了（BL-002〜BL-007）

### Phase 6B: f∞studio デザインシステム適用 ✅ <!-- completed: 2026-02-11 -->
- [x] カラーシステムの適用（Canvas: #0A0A0F, Accent: #DFFF4F, 不透明度スケール）
- [x] タイポグラフィの適用（Inter w200-w800, JetBrains Mono for metadata）
- [x] コンポーネントスタイルの統一（カード、チップ、ボタン）
- [x] `lib/theme/app_theme.dart` 新規作成（全デザイントークン集約）

### Phase 6C: UI/UX 最終仕上げ（Phase 5 残タスク統合） ✅ <!-- completed: 2026-02-11 -->
- [x] Settings Screen モダン化（デザインシステム適用、多言語対応済み）
- [x] Trace Card Redesign（Meaning > Time 階層シフト）
- [x] Typography & Color リファイン（コントラスト、階層）
- [x] Micro-interactions & Haptics チューンアップ <!-- completed: 2026-02-12 -->

### Phase 6D: ストア申請準備
- [ ] iOS / Android スクリーンショット撮影（Home, Capture, Dissolve, Detail, Share）
- [ ] ストアメタデータ最終確認（STORE_METADATA.md）
- [ ] プライバシーポリシーURL公開確認

### Phase 6E: 最終検証 & 申請
- [ ] Android実機テスト
- [ ] TestFlight再配布（修正版）& 最終テスト
- [ ] App Store 申請
- [ ] Google Play 申請

## 🚀 Phase 7: v1.2 Phase A ✅ <!-- completed: 2026-05-01 -->
- [x] **C-1 データエクスポート:** JSON / CSV export <!-- completed: 2026-05-01 -->
- [x] **C-2 データインポート:** JSON dry-run / apply / conflict handling <!-- completed: 2026-05-01 -->
- [ ] **C-3 既存写真の一括カード化:** Phase B 対象
- [x] **C-4 データモデル拡張:** `originalFileName`, `aiProviderUsed`, `schemaVersion` <!-- completed: 2026-05-01 -->
- [x] **C-5 カラー抽出改善:** Vibrant + HSV staged extraction <!-- completed: 2026-05-01 -->
- [x] **C-6 フォルダ機能:** folder model, service, selector, management UI <!-- completed: 2026-05-01 -->
- [ ] **C-7 カード ZIP 出力:** Phase B 対象
- [x] **C-8 オンボーディング・設定 UX 改善:** AI Enrichment, info sheets, provider badges <!-- completed: 2026-05-01 -->
- [x] **C-9 APIキー secure storage 移行:** secure storage + migration <!-- completed: 2026-05-01 -->
- [x] **C-10 プロンプトプリセット:** Minimal / Poetic / Documentary / Exhibition <!-- completed: 2026-05-01 -->
