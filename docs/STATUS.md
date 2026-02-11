# Ambientrace 開発ステータス

**最終更新:** 2026-02-11 JST

---

## 📱 プロジェクト概要

**アプリ名:** Ambientrace（アンビエントレース）

**コンセプト:** 写真を保存せず「空気の痕跡（環境データ）」だけを記録するアプリ。撮影した瞬間のカラーパレット、位置情報、天気、画像から検出したラベルなどを保存し、後から見返すことで記憶を想像で再構成する体験を提供する。

**技術スタック:**
- Flutter (Dart)
- iOS / Android / macOS 対応

---

## 📁 プロジェクト構成

```
/Users/tai/Documents/development/App/Ambientrace/
├── lib/
│   ├── main.dart                    # アプリエントリーポイント
│   ├── models/
│   │   └── trace_log.dart           # トレースデータモデル
│   ├── screens/
│   │   ├── home_screen.dart         # ホーム画面（検索・フィルター付き）
│   │   ├── capture_screen.dart      # 撮影/画像選択画面
│   │   ├── trace_detail_screen.dart # 詳細表示・削除
│   │   ├── settings_screen.dart     # 設定画面（APIキー・情報）
│   │   └── onboarding_screen.dart   # オンボーディング（初回起動）
│   ├── services/
│   │   ├── storage_service.dart     # ローカルストレージ
│   │   ├── location_service.dart    # GPS・位置情報
│   │   ├── color_service.dart       # カラーパレット抽出
│   │   ├── weather_service.dart     # 天気API（Open-Meteo）
│   │   ├── image_labeling_service.dart  # 画像ラベリング統合（プロバイダールーティング）
│   │   ├── llm_service.dart         # LLM抽象基底クラス + LlmProvider enum
│   │   ├── gemini_service.dart      # Gemini API連携 ✅
│   │   ├── openai_service.dart      # OpenAI (ChatGPT) API連携 ✅
│   │   └── claude_service.dart      # Anthropic (Claude) API連携 ✅
│   └── widgets/
│       ├── trace_card.dart          # トレースカード（Atmospheric Time主役）
│       ├── shareable_trace_card.dart # SNSシェア用カード
│       └── dissolve_animation.dart  # 写真→データ溶解アニメーション
├── test/
│   ├── widget_test.dart
│   └── services/
│       └── gemini_service_test.dart # GeminiService ユニットテスト
├── docs/
│   ├── SPEC.md                      # 企画書・仕様書
│   ├── STATUS.md                    # このファイル
│   ├── TASKS.md                     # タスク管理
│   ├── STORE_METADATA.md            # ストア用メタデータ
│   ├── WORK_LOG_2026-02-03.md       # 作業ログ
│   └── INSTRUCTIONS_FOR_CLAUDE.md   # Claude Code用指示書
├── assets/
│   └── icon/                        # アプリアイコン用
├── ios/                             # iOS設定
├── macos/                           # macOS設定
└── android/                         # Android設定
```

---

## ✅ 完了した機能

| 機能 | 説明 | 状態 |
|------|------|------|
| **開発環境** | Flutter 3.38.7, Xcode 26.2, Android SDK | ✅ |
| **カメラ/画像選択** | カメラ（実機）または画像ピッカー（シミュレータ/macOS） | ✅ |
| **カラーパレット抽出** | 画像から主要色を抽出 | ✅ |
| **位置情報** | GPS座標の取得 | ⚠️ macOSでパーミッション問題あり |
| **地名取得 (Geocoding)** | 座標から地名を取得 | ⚠️ macOS非対応（スキップ） |
| **天気API** | Open-Meteo APIで気温・天候取得 | ✅ |
| **画像ラベリング** | ML Kit（実機） + Gemini API（オプション） | ✅ iOS実機確認済み |
| **画像圧縮** | API送信前に画像を圧縮（1024px, JPEG 80%） | ✅ |
| **溶解アニメーション** | 写真がデータに変換されるビジュアル演出 | ✅ |
| **ログ一覧** | 日付グループ化、検索、フィルター機能 | ✅ |
| **詳細画面** | トレースの全データ表示、削除機能 | ✅ |
| **設定画面** | AIプロバイダー選択、APIキー管理、About、Licenses、Tutorial | ✅ |
| **Multi-LLM** | Gemini / ChatGPT / Claude の3プロバイダー対応 | ✅ |
| **タイムスタンプ分離** | 写真撮影日時（capturedAt）とカード生成日時（createdAt）を別管理 | ✅ |
| **ユニットテスト** | GeminiServiceのテスト | ✅ |
| **感覚フィードバック** | シャッター・アニメーション・シェア時のハプティクス | ✅ |
| **シェア機能** | "Trace Card" 画像生成とSNS共有 | ✅ |
| **周辺音計測** | 撮影時の騒音レベル(dB)測定（macOS不可） | ✅ |
| **歩数計測** | 撮影時の歩数取得（macOS不可） | ❌ UI非表示（データは収集継続） |
| **AIスケッチ生成** | トレースデータから抽象画を生成 | ❌ 削除（Phase 2で「想像」を重視） |
| **スプラッシュ画面** | ネイティブスプラッシュ（ブランドカラー） | ✅ |
| **オンボーディング** | 初回起動時のコンセプト説明（3ページ） | ✅ |
| **設定画面（情報）** | About/Licenses/Privacy Policy | ✅ |
| **アプリアイコン** | iOS/Android両対応のアイコン生成済み | ✅ |
| **エラーフィードバック** | スタイル付きSnackbar | ✅ |
| **ストアメタデータ** | 説明文・キーワード作成済み | ✅ |

