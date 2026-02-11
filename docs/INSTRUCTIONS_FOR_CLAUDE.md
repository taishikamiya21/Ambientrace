# Claude Code への指示書 (Phase 6: リリース準備)

Phase 1〜5の主要機能は完了。TestFlightアップロード済み。
**目標:** テスト修正 → デザイン適用 → 最終検証 → App Store / Google Play リリース。

---

## コンテキスト

**完了済み:**
- ✅ Phase 1: コア機能（カメラ、Gemini連携、位置情報、天気）
- ✅ Phase 2: コンセプト鮮明化（AI Sketch削除、Step Count非表示）
- ✅ Phase 3: プロダクト化（スプラッシュ、オンボーディング、設定画面拡充）
- ✅ Phase 3.5: UI/UX洗練（エラーフィードバック、ストアメタデータ）
- ✅ Phase 5（部分）: Atmospheric Time、Tag Localization、全画面リデザイン
- ✅ Phase 5（部分）: Multi-LLM Support（Gemini / ChatGPT / Claude 3プロバイダー対応）
- ✅ Phase 5（部分）: タイムスタンプ分離、Reconstructed Memory改善
- ✅ TestFlightアップロード完了

**Phase 6 で対応する残課題:**
- ⏳ TestFlightテストで発見された修正項目（→ `docs/BACKLOG.md`）
- ⏳ f∞studio デザインシステムの適用
- ⏳ Settings Screen モダン化
- ⏳ Trace Card Redesign（Meaning > Time）
- ⏳ Typography & Color リファイン
- ⏳ Android実機テスト
- ⏳ スクリーンショット撮影 & ストア申請

---

## ⚠️ タスク実行順序（厳守）

以下の順序で作業を進めること。**依存関係を無視してスキップしないこと。**

### Phase 6A: バグ修正・品質改善（最優先）

**対象:** `docs/BACKLOG.md` に記載された修正項目

1. `BACKLOG.md` を確認し、`Critical` → `High` → `Medium` の順に対応
2. 各項目の修正後、`BACKLOG.md` のステータスを `Done` に更新
3. すべての Critical / High 項目が完了したら 6B に進む

### Phase 6B: f∞studio デザインシステム適用

**参照:** `docs/FOOSTUDIO_DESIGN_SYSTEM_JP.md`

f∞studio デザインシステムの以下の要素をアプリに適用する：

1. **カラーシステム:**
   - Canvas Primary: `#0A0A0F`（既に使用中、確認のみ）
   - Canvas Secondary: `#1A1A2E`（ボトムシート、ダイアログ背景）
   - Accent Neon: `#DFFF4F`（画面全体の5%以下、CTA・アクティブ状態のみ）
   - テキスト不透明度スケール（hero: 1.0 → whisper: 0.1 の9段階）
   - サーフェス不透明度スケール（elevated: 0.12 → faint: 0.03）

2. **タイポグラフィ:**
   - Primary: Inter（w200〜w800）— ダークモードでは w700以上を原則使用しない
   - Technical: JetBrains Mono / Roboto Mono — メタデータ、タイムスタンプ
   - 日本語: Noto Sans JP（見出し w500、本文 w300）
   - ダークモードの見出しは Thin（w200）〜 Medium（w500）の範囲

3. **コンポーネント:**
   - カード: ダーク→ `white@0.05` 背景、`12px` 角丸、シャドウなし
   - チップ/タグ: ピル型（999px）、`white@0.12` ボーダー
   - ボタン: ピル型、`white@0.1` 背景、uppercase

### Phase 6C: UI/UX 最終仕上げ

Phase 5 の残タスクを統合して完了させる。

1. **Settings Screen モダン化:**
   - iOS: CupertinoListSection ベースの標準レイアウト
   - Android: Material 3 の ListTile ベース
   
2. **Trace Card Redesign（Meaning > Time）:**
   - Hero: Ambient Label（最も代表的なタグ）をカードタイトルに
   - Secondary: Atmospheric Time をサブタイトルに
   - Footer: 正確な時刻、場所、天気をメタデータとして控えめに表示
   
3. **Typography & Color リファイン:**
   - デザインシステムの不透明度スケールに沿ったコントラスト調整
   - 情報階層の最終チェック

4. **Micro-interactions & Haptics:**
   - ボタン押下時の `translate(1px, 1px)` マイクロアニメーション
   - カードホバー/タップ時のフィードバック

### Phase 6D: ストア申請準備

1. **スクリーンショット撮影:**
   - Home（履歴一覧）
   - Capture（カメラビュー）
   - Dissolve（溶解アニメーション）
   - Detail（Trace Card表示）
   - Share（シェアカード）

2. **メタデータ最終確認:** `docs/STORE_METADATA.md`
3. **プライバシーポリシーURL:** GitHub Pages で公開確認

### Phase 6E: 最終検証 & 申請

1. Android実機テスト（パーミッション、機能確認）
2. TestFlight再配布（修正版をアップロード）
3. 最終動作確認
4. App Store Connect / Google Play Console 申請

---

## 維持すべき機能（復活させない）

| 機能 | 状態 | 理由 |
| :--- | :--- | :--- |
| **AI Sketch** | ❌ 削除維持 | 「データから想像する」コンセプトと矛盾 |
| **Step Count** | ❌ 非表示維持 | フィットネスアプリではない |

---

## 参照ドキュメント

| ドキュメント | パス | 用途 |
|:--|:--|:--|
| **バックログ** | `docs/BACKLOG.md` | TestFlight修正項目 |
| **デザインシステム** | `docs/FOOSTUDIO_DESIGN_SYSTEM_JP.md` | UI/UXの設計基準 |
| **タスク管理** | `docs/TASKS.md` | 全タスクの進捗 |
| **ストアメタデータ** | `docs/STORE_METADATA.md` | ストア申請用テキスト |
| **ステータス** | `docs/STATUS.md` | 技術詳細・変更履歴 |
| **仕様書** | `docs/SPEC.md` | コンセプト・機能仕様 |

---

## 最終成果物

アプリは **リリース候補版 (Release Candidate - RC)** として、以下の品質を満たすこと:
- 安定的（クラッシュしない）
- 美しい（f∞studio デザインシステムに準拠したUI）
- 機能的（全機能が正常に動作）
- ストア準備完了（スクリーンショット、メタデータ、プライバシーポリシー）
