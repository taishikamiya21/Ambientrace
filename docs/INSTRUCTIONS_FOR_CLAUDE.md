# Claude Code への指示書 (Phase 4: ストア公開準備)

Phase 3〜3.5（プロダクト化・UI/UX洗練）が完了しました。アプリは現在、リリース候補版（RC）の品質に近づいています。
**目標:** 実機テストを完了し、App Store / Google Play への公開準備を整えること。

## コンテキスト

**完了済み:**
- ✅ Phase 1: コア機能（カメラ、Gemini連携、位置情報、天気）
- ✅ Phase 2: コンセプト鮮明化（AI Sketch削除、Step Count非表示）
- ✅ Phase 3: プロダクト化（スプラッシュ、オンボーディング、設定画面拡充）
- ✅ Phase 3.5: UI/UX洗練（エラーフィードバック、ストアメタデータ）
- 🚀 **Phase 5 (New):** UI Modernization (OOUI, HIG, Material 3)

**残りの課題:**
- ⏳ アプリアイコン画像の作成・配置
- ⏳ 実機（iOS/Android）でのテスト
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
### 4. Tagging & AI (New Requirements)
- **Multi-LLM Support:**
    - `GeminiService` だけでなく、`OpenAIService` (ChatGPT) と `ClaudeService` (Anthropic) のAPIキーも設定可能にしてください。
    - ユーザーがどのAIを使用するか設定画面で選択できるようにしてください。
- **Tag Localization (No-AI Fallback):**
    - AIキー未設定時（ML Kit使用時）のタグ生成において、ユーザーのシステム言語（日本語/英語など）に合わせて出力してください。
    - 現在の実装 (`_convertToAmbientLabels` in `image_labeling_service.dart`) は英語固定ですが、これを多言語対応（`intl` パッケージまたはローカルマッピング）してください。
    - google_mlkit_translation APIの利用も検討してください。

### 5. Trace Card Concept Redesign
- **脱・ログ思考:**
    - 現在のUIは「撮影時刻（21:30）」が一番目立っていますが、これは「記録（ログ）」的であり「Ambient（雰囲気）」ではありません。
- **"Atmospheric Time" (曖昧な時間):**
    - 正確な時刻よりも、「深夜 (Late Night)」「早朝 (Dawn)」「夕暮れ (Dusk)」といった「時間帯の雰囲気」をメインに表示してください。
    - 正確な時刻は、詳細情報の隅に小さく表示する程度に留めてください。
- **Focus:**
    - メインビジュアル: カラーパレット（色の記憶）
    - サブ: Atmospheric Time & Ambient Labels（言葉の記憶）

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