---

### 🔄 2026-02-07 の変更履歴 (Phase 5: Multi-LLM & Data拡張)

**8. Multi-LLM Support（AIプロバイダー選択）**
- `LlmService` 抽象基底クラスを新設（共通インターフェース: `analyzeImage`, `generateStory`）
- `GeminiService` を `LlmService` のサブクラスにリファクタリング
- `OpenAIService` 新規作成（gpt-4o-mini、Vision API対応）
- `ClaudeService` 新規作成（claude-sonnet-4-5-20250929、Messages API対応）
- `ImageLabelingService` にプロバイダールーティング追加（`activeLlmService`, `selectedProvider`）
- 設定画面に3択プロバイダーセレクター追加（各プロバイダーの設定状態を表示）
- プロバイダー選択はSharedPreferencesに永続化

**9. タイムスタンプ分離（capturedAt / createdAt）**
- `TraceLog` モデルに `createdAt`（カード生成日時）フィールドを追加
- `capturedAt` は写真撮影日時（EXIF取得 or カメラ撮影時刻）を保持
- `createdAt` はトレースカード作成時の `DateTime.now()` を保持
- 既存データとの後方互換性: `createdAt` が未設定の場合 `capturedAt` にフォールバック
- ホーム画面のソート順を `createdAt`（カード生成順）に変更
- Reconstructed Memory（ストーリー生成）には `capturedAt`（写真撮影日時）を使用

**10. Reconstructed Memory改善**
- ストーリー生成プロンプトを最適化: 2文・明示的な文字数/単語数制限を追加
- 日本語: 「2文、100文字以内」 / 英語: 「2 sentences, under 50 words」
- Gemini: maxOutputTokens 800→500 (thinking tokenのオーバーヘッド考慮)
- OpenAI/Claude: max_tokens 800→200 (2文の出力に適切なバジェット)
- 文章の途中切れを防止しつつ、トークン使用量を削減

**変更ファイル:**
- `lib/services/llm_service.dart`: 新規（抽象基底クラス）
- `lib/services/openai_service.dart`: 新規
- `lib/services/claude_service.dart`: 新規
- `lib/services/gemini_service.dart`: LlmService継承にリファクタリング
- `lib/services/image_labeling_service.dart`: マルチプロバイダールーティング
- `lib/models/trace_log.dart`: `createdAt` フィールド追加
- `lib/screens/settings_screen.dart`: プロバイダーセレクターUI
- `lib/screens/home_screen.dart`: SettingsScreen引数変更
- `lib/screens/trace_detail_screen.dart`: activeLlmService使用
- `lib/screens/capture_screen.dart`: createdAt明示的指定
- `lib/services/storage_service.dart`: createdAtでソート

---

### 🔄 2026-02-07 の変更履歴 (Phase 5: UI/UX Modernization)

**コンセプトシフト: "ログ思考" → "アンビエント思考"**

正確な時刻（21:30）を主役にすることで「データログ」感が出ていた問題を解決。代わりに「Atmospheric Time」（曖昧な時刻: "Dusk", "Morning"）を全画面で主役にし、カラーパレットをビジュアルヒーローとすることで「雰囲気の記憶」というコンセプトを強化。

