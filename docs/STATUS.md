# Ambientrace 開発ステータス

**最終更新:** 2026-02-03 13:40 JST

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
│   │   └── settings_screen.dart     # 設定画面（APIキー入力）
│   ├── services/
│   │   ├── storage_service.dart     # ローカルストレージ
│   │   ├── location_service.dart    # GPS・位置情報
│   │   ├── color_service.dart       # カラーパレット抽出
│   │   ├── weather_service.dart     # 天気API（Open-Meteo）
│   │   ├── image_labeling_service.dart  # 画像ラベリング統合
│   │   └── gemini_service.dart      # Gemini API連携 ✅ 動作確認済み
│   └── widgets/
│       ├── trace_card.dart          # ログカード表示
│       └── dissolve_animation.dart  # 写真→データ溶解アニメーション
├── test/
│   ├── widget_test.dart
│   └── services/
│       └── gemini_service_test.dart # GeminiService ユニットテスト
├── docs/
│   ├── SPEC.md                      # 企画書・仕様書
│   ├── STATUS.md                    # このファイル
│   └── INSTRUCTIONS_FOR_CLAUDE.md   # Claude Code用指示書
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
| **Gemini画像ラベリング** | gemini-2.5-flash で画像からラベル抽出 | ✅ 動作確認済み |
| **画像圧縮** | API送信前に画像を圧縮（1024px, JPEG 80%） | ✅ |
| **溶解アニメーション** | 写真がデータに変換されるビジュアル演出 | ✅ |
| **ログ一覧** | 日付グループ化、検索、フィルター機能 | ✅ |
| **詳細画面** | トレースの全データ表示、削除機能 | ✅ |
| **設定画面** | Gemini APIキーの入力・管理 | ✅ |
| **設定画面** | Gemini APIキーの入力・管理 | ✅ |
| **ユニットテスト** | GeminiServiceのテスト | ✅ |
| **感覚フィードバック** | シャッター・アニメーション・シェア時のハプティクス | ✅ |
| **シェア機能** | "Trace Card" 画像生成とSNS共有 | ✅ |
| **周辺音計測** | 撮影時の騒音レベル(dB)測定（macOS不可） | ✅ |
| **歩数計測** | 撮影時の歩数取得（macOS不可） | ❌ UI非表示（データは収集継続） |
| **AIスケッチ生成** | トレースデータから抽象画を生成 | ❌ 削除（Phase 2で「想像」を重視） |

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

## 🔲 今後のタスク

### 優先度: 高

1. **iOS/Android 実機テスト**
   - カメラ機能の動作確認
   - ノイズ計測・歩数計測（iOS/Androidのみ）の確認
   - シェア機能（画像生成・SNS連携）の確認
   - 位置情報・ジオコーディングの権限確認

2. **ストア公開準備**
   - アプリアイコン作成（iOS/Android各サイズ）
   - スクリーンショット撮影
   - プライバシーポリシーの作成
   - App Store / Google Play Console への登録

### 優先度: 中

3. **macOS位置情報の問題解決**
   - デバッグして原因特定（開発環境用として修正推奨）

4. **UI/UXの改善**
   - エラー時のユーザーフィードバック改善（トースト表示など）
   - ラベル表示の視覚的ブラッシュアップ

### 優先度: 低（将来の拡張）

5. **パフォーマンス最適化**
   - アプリ起動速度の改善
   - 画像処理のさらなる軽量化

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
- **f∞studio企画書:** `/Users/tai/Documents/development/App/Reference/foostudio_KG+企画書_20251230.pdf`

---

## 💡 技術メモ

### Gemini API

- **使用モデル:** `gemini-2.5-flash`（2026年2月時点で最新の高速マルチモーダルモデル）
- **無料枠:** 1分あたり15リクエスト、1日あたり1500リクエスト程度
- **クォータ超過時:** 新しいAPIキーを別プロジェクトで生成すると無料枠がリセット
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
| 天気API | ✅ | ✅ | ✅ |
| カラーパレット | ✅ | ✅ | ✅ |

### その他

- ML KitはiOS/Android実機専用。シミュレータ/macOSでは動作しない
- Open-Meteo APIは無料でAPIキー不要
