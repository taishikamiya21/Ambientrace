# Claude Code への指示書 (Phase 5: UI Modernization & Store準備)

Phase 1〜4が完了し、Phase 5（UI/UX Modernization）が進行中です。
**目標:** UI品質の最終仕上げと、App Store / Google Play への公開準備を整えること。

## コンテキスト

**完了済み:**
- ✅ Phase 1: コア機能（カメラ、Gemini連携、位置情報、天気）
- ✅ Phase 2: コンセプト鮮明化（AI Sketch削除、Step Count非表示）
- ✅ Phase 3: プロダクト化（スプラッシュ、オンボーディング、設定画面拡充）
- ✅ Phase 3.5: UI/UX洗練（エラーフィードバック、ストアメタデータ）
- ✅ Phase 5（部分）: Atmospheric Time、Tag Localization、全画面リデザイン
- ✅ Phase 5（部分）: Multi-LLM Support（Gemini / ChatGPT / Claude 3プロバイダー対応）
- ✅ Phase 5（部分）: タイムスタンプ分離（写真撮影日時 / カード生成日時）
- ✅ Phase 5（部分）: Reconstructed Memory改善（プロンプト最適化・トークン削減）

**残りの課題:**
- ⏳ Settings Screen モダン化
- ⏳ Typography & Color リファイン
- ⏳ Android実機テスト
- ⏳ スクリーンショット撮影
- ⏳ ストア申請

---

## Task 1: アプリアイコン作成（優先度：高）

**対象:** `assets/icon/`

1. **アイコン画像を作成:**
   - サイズ: 1024x1024 PNG
   - ファイル名: `app_icon.png`
   - 配置先: `assets/icon/app_icon.png`

2. **デザインガイドライン:**
   - コンセプト: 「空気の痕跡」「溶ける」「ミニマル」
   - 背景色: #0A0A0F（ダークテーマ）
   - 参考: `assets/icon/README.md`

3. **生成コマンド:**
   ```bash
   dart run flutter_launcher_icons
   ```

---

## Task 2: 実機での検証（優先度：高）

**対象:** iOS & Android（物理デバイス）

1. **パーミッション確認:**
   - カメラ、位置情報、マイク（ノイズ計測用）の許可フロー
   - 拒否時のグレースフル・デグラデーション

2. **機能確認:**
   - シェア機能（Trace Card生成）
   - ジオコーディング（地名取得）
   - オンボーディングフロー

---

## Task 3: スクリーンショット撮影

**対象:** App Store / Google Play 用

撮影する画面:
1. ホーム（履歴一覧）
2. キャプチャ（カメラビュー）
3. 溶解アニメーション
4. 詳細画面（Trace Card）
5. シェア機能

---

## Task 4: ストア申請準備

1. **必要なもの:**
   - プライバシーポリシーURL
   - サポートURL（GitHub Issues など）
   - 説明文・キーワード → `docs/STORE_METADATA.md` 参照

2. **App Store Connect / Google Play Console:**
   - アプリ情報登録
   - スクリーンショットアップロード
   - 審査申請

---

## Task 5: UI/UX Modernization (Phase 5)

ユーザーが直感的に利用できるよう、以下のガイドラインに従ってUIを刷新します。

### 1. Guideline References
- **iOS Human Interface Guidelines (HIG):** [https://developer.apple.com/jp/design/human-interface-guidelines/](https://developer.apple.com/jp/design/human-interface-guidelines/)
- **Material Design 3 (Android):** [https://m3.material.io/](https://m3.material.io/)
- **Android Design Guide:** [https://developer.android.com/design?hl=ja](https://developer.android.com/design?hl=ja)

### 2. OOUI (Object-Oriented UI) Principles
- **オブジェクト中心:** タスクベース（動詞）ではなく、オブジェクト（名詞）を起点にする。
    - 悪い例: 「撮影する」「探す」メニューが並列
    - 良い例: アプリを開くと「Trace（記憶の断片）」のリストがあり、その詳細を見たり、新しいTraceを追加（撮影）したりする。
- **Direct Manipulation:** オブジェクトを直接操作する感覚（スワイプ削除、タップして詳細展開）。

### 3. Implementation Goals
- **Navigation:**
    - iOS: Tab Bar, Large Titles, Modal Sheets.
    - Android: Navigation Bar, Top App Bar (Material 3 style).
- **Home Screen (Trace List):**
    - リストアイテムは「Trace」オブジェクトそのものとしてデザイン。
    - 日付、場所、色がひと目でわかるカード型など。
- **Capture Screen:**
    - 「カメラ」モードと「ライブラリ」モードのシームレスな切り替え。
    - 没入感のある全画面ビューファインダー。
- **Typography & Color:**
    - プラットフォームごとのシステムフォント（San Francisco / Roboto）を適切に使用。
### 4. Tagging & AI ✅ 実装済み
- **Multi-LLM Support:** ✅ 完了
    - `LlmService` 抽象基底クラス → `GeminiService` / `OpenAIService` / `ClaudeService`
    - `ImageLabelingService` がプロバイダールーティングを管理（`activeLlmService`）
    - 設定画面に3択プロバイダーセレクター + 各プロバイダーのAPIキー管理
- **Tag Localization (No-AI Fallback):** ✅ 完了
    - ML Kitラベルの日英自動切替（37エントリ）
- **タイムスタンプ分離:** ✅ 完了
    - `capturedAt`（写真撮影日時: EXIF or カメラ時刻）と `createdAt`（カード生成日時）を分離管理
    - Reconstructed Memoryには `capturedAt` を使用
- **Reconstructed Memory:** ✅ 改善済み
    - プロンプト最適化（2文・文字数制限）、トークン使用量削減

### 5. Trace Card Concept Redesign
- **Hierarchy Shift (Meaning > Time):**
    -   **Main Content (Hero):** 抽出された「意味情報（Ambient Tags）」をカードのメインタイトルとして大きく表示してください。
    -   ユーザーにとって最も重要なのは「いつ撮ったか（Afternoon）」ではなく、「何を撮ったか/感じたか（やわらかな午後の陽射し）」です。
    -   複数のタグがある場合、最初のタグまたは最も代表的なタグをタイトルとして使用してください。
- **Atmospheric Time (Secondary):**
    -   「Afternoon」や「Late Night」などの時間帯表現は、サブタイトルや補足情報として扱ってください。
    -   正確な時刻（21:30）はさらに控えめに（metadataとして）表示してください。
- **Visual Focus:**
    1.  **Meaning:** Ambient Label (Title)
    2.  **Feeling:** Color Palette (Visual bar/gradient)
    3.  **Context:** Atmospheric Time & Location (Subtitle/Footer)

---

## 維持すべき機能（復活させない）

| 機能 | 状態 | 理由 |
| :--- | :--- | :--- |
| **AI Sketch** | ❌ 削除維持 | 「データから想像する」コンセプトと矛盾 |
| **Step Count** | ❌ 非表示維持 | フィットネスアプリではない |

---

## 参照ドキュメント

- **タスク管理:** `docs/TASKS.md`
- **ストアメタデータ:** `docs/STORE_METADATA.md`
- **作業ログ:** `docs/WORK_LOG_2026-02-03.md`
- **ステータス:** `docs/STATUS.md`

---

## 最終成果物

アプリは **リリース候補版 (Release Candidate - RC)** として、以下の品質を満たすこと:
- 安定的（クラッシュしない）
- 美しい（コンセプトに沿ったミニマルなUI）
- 機能的（全機能が正常に動作）