**1. Atmospheric Time (曖昧時刻)**
- `TraceLog`モデルに`atmosphericTime`（英語）、`atmosphericTimeJa`（日本語）を追加
- 8つの時間帯: Late Night / Dawn / Morning / Midday / Afternoon / Dusk / Evening / Late Night
- 全画面で正確な時刻（21:30）を脇役に降格、Atmospheric Timeを主役に

**2. Tag Localization (タグ多言語化)**
- ML Kitフォールバックラベルの日本語マッピング追加（37エントリ）
- デバイス言語に応じて自動切替（`PlatformDispatcher.instance.locale`）
- 例: `sky` → EN: "Open Sky" / JA: "広がる空"

**3. TraceCard リデザイン**
- カラーグラデーションバー（8px）をトップヒーローに
- Atmospheric Time（22px, w300）を主見出しに
- 正確な時刻を11px角に降格
- アンビエントラベルをピルチップで表示（3件まで）
- メタデータ行（位置・天気・気温）をボトムに

**4. Home Screen モダン化**
- `CustomScrollView` + `Sliver`ベースに書き換え
- ヘッダーリファイン（28px, w200, letter-spacing: 3）
- 天気フィルターチップ（水平スクロール）
- ダブルリングFABキャプチャーボタン
- Atmospheric Timeを検索対象に追加

**5. Detail Screen リデザイン**
- カラーグラデーントヒーローバナー（120px）追加
- Atmospheric Time（36px, w200）を主見出しに
- AppBarに "Atmospheric Time + Date" 表示
- 削除確認をダイアログからボトムシートに変更

**6. Capture Screen イマーシブ化**
- タイトル削除、フルスクリーンカメラ体験
- トップグラデーションオーバーレイ（可読性確保）
- ダブルリングキャプチャーボタン（76px外/62px内）
- キャプチャー中パルスアニメーション
- ギャラリーボタン小型化（44px）

**7. Shareable Trace Card更新**
- Atmospheric Time（36px）をヒーロー表示に
- 正確な時刻+日付を12pxサブタイトルに

**変更ファイル:**
- `lib/models/trace_log.dart`: Atmospheric Time getters追加
- `lib/services/image_labeling_service.dart`: 日本語ラベルマップ追加
- `lib/widgets/trace_card.dart`: 完全リデザイン
- `lib/screens/home_screen.dart`: CustomScrollView化
- `lib/screens/trace_detail_screen.dart`: カラーヒーロー+Atmospheric Time
- `lib/screens/capture_screen.dart`: イマーシブUI
- `lib/widgets/shareable_trace_card.dart`: Atmospheric Time対応

---

### 🔄 2026-02-03 の変更履歴 (Phase 4: Privacy Policy実装)

**Privacy Policy:**
1. **PRIVACY_POLICY.md作成:** 日英両対応のプライバシーポリシーを作成
2. **アプリ内表示:** Settings → Privacy Policyで全文表示可能
3. **STORE_METADATA.md更新:** Privacy URL、Support URLを追加

**変更ファイル:**
- `docs/PRIVACY_POLICY.md`: 新規作成
- `lib/screens/settings_screen.dart`: PrivacyPolicyScreen追加
- `docs/STORE_METADATA.md`: URL更新

---

### 🔄 2026-02-03 の変更履歴 (Phase 4: iOS実機テスト・バグ修正)

**実機テストで発見・修正した問題:**

1. **Ambient Traces が空になる問題**
   - **原因:** Gemini API未設定時にラベルが取得できなかった
   - **修正:** `google_mlkit_image_labeling` を有効化し、ML Kitをフォールバックとして使用
   - **追加:** ML Kitのラベルを「Ambient風」に変換するマッピング（例: `sky` → `Open Sky`）

2. **Share機能が失敗する問題**
   - **原因:** iOSでは `sharePositionOrigin` パラメータが必須
   - **修正:** `Share.shareXFiles` に `sharePositionOrigin` を追加

**変更ファイル:**
- `lib/services/image_labeling_service.dart`: ML Kit統合、Ambientラベル変換
- `lib/screens/trace_detail_screen.dart`: Share機能修正、エラーログ追加
- `pubspec.yaml`: `google_mlkit_image_labeling` 有効化

---

### 🔄 2026-02-03 の変更履歴 (Phase 4: ビルド検証・アイコン生成)

**アプリアイコン:**
1. **アイコン画像:** ユーザーが1024x1024 PNGを `assets/icon/` に作成。
2. **アイコン生成:** `dart run flutter_launcher_icons` でiOS/Android両対応のアイコンを生成。

**ビルド準備:**
1. **ネイティブスプラッシュ生成:** `dart run flutter_native_splash:create` を実行、iOS/Android両方に適用完了。
2. **Androidパーミッション修正:** `ACTIVITY_RECOGNITION` 権限を追加（歩数計測用）。
3. **Androidアプリ名修正:** 「ambientrace」→「Ambientrace」に修正。
4. **Android v2 embedding修正:** `flutter create --platforms=android .` で再生成、MainActivityを追加。
5. **ビルド検証:** iOS/Androidビルドが正常に完了することを確認。

**変更ファイル:**
- `assets/icon/app_icon.png`: アプリアイコン画像
- `assets/icon/app_icon_foreground.png`: Androidアダプティブアイコン用
- `android/app/src/main/AndroidManifest.xml`: 権限追加、アプリ名修正
- `android/app/src/main/kotlin/.../MainActivity.kt`: 新規作成
- `android/app/src/main/res/`: アイコン・スプラッシュ画面リソース生成

---

### 🔄 2026-02-03 の変更履歴 (Phase 3.5: UI/UX Polish)

**UI/UX改善:**
1. **オンボーディング改善:** タイトルスプラッシュが溶けてオンボーディングに遷移。ミニマルなデザインに変更。
2. **設定から再表示:** 「View Tutorial」オプションを追加。
3. **エラーフィードバック:** スタイル付きSnackbarでユーザーフレンドリーなエラー表示。
4. **アプリアイコン:** `flutter_launcher_icons` 設定済み（画像追加後に生成可能）。
5. **ストアメタデータ:** `STORE_METADATA.md` に説明文・キーワード作成。

**追加パッケージ:**
- `flutter_launcher_icons: ^0.14.1`

**新規ファイル:**
- `docs/STORE_METADATA.md`
- `assets/icon/README.md`

---

### 🔄 2026-02-03 の変更履歴 (Phase 3: Productization)

**プロダクト化:**
1. **スプラッシュ画面:** `flutter_native_splash` を導入。ブランドカラー (#0A0A0F) を設定。
2. **オンボーディング:** 初回起動時に3ページのチュートリアルを表示（Capture → Dissolve → Remain）。
3. **設定画面の拡充:** About（バージョン情報）、Licenses（OSSライセンス）、Privacy Policy（プレースホルダー）を追加。

**追加パッケージ:**
- `flutter_native_splash: ^2.4.0`
- `package_info_plus: ^8.0.0`

**新規ファイル:**
- `lib/screens/onboarding_screen.dart`

**変更ファイル:**
- `lib/main.dart`: オンボーディングフロー統合
- `lib/screens/settings_screen.dart`: Generalセクション追加
- `pubspec.yaml`: パッケージ追加、スプラッシュ設定

---

### 🔄 2026-02-03 の変更履歴 (Phase 2: Less is More)

**コンセプトの鮮明化:**
アプリを「純粋でミニマルな雰囲気記録ツール」に集中させるため、以下の変更を実施。

**削除した機能:**
1. **AI Sketch機能:** 削除。画像を生成することは「データから想像する」という哲学に反するため。
2. **Step Count表示:** 削除。フィットネスアプリではなく「Ambient（環境）」に集中するため。

**UI再構成:**
1. **Atmosphereセクション:** 天気・気温・騒音レベルを「Atmosphere」セクションに統合。
2. **Activityセクション:** 完全に削除。

**変更ファイル:**
- `lib/screens/trace_detail_screen.dart`: AI Sketch UI削除、Step Count削除、Noise LevelをAtmosphereセクションへ移動
- `lib/widgets/trace_card.dart`: Step Count表示削除
- `lib/screens/capture_screen.dart`: 成功メッセージから「steps」削除

**バグ修正:**
- **シェア機能:** 一時ディレクトリが存在しない場合にエラーが発生する問題を修正（ディレクトリを自動作成）

---

### 🔄 2026-02-03 の変更履歴 (Phase 1完了)

**実装完了:**
1. **感覚フィードバック (Haptics):** シャッター時、溶解時、シェア時に触覚フィードバックを追加。
2. **シェア機能 (Trace Card):** `share_plus` を使用し、データ化された記憶をカード画像として共有。
3. **周辺音計測:** `noise_meter` で撮影時のdBを取得（Atmosphereセクションに統合）。
4. **歩数計測:** `pedometer` で歩数を取得（データ取得のみ、UI非表示）。
5. **AIストーリー生成:** Gemini APIで画像とデータから「物語」を生成。
6. **AIスケッチ削除:** コンセプト「Less is More」に基づき機能削除。

**ファイル構成の変更:**
- 新規: `lib/services/noise_service.dart`, `step_service.dart`
- 新規: `lib/widgets/shareable_trace_card.dart`
- 更新: `TraceLog` モデルに `noiseLevel`, `stepCount` 追加

### 🔄 2026-02-01 の変更履歴

### Gemini API サービス修正

**ファイル:** `lib/services/gemini_service.dart`

1. **モデル変更:** `gemini-pro-vision` → `gemini-2.5-flash`
   - `gemini-pro-vision` は廃止済み
   - `gemini-1.5-flash` はAPIキーによっては404エラー
   - `gemini-2.0-flash` / `gemini-2.0-flash-lite` はクォータ超過
   - **最終的に `gemini-2.5-flash` で動作確認**

2. **画像圧縮機能追加:**
   - 大きな画像（10MB以上）をAPI送信前に圧縮
   - 長辺を1024pxにリサイズ
   - JPEG品質80%でエンコード
   - 例: 11MB → 135KB に削減

3. **依存性注入対応（テスト用）:**
   - `http.Client` をコンストラクタで注入可能に
   - `apiKey` をコンストラクタで渡せるように変更

**使用モデル:** `gemini-2.5-flash`
**エンドポイント:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`

### macOS 位置情報パーミッション

**ファイル:** `macos/Runner/Info.plist`

追加したキー:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

**注意:** パーミッションダイアログが表示されない場合は、アプリを削除して再インストールするか、macOSを再起動してください。

### 位置情報サービス修正

**ファイル:** `lib/services/location_service.dart`

- macOSでは `geocoding` パッケージが完全にサポートされていないため、`getPlaceName()` をスキップするよう修正
- iOS/Androidでは正常に動作

### 追加したパッケージ

**ファイル:** `pubspec.yaml`

```yaml
dependencies:
  image: ^4.5.3          # 画像圧縮用

dev_dependencies:
  mocktail: ^1.0.4       # テスト用モック
```

### ユニットテスト作成

**ファイル:** `test/services/gemini_service_test.dart`

テスト内容:
- `isConfigured` のテスト
- `maskedApiKey` のテスト
- `analyzeImage` が正しいURL（gemini-2.5-flash）を呼び出すことを検証
- 成功レスポンスのラベルパース
- APIキー未設定時の動作
- APIエラー時の動作

---

## ⚠️ 既知の問題

### 1. macOS位置情報のパーミッション問題

**症状:**
```
Error getting location: User denied permissions to access the device's location.
```

**状況:**
- Info.plistにパーミッションキーは追加済み
- システム設定で位置情報サービスは有効
- アプリにチェックは入っている

**対処法:**
1. アプリを削除して再インストール
2. macOSを再起動
3. iOS/Android実機でテスト（そちらでは動作するはず）

### 2. macOSでジオコーディング非対応

**対応:** macOSでは `getPlaceName()` をスキップするよう実装済み。iOS/Androidでは正常に動作。

### 3. iOS実機でのテストができない

**症状:**
```
Developer App Certificate is not trusted
```

**対処法:**
1. iPhoneを再起動してから再試行
2. 別のBundle Identifierを使用
3. Appleサーバーとの通信問題（時間をおいて再試行）

---

## 🔲 今後のタスク — Phase 6: リリース準備

> **バックログ:** [BACKLOG.md](./BACKLOG.md) — TestFlightテスト修正項目
> **デザインシステム:** [FOOSTUDIO_DESIGN_SYSTEM_JP.md](./FOOSTUDIO_DESIGN_SYSTEM_JP.md)
> **タスク詳細:** [TASKS.md](./TASKS.md) — Phase 6A〜6E

| フェーズ | 内容 | ステータス |
|:--|:--|:--|
| 6A | バグ修正・品質改善（TestFlight Backlog） | ⏳ 準備中 |
| 6B | f∞studio デザインシステム適用 | ⏳ 未着手 |
| 6C | UI/UX 最終仕上げ（Settings, Trace Card, Typography） | ⏳ 未着手 |
| 6D | ストア申請準備（Screenshots, Metadata） | ⏳ 未着手 |
| 6E | 最終検証 & App Store / Google Play 申請 | ⏳ 未着手 |

### 優先度: 中

- **macOS位置情報の問題解決**（開発環境用、リリースには影響なし）

### ✅ 完了済み

- ~~スプラッシュ画面~~ → `flutter_native_splash` 設定済み
- ~~オンボーディング~~ → 3ページのチュートリアル実装済み
- ~~設定画面拡充~~ → About/Licenses/Privacy Policy追加済み
- ~~エラーフィードバック~~ → スタイル付きSnackbar実装済み
- ~~ストアメタデータ~~ → STORE_METADATA.md作成済み
- ~~アプリアイコン~~ → iOS/Android両対応のアイコン生成済み
- ~~Phase 5 UI Modernization~~ → Atmospheric Time、Tag Localization、全画面リデザイン完了
- ~~Multi-LLM Support~~ → Gemini/ChatGPT/Claude 3プロバイダー対応完了
- ~~タイムスタンプ分離~~ → capturedAt（撮影日時）/ createdAt（カード生成日時）分離完了
- ~~Reconstructed Memory改善~~ → プロンプト最適化・トークン削減完了
- ~~TestFlightアップロード~~ → 初回ビルド配布済み

---

## 🔧 開発コマンド

```bash
# プロジェクトディレクトリに移動
cd /Users/tai/Documents/development/App/Ambientrace

# 依存関係を取得
flutter pub get

# 分析（エラーチェック）
flutter analyze

# テスト実行
flutter test

# GeminiServiceのテストのみ実行
flutter test test/services/gemini_service_test.dart

# macOSで実行
flutter run -d macos

# iOSシミュレータで実行
open -a Simulator
flutter run

# クリーンビルド
flutter clean && flutter pub get && flutter run -d macos
```

---

## 📚 参考ドキュメント

- **企画書:** `/Users/tai/Documents/development/App/Ambientrace/docs/SPEC.md`
- **Claude Code指示書:** `/Users/tai/Documents/development/App/Ambientrace/docs/INSTRUCTIONS_FOR_CLAUDE.md`
- **バックログ:** `/Users/tai/Documents/development/App/Ambientrace/docs/BACKLOG.md`
- **デザインシステム:** `/Users/tai/Documents/development/App/Ambientrace/docs/FOOSTUDIO_DESIGN_SYSTEM_JP.md`
- **f∞studio企画書:** `/Users/tai/Documents/development/App/Reference/foostudio_KG+企画書_20251230.pdf`

---

## 💡 技術メモ

### AI API（Multi-LLM対応）

**Gemini（デフォルト）:**
- **使用モデル:** `gemini-2.5-flash`（画像解析・ストーリー生成）
- **無料枠:** 1分あたり15リクエスト、1日あたり1500リクエスト程度

**OpenAI (ChatGPT):**
- **使用モデル:** `gpt-4o-mini`（Vision対応・コスト効率良）
- **認証:** `Authorization: Bearer <API_KEY>`

**Anthropic (Claude):**
- **使用モデル:** `claude-sonnet-4-5-20250929`
- **認証:** `x-api-key: <API_KEY>`, `anthropic-version: 2023-06-01`

**共通アーキテクチャ:**
- `LlmService` 抽象基底クラス → `GeminiService` / `OpenAIService` / `ClaudeService`
- `ImageLabelingService` がプロバイダールーティングを管理
- 選択プロバイダーはSharedPreferencesに永続化
- **利用可能モデル確認コマンド:**
  ```bash
  curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_API_KEY" | jq '.models[] | select(.supportedGenerationMethods[] | contains("generateContent")) | .name'
  ```

### プラットフォーム別制限

| 機能 | macOS | iOS | Android |
|------|-------|-----|---------|
| カメラ | ❌ 非対応（画像ピッカー使用） | ✅ | ✅ |
| 位置情報 | ⚠️ パーミッション問題 | ✅ | ✅ |
| ジオコーディング | ❌ 非対応（スキップ） | ✅ | ✅ |
| Gemini API | ✅ | ✅ | ✅ |
| OpenAI API | ✅ | ✅ | ✅ |
| Claude API | ✅ | ✅ | ✅ |
| 天気API | ✅ | ✅ | ✅ |
| カラーパレット | ✅ | ✅ | ✅ |

### その他

- ML KitはiOS/Android実機専用。シミュレータ/macOSでは動作しない
- Open-Meteo APIは無料でAPIキー不要
