# f∞ studio デザインシステム v2.0

**Boundary Lab — 境界の実験室**

> 写真の「境界」を探求する実験室から生まれたデザインシステム。
> 暗いキャンバスの上に、不透明度の階層で情報を浮かび上がらせる。
> ネオンライムは「発見の瞬間」にのみ灯る。

---

## 1. デザイン哲学

### 1.1 コンセプト — Boundary Lab（境界の実験室）

f∞ studio は写真の「境界」を探求するアートコレクティブである。v2.0 では、v1.0 の "Experimental Industrialism（実験的工業主義）" を発展させ、**Boundary Lab（境界の実験室）** というコンセプトを新たに掲げる。

工場から実験室へ。知的で静謐な空間に、実験の痕跡と発見の瞬間が共存する。f∞ studio のインターフェースもまた、境界上の存在である。

### 1.2 5つの基本原則

| # | 原則 | 説明 |
|:--|:-----|:-----|
| 1 | **Boundary Lab（境界の実験室）** | 工場から実験室へ。知的で静謐な空間に、実験の痕跡と発見の瞬間が共存する。f∞ studio は写真の「境界」を探求する実験室であり、そのインターフェースもまた境界上の存在である。 |
| 2 | **Pan-graphic Continuum（汎写真的連続体）** | 不透明度のグラデーション、軽重のタイポグラフィ、境界のフェード。デザインの中に「境界の揺らぎ」を体現する。明確な区切りよりも、連続的な変化を重視する。 |
| 3 | **Dark-First Research Canvas（暗室のキャンバス）** | 暗いキャンバスの上に、不透明度の階層で情報を浮かび上がらせる。ネオンライムは「発見の瞬間」にのみ灯る指標灯。大面積での使用は禁止。 |
| 4 | **Typographic Duality（タイポグラフィの二面性）** | 極細（w200）と太字（w600+）の共存。「記録」の静けさと「宣言」の力強さ、「問い」の繊細さと「秩序」の明確さ。二つの極が一つのシステムの中で対話する。 |
| 5 | **Structured Experimentation（構造化された実験）** | グリッド＋等幅フォント＝実験プロトコル。構造は実験を支える骨格であり、その中での逸脱にこそ価値がある。 |

### 1.3 キーワード

```
research / boundary / quiet-intensity / dark-canvas / precision / experimental / pan-graphic
研究 / 境界 / 静かな強度 / 暗いキャンバス / 精密 / 実験的 / 汎写真的
```

---

## 2. カラーシステム

### 2.1 キャンバスカラー（Canvas Colors）

| トークン | Hex | 用途 |
|:---|:---|:---|
| `color.canvas.primary` | `#0A0A0F` | **Deep Canvas** — 微かな青みを帯びた漆黒。全画面の主背景色。暗室のような静謐さ。 |
| `color.canvas.secondary` | `#1A1A2E` | **Surface** — 浮き上がったサーフェス、ボトムシート、ダイアログの背景。 |
| `color.canvas.light` | `#FFFFFF` | **White** — ライトモードの主背景色。 |
| `color.canvas.cream` | `#E8E6D9` | **Cream** — ライトモードの代替背景。紙的な質感。 |

### 2.2 アクセントカラー

| トークン | Hex | 用途 |
|:---|:---|:---|
| `color.accent.neon` | `#DFFF4F` | **Neon Lime** — 「発見の瞬間」を示す指標灯。画面全体の **5%以下** の面積に限定。CTA、アクティブ状態、重要な指標にのみ使用。 |
| `color.accent.neon-muted` | `rgba(223, 255, 79, 0.15)` | ネオンの控えめな背景使用（選択状態のチップ等） |

#### ネオンライム使用ルール（厳守）

- 背景色としての大面積使用は **禁止**（v1.0 の `card--neon` は廃止）
- ボタン背景には使用しない（ボーダーまたはテキスト色としてのみ）
- ダークモードでのアクティブ状態インジケーター、ホバー時のテキスト色、CTA ボーダーに限定
- ライトモードではフォーカスリング、アクティブリンクの下線に使用

### 2.3 機能カラー

| トークン | Hex | 用途 |
|:---|:---|:---|
| `color.functional.error` | `#FF4F4F` | エラー、削除、警告 |
| `color.functional.success` | `#4FFF8C` | 成功、完了、確認 |
| `color.functional.warning` | `#FFD24F` | 注意、保留、未処理 |

### 2.4 テキスト不透明度スケール（ダークモード・白ベース）

| トークン | Alpha | 用途 |
|:---|:---|:---|
| `opacity.text.hero` | `1.0` | ヒーロータイトル、最重要コンテンツ |
| `opacity.text.high` | `0.85` | 見出し、強調テキスト |
| `opacity.text.body` | `0.7` | 本文テキスト、説明文 |
| `opacity.text.secondary` | `0.6` | セクション説明、補足テキスト |
| `opacity.text.tertiary` | `0.5` | アイコンボタン、メタデータ |
| `opacity.text.caption` | `0.4` | サブタイトル、タグライン |
| `opacity.text.muted` | `0.3` | 日付、時刻などの控えめな情報 |
| `opacity.text.ghost` | `0.2` | ボーダー的テキスト、非活性要素 |
| `opacity.text.whisper` | `0.1` | 最も控えめな要素、ヒント |

### 2.5 サーフェス不透明度スケール（白ベース）

| トークン | Alpha | 用途 |
|:---|:---|:---|
| `opacity.surface.elevated` | `0.12` | 選択済み要素、強調サーフェス |
| `opacity.surface.container` | `0.08` | カード背景、コンテナ |
| `opacity.surface.subtle` | `0.05` | 控えめなカード、情報カード |
| `opacity.surface.faint` | `0.03` | 最も控えめなサーフェス |

### 2.6 ボーダー不透明度スケール（白ベース）

| トークン | Alpha | 用途 |
|:---|:---|:---|
| `opacity.border.strong` | `0.3` | 選択済み要素、強調ボーダー |
| `opacity.border.medium` | `0.2` | アクティブ状態のボーダー |
| `opacity.border.default` | `0.12` | 標準的なカード・コンテナのボーダー |
| `opacity.border.subtle` | `0.08` | 控えめなボーダー |
| `opacity.border.faint` | `0.05` | 最も控えめなボーダー |

### 2.7 テクスチャ＆エフェクト

**ノイズオーバーレイ**
v1.0 から維持。不透明度 `0.05`〜`0.10` の range で使用。暗いキャンバスにフィルム的なテクスチャを付与する。

**ハードシャドウ — ライトモード限定**
ダークモードでは不透明度とグラデーションで深度を表現する。

```css
/* ライトモードのみ */
.light-mode .shadow {
  box-shadow: 4px 4px 0px #111111;
}
/* ダークモードではシャドウなし — 不透明度で深度を表現 */
```

**Backdrop Blur（新規許容）**
`backdrop-filter: blur()` を新たに許容する。Pan-graphy における「パンフォーカスの対概念としてのボケ」を表現。ダークモードのオーバーレイ、モーダル背景に使用可。

> **注意:** ソフトドロップシャドウ（blur 付き `box-shadow`）は引き続き **禁止**。`backdrop-filter` の blur とは明確に区別すること。

### 2.8 ライトモードカラー

| トークン | 値 | 用途 |
|:---|:---|:---|
| `color.text.on-light` | `#111111` | ライトモードのテキスト色 |
| `color.border.on-light` | `#111111` | ライトモードのボーダー色 |
| `color.shadow.on-light` | `#111111` | ライトモードのハードシャドウ色 |

---

## 3. タイポグラフィ

### 3.1 フォントファミリー

| 用途 | フォントスタック | 備考 |
|:---|:---|:---|
| **見出し・本文（Primary）** | **Inter**（w200〜w800）, System Sans-Serif | v2.0 では一つのファミリーでウェイトの幅を活かす |
| **メタデータ / 技術用（Technical）** | **JetBrains Mono**, **Roboto Mono**, **SF Mono**, System Monospace | 実験プロトコルの記録。等幅の秩序。 |

> **v1.0 からの変更:** Archivo Black は廃止。Inter がウェイトバリエーション（w200〜w800）によって、ディスプレイから本文まですべてのニーズをカバーする。

### 3.2 タイプスケール

| トークン | サイズ | ウェイト | 字間 | 用途 |
|:---|:---|:---|:---|:---|
| `type.display` | 48px | Thin（200） | -0.02em | ヒーローセクション。問いかけるような繊細さ。 |
| `type.headline` | 32px | Light（300） | -0.01em | ページタイトル。語りかけるような軽さ。 |
| `type.title` | 24px | Medium（500） | 0 | セクションヘッダー、カードタイトル。注目を集める。 |
| `type.subtitle` | 18px | Light（300） | 0 | サブヘッダー、導入テキスト |
| `type.body` | 16px | Light（300） | 0 | 標準的な本文テキスト。読みやすさと軽やかさの両立。 |
| `type.label` | 14px | Medium（500） | 0.05em | ボタン、ナビゲーション（UPPERCASE） |
| `type.section` | 12px | SemiBold（600） | 0.15em | セクションタイトル（UPPERCASE）。実験プロトコルの見出し。 |
| `type.mono` | 12px | Regular（400） | 0.05em | メタデータ、タイムスタンプ、技術スペック |

### 3.3 フォントウェイト意味体系

| ウェイト | 値 | 意味 | 使用コンテキスト |
|:---|:---|:---|:---|
| **Thin** | w200 | 問い（Question） | Display 見出し、ヒーローテキスト |
| **Light** | w300 | 語り（Narrative） | 本文、説明文、サブタイトル |
| **Medium** | w500 | 注目（Attention） | タイトル、ボタン、ラベル |
| **SemiBold** | w600 | 秩序（Order） | セクションタイトル、カテゴリヘッダー |
| **Bold** | w700 | 宣言（Declaration） | **ライトモード限定**。ライトモードの見出し |
| **ExtraBold** | w800 | 強調宣言 | **ライトモード限定**。特に強いインパクトが必要な場面 |

> **ダークモードでは w700 以上を原則使用しない。** 暗いキャンバスの上では、細いウェイトが知的で実験的な印象を生む。太いウェイトはライトモードの「構造的強度」に限定する。

### 3.4 日欧混植ルール

| 用途 | 日本語フォント | 欧文フォント | 備考 |
|:---|:---|:---|:---|
| 見出し | Noto Sans JP Medium（w500） | Inter Medium（w500） | v1.0 の Bold/Black から軽量化 |
| 本文 | Noto Sans JP Light（w300） | Inter Light（w300） | 読みやすさと軽やかさの両立 |
| 技術テキスト | — | JetBrains Mono Regular（w400） | 変更なし |

**混植時のサイズ調整:**
- 日本語フォントは欧文フォントの約 95% のサイズに設定
- `line-height` は日本語の高さに合わせて `1.8`〜`2.0` を基本とする
- 欧文と日本語の間には半角スペースを挿入

### 3.5 テキストスタイル

**UPPERCASE ルール:**
- `type.label`（ボタン、ナビゲーション）: `text-transform: uppercase`
- `type.section`（セクションタイトル）: `text-transform: uppercase`
- `type.mono`（メタデータ）: 必要に応じて `text-transform: uppercase`
- その他のテキストスタイルでは UPPERCASE を使用しない

**行送り（Line Height）:**

| トークン | line-height | 備考 |
|:---|:---|:---|
| `type.display` | 1.1 | タイトな行送り。視覚的インパクト重視 |
| `type.headline` | 1.2 | ゆとりを持たせた見出し |
| `type.title` | 1.3 | 適度な間隔 |
| `type.subtitle` | 1.4 | 読みやすさを確保 |
| `type.body` | 1.6 | 本文の読みやすさを最優先 |
| `type.label` | 1.0 | 単行。ボタン内テキスト |
| `type.section` | 1.0 | 単行。セクションラベル |
| `type.mono` | 1.4 | メタデータの可読性 |

---

## 4. レイアウト＆スペーシング

### 4.1 グリッドシステム

グリッドは「見せる構造」として機能する。v1.0 から引き続き、可視グリッドライン、意図的な非対称、装飾としてのグリッドを活用する。

**グリッドラインの表現（モード別）:**

| モード | グリッドライン |
|:---|:---|
| ライトモード | `1px solid #111111` または `rgba(255,255,255,0.2)` |
| ダークモード | `1px solid rgba(255,255,255,0.12)` |

**グリッド構成:**
- **Mobile（〜767px）:** 4 カラム、マージン 16px、ガター 16px
- **Tablet（768px〜1023px）:** 8 カラム、マージン 24px、ガター 20px
- **Desktop（1024px〜）:** 12 カラム、マージン 32px、ガター 24px

### 4.2 スペーシングスケール（4px 基準・10段階）

| トークン | 値 | 用途 |
|:---|:---|:---|
| `space.xxs` | 4px | 密接した要素間（アイコン間隔） |
| `space.xs` | 8px | タグ間隔、関連要素間 |
| `space.sm` | 12px | コンポーネント内の小さなギャップ |
| `space.md` | 16px | コンポーネント内パディング |
| `space.lg` | 20px | コンポーネント間のスペーシング |
| `space.xl` | 24px | セクション間の区切り |
| `space.2xl` | 32px | 大セクションスペーシング |
| `space.3xl` | 48px | 主要レイアウトブロック間 |
| `space.4xl` | 64px | ページレベルの区切り |
| `space.5xl` | 96px | ヒーロースペーシング |

### 4.3 ボーダー＆ラディウス

#### ボーダー — モード別体系

**ライトモード:**

| プロパティ | 値 | 備考 |
|:---|:---|:---|
| デフォルトボーダー | `1px solid #111111` | 明確な境界線 |
| 強調ボーダー | `2px solid #111111` | ボタン、重要なカード |
| シャドウ | `4px 4px 0px #111111` | ハードシャドウ健在 |

**ダークモード:**

| プロパティ | 値 | 備考 |
|:---|:---|:---|
| デフォルトボーダー | `1px solid rgba(255,255,255,0.12)` | 控えめだが認識可能 |
| 強調ボーダー | `1px solid rgba(255,255,255,0.2)` | アクティブ、選択状態 |
| シャドウ | なし | 不透明度とグラデーションで深度を表現 |

#### ボーダーラディウス — 5段階

| スタイル | 値 | 用途 | 備考 |
|:---|:---|:---|:---|
| **Sharp（シャープ）** | `0px` | 画像、大型コンテナ（ライトモード） | 工業的な直線性 |
| **Technical（テクニカル）** | `4px` | 入力フィールド、コードブロック | 機能的な最小限の丸み |
| **Container（コンテナ）** | `12px` | ダークモードのカード、情報カード | 暗いキャンバス上での柔らかさ |
| **Surface（サーフェス）** | `16px` | ダークモードのコンテナ、ストーリーブロック | 浮遊感のある要素 |
| **Pill（ピル）** | `999px` | ボタン、チップ、タグ | 完全な丸み |

> **v1.0 からの変更:** v1.0 の「3段階厳守（0px / 4px / 999px）」から拡張。ライトモードでは引き続き Sharp / Technical / Pill の3段階を基本とするが、ダークモードでは Container（12px）と Surface（16px）を追加し、暗いキャンバス上での視認性と柔らかさを確保する。

## 5. UIコンポーネント

> すべてのコンポーネントは「Boundary Lab」の哲学に従う。
> **ダークモードがプライマリ**。ライトモードはセカンダリバリアントとして提供。
> ダークモード: シャドウなし、不透明度ベース、角丸 12px〜16px。
> ライトモード: ハードシャドウ（blur なし）、ソリッドボーダー、シャープな角。

---

### 5.1 ボタン

#### ダークモード（プライマリ）

**Primary Button（ダーク）:**

| プロパティ | 値 |
|:---|:---|
| 背景色 | `rgba(255, 255, 255, 0.1)` |
| テキスト色 | `rgba(255, 255, 255, 0.85)` |
| 形状 | ピル型（`border-radius: 999px`） |
| パディング | `12px 32px` |
| フォント | `type.label`（14px / Medium 500 / 字間 0.05em） |
| テキスト変換 | `uppercase` |
| ボーダー | `1px solid rgba(255, 255, 255, 0.12)` |
| ホバー | 背景 → `rgba(255, 255, 255, 0.15)`、テキスト → `white` |
| アクティブ | `transform: translate(1px, 1px)` |
| シャドウ | なし |

**CTA Button（ダーク）— 唯一のネオン使用ボタン:**

| プロパティ | 値 |
|:---|:---|
| 背景色 | `transparent` |
| テキスト色 | `#DFFF4F` |
| ボーダー | `1px solid #DFFF4F` |
| 形状 | ピル型（`border-radius: 999px`） |
| ホバー | 背景 → `rgba(223, 255, 79, 0.1)` |
| アクティブ | `transform: translate(1px, 1px)` |

**Secondary Button（ダーク）:**

| プロパティ | 値 |
|:---|:---|
| 背景色 | `transparent` |
| テキスト色 | `rgba(255, 255, 255, 0.7)` |
| ボーダー | `1px solid rgba(255, 255, 255, 0.12)` |
| 形状 | ピル型（`border-radius: 999px`） |
| ホバー | テキスト → `white`、ボーダー → `rgba(255, 255, 255, 0.2)` |

```css
/* === ダークモード ボタン === */

.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 12px 32px;
  background-color: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.85);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 999px;
  font-family: 'Inter', 'Noto Sans JP', sans-serif;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  cursor: pointer;
  transition: background-color 0.15s ease, color 0.15s ease;
}

.btn-primary:hover {
  background-color: rgba(255, 255, 255, 0.15);
  color: #FFFFFF;
}

.btn-primary:active {
  transform: translate(1px, 1px);
}

.btn-cta {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 12px 32px;
  background-color: transparent;
  color: #DFFF4F;
  border: 1px solid #DFFF4F;
  border-radius: 999px;
  font-family: 'Inter', 'Noto Sans JP', sans-serif;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.btn-cta:hover {
  background-color: rgba(223, 255, 79, 0.1);
}

.btn-secondary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 12px 32px;
  background-color: transparent;
  color: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 999px;
  font-family: 'Inter', 'Noto Sans JP', sans-serif;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  cursor: pointer;
  transition: color 0.15s ease, border-color 0.15s ease;
}

.btn-secondary:hover {
  color: #FFFFFF;
  border-color: rgba(255, 255, 255, 0.2);
}
```

#### ライトモード（セカンダリ）

**Primary Button（ライト）:**

| プロパティ | 値 |
|:---|:---|
| 背景色 | `#111111` |
| テキスト色 | `#FFFFFF` |
| 形状 | ピル型（`border-radius: 999px`）またはシャープ型（`0px`） |
| ボーダー | なし |
| ホバー | 背景 → `#DFFF4F`、テキスト → `#111111` |
| シャドウ（ホバー時） | `4px 4px 0px #111111` |

**Secondary Button（ライト）:**

| プロパティ | 値 |
|:---|:---|
| 背景色 | `transparent` |
| テキスト色 | `#111111` |
| ボーダー | `2px solid #111111` |
| ホバー | 背景 → `#111111`、テキスト → `#FFFFFF` |

```css
/* === ライトモード ボタン === */

.light-mode .btn-primary {
  background-color: #111111;
  color: #FFFFFF;
  border: none;
}

.light-mode .btn-primary:hover {
  background-color: #DFFF4F;
  color: #111111;
}

.light-mode .btn-secondary {
  color: #111111;
  border: 2px solid #111111;
}

.light-mode .btn-secondary:hover {
  background-color: #111111;
  color: #FFFFFF;
}
```

#### ボタンサイズバリエーション

| サイズ | パディング | フォントサイズ | 用途 |
|:---|:---|:---|:---|
| Small | `8px 20px` | 12px | インラインアクション |
| Medium（デフォルト） | `12px 32px` | 14px | 一般的な CTA |
| Large | `16px 48px` | 16px | ヒーローセクション |

#### ボタン状態一覧

| 状態 | ダーク Primary | ダーク CTA | ライト Primary |
|:---|:---|:---|:---|
| Default | `white@0.1` 背景 | `transparent` / ネオンボーダー | `#111111` 背景 |
| Hover | `white@0.15` 背景 | `neon@0.1` 背景 | `#DFFF4F` 背景 |
| Active | `translate(1px, 1px)` | `translate(1px, 1px)` | `translate(1px, 1px)` |
| Disabled | `opacity: 0.3` | `opacity: 0.3` | `opacity: 0.4` |
| Focus | `outline: 1px solid #DFFF4F` / `outline-offset: 2px` | `outline: 1px solid #DFFF4F` | `outline: 2px solid #DFFF4F` |

---

### 5.2 カード（"モジュール"）

プロジェクト、メンバー、イベント等のコンテンツを包むコンテナ。

#### ダークモード（プライマリ）

| プロパティ | 値 |
|:---|:---|
| 背景色 | `rgba(255, 255, 255, 0.05)` |
| ボーダー | `1px solid rgba(255, 255, 255, 0.12)` |
| シャドウ | なし |
| 角丸 | `12px`（Container） |
| パディング | コンテンツエリア `16px` |

```
┌─────────────────────────────────────┐  ← border: 1px solid white@0.12
│                                     │     border-radius: 12px
│         画像エリア                    │  ← border-radius: 12px 12px 0 0
│         (Image Area)                │     filter: saturate(0.7) contrast(1.05)
│                                     │
├─────────────────────────────────────┤  ← border-top: 1px solid white@0.08
│                                     │
│  タイトル                            │  ← type.title (24px / w500 / white@0.85)
│  説明テキスト（最大2行）              │  ← type.body (16px / w300 / white@0.7)
│                                     │
│  [DESIGN]  [TECH]                   │  ← チップ（セクション5.3参照）
│                                     │
├─────────────────────────────────────┤  ← border-top: 1px solid white@0.08
│  2026.02.07  ─  WORKSHOP  ─  TOKYO │  ← type.mono (12px / white@0.5)
└─────────────────────────────────────┘
```

**ホバーインタラクション（ダーク）:**

| 状態 | 変化 |
|:---|:---|
| Hover | 背景 → `rgba(255,255,255,0.08)`、ボーダー → `rgba(255,255,255,0.2)` |
| Active | `transform: translate(1px, 1px)` |

```css
/* === ダークモード カード === */

.card {
  background-color: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 12px;
  overflow: hidden;
  transition: background-color 0.15s ease, border-color 0.15s ease;
}

.card:hover {
  background-color: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.2);
}

.card__image {
  width: 100%;
  aspect-ratio: 16 / 10;
  object-fit: cover;
  display: block;
  filter: saturate(0.7) contrast(1.05);
}

.card__content {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.card__title {
  font-family: 'Inter', 'Noto Sans JP', sans-serif;
  font-size: 24px;
  font-weight: 500;
  line-height: 1.2;
  color: rgba(255, 255, 255, 0.85);
}

.card__description {
  font-size: 16px;
  font-weight: 300;
  line-height: 1.6;
  color: rgba(255, 255, 255, 0.7);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card__meta {
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  padding: 12px 16px;
  font-family: 'JetBrains Mono', 'Roboto Mono', monospace;
  font-size: 12px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.5);
}
```

#### ライトモード

| プロパティ | 値 |
|:---|:---|
| 背景色 | `#FFFFFF` |
| ボーダー | `1px solid #111111` |
| シャドウ | `4px 4px 0px #111111` |
| 角丸 | `0px`（Sharp） |

```css
/* === ライトモード カード === */

.light-mode .card {
  background-color: #FFFFFF;
  border: 1px solid #111111;
  box-shadow: 4px 4px 0px #111111;
  border-radius: 0px;
}

.light-mode .card:hover {
  transform: translate(-2px, -2px);
  box-shadow: 6px 6px 0px #111111;
  background-color: #FFFFFF;
  border-color: #111111;
}

.light-mode .card__title {
  color: #111111;
  font-weight: 700;
}

.light-mode .card__description {
  color: #111111;
  font-weight: 400;
}

.light-mode .card__meta {
  border-top-color: #111111;
  color: #111111;
}
```

#### カードバリエーション

| バリエーション | モード | 背景 | ボーダー | シャドウ |
|:---|:---|:---|:---|:---|
| Default | ダーク | `white@0.05` | `white@0.12` | なし |
| Elevated | ダーク | `white@0.08` | `white@0.15` | なし |
| Dark Accent | ダーク | `white@0.05` | `#DFFF4F@0.3` | なし |
| Default | ライト | `#FFFFFF` | `1px solid #111111` | `4px 4px 0px #111111` |
| Cream | ライト | `#E8E6D9` | `1px solid #111111` | `4px 4px 0px #111111` |

> **v1.0 からの変更:** `card--neon`（ネオンライム背景）バリエーションは廃止。ネオンはアクセントとしてのみ使用。

---

### 5.3 チップ / タグ

#### ダークモード

| バリエーション | 背景 | ボーダー | テキスト | 角丸 |
|:---|:---|:---|:---|:---|
| Default | `transparent` | `white@0.12` | `white@0.6` | `999px`（ピル） |
| Selected | `rgba(223,255,79,0.1)` | `rgba(223,255,79,0.3)` | `#DFFF4F` | `999px` |
| Solid | `white@0.1` | なし | `white@0.85` | `999px` |

#### ライトモード

| バリエーション | 背景 | ボーダー | テキスト | 角丸 |
|:---|:---|:---|:---|:---|
| Outline（デフォルト） | `transparent` | `1px solid #111111` | `#111111` | `4px` |
| Outline Pill | `transparent` | `1px solid #111111` | `#111111` | `999px` |
| Solid Black | `#111111` | なし | `#FFFFFF` | `4px` |

> **v1.0 からの変更:** `chip--neon`（ネオン背景チップ）は廃止。

```css
/* === ダークモード チップ === */

.chip {
  display: inline-flex;
  align-items: center;
  padding: 4px 12px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 999px;
  font-family: 'JetBrains Mono', 'Roboto Mono', monospace;
  font-size: 12px;
  font-weight: 400;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.6);
  background-color: transparent;
  white-space: nowrap;
}

.chip--selected {
  background-color: rgba(223, 255, 79, 0.1);
  border-color: rgba(223, 255, 79, 0.3);
  color: #DFFF4F;
}

.chip--solid {
  background-color: rgba(255, 255, 255, 0.1);
  border-color: transparent;
  color: rgba(255, 255, 255, 0.85);
}

/* === ライトモード チップ === */

.light-mode .chip {
  border: 1px solid #111111;
  border-radius: 4px;
  color: #111111;
}

.light-mode .chip--pill {
  border-radius: 999px;
}

.light-mode .chip--solid {
  background-color: #111111;
  color: #FFFFFF;
  border-color: transparent;
}
```

#### チップグループ

```css
.chip-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
```

---

### 5.4 ナビゲーション

#### デスクトップ: スティッキーヘッダー（ダークモード = デフォルト）

```
┌──────────────────────────────────────────────────────────────┐
│  f∞                          PROJECTS  MEMBERS  EVENTS  ≡  │
└──────────────────────────────────────────────────────────────┘
```

| プロパティ | 値 |
|:---|:---|
| 高さ | `64px` |
| 背景 | `#0A0A0F` |
| ボーダー | `border-bottom: 1px solid rgba(255,255,255,0.08)` |
| ロゴ色 | `rgba(255, 255, 255, 0.85)` |
| リンク色 | `rgba(255, 255, 255, 0.6)` |
| リンクホバー | `rgba(255, 255, 255, 1.0)` |
| リンクアクティブ | テキスト `#DFFF4F`、`border-bottom: 1px solid #DFFF4F` |

```css
/* === ダークモード ナビゲーション（デフォルト） === */

.nav-header {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  padding: 0 24px;
  background-color: #0A0A0F;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.nav-header__logo {
  font-family: 'Inter', 'Noto Sans JP', sans-serif;
  font-size: 24px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.85);
  text-decoration: none;
  letter-spacing: -0.02em;
}

.nav-header__links {
  display: flex;
  align-items: center;
  gap: 0;
}

.nav-header__link {
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  text-decoration: none;
  color: rgba(255, 255, 255, 0.6);
  transition: color 0.15s ease;
}

.nav-header__link:hover {
  color: #FFFFFF;
}

.nav-header__link--active {
  color: #DFFF4F;
  border-bottom: 1px solid #DFFF4F;
}
```

#### ライトモード ナビゲーション

| プロパティ | 値 |
|:---|:---|
| 背景 | `#FFFFFF` |
| ボーダー | `border-bottom: 1px solid #111111` |
| ロゴ色 | `#111111` |
| リンク色 | `#111111` |
| リンクホバー | 背景 `#111111`、テキスト `#DFFF4F` |

```css
/* === ライトモード ナビゲーション === */

.light-mode .nav-header {
  background-color: #FFFFFF;
  border-bottom: 1px solid #111111;
}

.light-mode .nav-header__logo {
  color: #111111;
  font-weight: 700;
}

.light-mode .nav-header__link {
  color: #111111;
}

.light-mode .nav-header__link:hover {
  background-color: #111111;
  color: #DFFF4F;
}

.light-mode .nav-header__link--active {
  border-bottom: 2px solid #DFFF4F;
  color: #111111;
}
```

#### モバイル: フルスクリーンオーバーレイ

```
┌────────────────────────┐
│  f∞                 ✕  │  ← ヘッダー（64px）
├────────────────────────┤
│                        │
│   PROJECTS             │  ← 32px / w300 / uppercase / white@0.85
│                        │
│   MEMBERS              │
│                        │
│   EVENTS               │
│                        │
│   ABOUT                │
│                        │
│   [CONTACT US]         │  ← CTA Button（ネオンボーダー）
│                        │
│   IG  X  YT            │  ← white@0.5 / 等幅
└────────────────────────┘
```

| プロパティ | 値 |
|:---|:---|
| 背景 | `#0A0A0F` |
| テキスト色 | `rgba(255, 255, 255, 0.85)` |
| リンクフォント | 32px / Light（w300） / uppercase |
| リンク間隔 | `24px` |
| アニメーション | スライドイン（右から左）、`200ms ease-out` |

```css
.mobile-menu {
  position: fixed;
  inset: 0;
  z-index: 200;
  background-color: #0A0A0F;
  display: flex;
  flex-direction: column;
  padding: 0 24px;
  transform: translateX(100%);
  transition: transform 0.2s ease-out;
}

.mobile-menu--open {
  transform: translateX(0);
}

.mobile-menu__link {
  font-size: 32px;
  font-weight: 300;
  text-transform: uppercase;
  text-decoration: none;
  color: rgba(255, 255, 255, 0.85);
  letter-spacing: -0.01em;
}

.mobile-menu__link:hover {
  color: #DFFF4F;
}
```

---

### 5.5 セクションタイトル（新規コンポーネント）

実験プロトコルのラベルとして機能する、大文字の小見出し。

| プロパティ | 値 |
|:---|:---|
| フォントサイズ | 12px |
| ウェイト | SemiBold（600） |
| 字間 | 0.15em |
| テキスト変換 | `uppercase` |
| カラー（ダーク） | `rgba(255, 255, 255, 0.5)` |
| カラー（ライト） | `rgba(17, 17, 17, 0.6)` |
| 下マージン | 12px |

```css
.section-title {
  font-family: 'Inter', 'Noto Sans JP', sans-serif;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.5);
  margin-bottom: 12px;
}

.light-mode .section-title {
  color: rgba(17, 17, 17, 0.6);
}
```

---

### 5.6 リストアイテム

#### ダークモード

```
┌──────────────────────────────────────────────────────────────┐
│  タイトルテキスト                     2026.02.07 ─ TOKYO    │  ← white@0.85 / white@0.5
│  説明テキスト（1行）                                         │  ← white@0.6
└──────────────────────────────────────────────────────────────┘
── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ← white@0.08
```

| プロパティ | 値 |
|:---|:---|
| 区切り | `border-bottom: 1px solid rgba(255,255,255,0.08)` |
| パディング | `16px 0` |
| タイトル | `type.title`（24px / w500 / `white@0.85`） |
| 説明 | `type.body`（16px / w300 / `white@0.6`） |
| メタデータ | `type.mono`（12px / `white@0.5` / uppercase） |
| ホバー | 背景 `rgba(255, 255, 255, 0.03)` |

```css
.list-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 16px 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  transition: background-color 0.15s ease;
}

.list-item:hover {
  background-color: rgba(255, 255, 255, 0.03);
}

.list-item__title {
  font-size: 18px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.85);
}

.list-item__description {
  font-size: 16px;
  font-weight: 300;
  color: rgba(255, 255, 255, 0.6);
}

.list-item__meta {
  font-family: 'JetBrains Mono', 'Roboto Mono', monospace;
  font-size: 12px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.5);
}

/* ライトモード */
.light-mode .list-item {
  border-bottom-color: #111111;
}

.light-mode .list-item:hover {
  background-color: rgba(223, 255, 79, 0.05);
}

.light-mode .list-item__title {
  color: #111111;
  font-weight: 700;
}

.light-mode .list-item__description {
  color: #111111;
  opacity: 0.7;
}

.light-mode .list-item__meta {
  color: #111111;
  opacity: 0.6;
}
```

---

### 5.7 入力フィールド

#### ダークモード

| プロパティ | 値 |
|:---|:---|
| ボーダー | `1px solid rgba(255,255,255,0.12)` |
| 角丸 | `4px`（テクニカル） |
| パディング | `12px 16px` |
| フォント | `type.body`（16px / w300） |
| 背景 | `transparent` |
| テキスト色 | `rgba(255, 255, 255, 0.85)` |
| プレースホルダー色 | `rgba(255, 255, 255, 0.3)` |
| フォーカス | ボーダー `#DFFF4F`、`outline: none` |
| エラー | ボーダー `#FF4F4F` |

```css
.input-field {
  padding: 12px 16px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 4px;
  font-family: 'Inter', 'Noto Sans JP', sans-serif;
  font-size: 16px;
  font-weight: 300;
  color: rgba(255, 255, 255, 0.85);
  background-color: transparent;
  outline: none;
  transition: border-color 0.15s ease;
}

.input-field::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.input-field:focus {
  border-color: #DFFF4F;
}

.input-field--error {
  border-color: #FF4F4F;
}

.input-label {
  font-family: 'JetBrains Mono', 'Roboto Mono', monospace;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.5);
}

/* ライトモード */
.light-mode .input-field {
  border: 2px solid #111111;
  color: #111111;
  background-color: #FFFFFF;
}

.light-mode .input-field::placeholder {
  color: #111111;
  opacity: 0.4;
}

.light-mode .input-field:focus {
  border-color: #DFFF4F;
  box-shadow: 4px 4px 0px #DFFF4F;
}

.light-mode .input-label {
  color: #111111;
}
```

---

### 5.8 ダイアログ / モーダル

#### ダークモード

| プロパティ | 値 |
|:---|:---|
| 背景 | `#1A1A2E` |
| ボーダー | `1px solid rgba(255,255,255,0.12)` |
| 角丸 | `16px`（Surface） |
| 幅 | `min(480px, 90vw)` |
| パディング | `24px` |
| オーバーレイ | `rgba(10, 10, 15, 0.7)` + `backdrop-filter: blur(20px)` |
| シャドウ | なし |

#### ライトモード

| プロパティ | 値 |
|:---|:---|
| 背景 | `#FFFFFF` |
| ボーダー | `2px solid #111111` |
| 角丸 | `0px`（Sharp） |
| シャドウ | `8px 8px 0px #111111` |
| オーバーレイ | `rgba(17, 17, 17, 0.6)` |

```css
/* === ダークモード モーダル === */

.modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 300;
  background-color: rgba(10, 10, 15, 0.7);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.modal {
  width: min(480px, 90vw);
  background-color: #1A1A2E;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 16px;
  padding: 24px;
}

.modal__title {
  font-size: 18px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: rgba(255, 255, 255, 0.85);
  margin-bottom: 16px;
}

.modal__body {
  font-size: 16px;
  font-weight: 300;
  line-height: 1.6;
  color: rgba(255, 255, 255, 0.7);
  margin-bottom: 24px;
}

.modal__actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

/* === ライトモード モーダル === */

.light-mode .modal-overlay {
  background-color: rgba(17, 17, 17, 0.6);
  backdrop-filter: none;
}

.light-mode .modal {
  background-color: #FFFFFF;
  border: 2px solid #111111;
  box-shadow: 8px 8px 0px #111111;
  border-radius: 0px;
}

.light-mode .modal__title {
  color: #111111;
  font-weight: 700;
}

.light-mode .modal__body {
  color: #111111;
  font-weight: 400;
}
```

---

### 5.9 触覚フィードバック

v2.0 では、知的で控えめな印象に合わせてフィードバック強度を `.heavy` から `.medium` に変更。

| イベント | iOS | Android |
|:---|:---|:---|
| ボタンタップ | `UIImpactFeedbackGenerator(style: .medium)` | `HapticFeedbackConstants.CONFIRM` |
| カードタップ | `UIImpactFeedbackGenerator(style: .light)` | `HapticFeedbackConstants.KEYBOARD_TAP` |
| CTA タップ | `UIImpactFeedbackGenerator(style: .medium)` | `HapticFeedbackConstants.CONFIRM` |
| 成功時 | `UINotificationFeedbackGenerator(.success)` | `HapticFeedbackConstants.CONFIRM` |

---

## 6. アイコン＆グラフィックス

---

### 6.1 アイコンスタイル

f∞ studio のアイコンは「精密さ」と「知的な軽さ」を基本とする。

#### スタイル規定

| プロパティ | 値 |
|:---|:---|
| スタイル | シャープなラインと幾何学的形状（ダーク）、明確で構造的（ライト） |
| ストローク幅 | `1.5px〜2px` |
| コーナー | シャープ（丸みなし） |
| 塗り | アウトライン（デフォルト） |
| グリッド | `24px × 24px` |

> **v1.0 からの変更:** ストローク幅を 2px 固定から `1.5px〜2px` の範囲に拡大。軽やかなタイポグラフィに合わせて、アイコンも若干の繊細さを許容する。

#### 推奨アイコンセット

| 推奨 | ソース | 理由 |
|:---|:---|:---|
| **第1推奨** | **Material Symbols（Sharp）** | エッジの効いた構造的要素に。f∞ の工業的ルーツを継承。 |
| **第2推奨** | **Material Symbols（Outlined）** | より軽やかな印象が必要な場面に。ダークモードでの視認性。 |
| 第3推奨 | Phosphor Icons | 代替選択肢 |
| カスタム | 独自 SVG | ブランド固有のアイコン |

#### アイコンサイズスケール

| トークン | サイズ | 用途 |
|:---|:---|:---|
| `icon.sm` | `16px` | インラインテキスト補助、チップ内 |
| `icon.md` | `20px` | ナビゲーション、リストアイテム |
| `icon.default` | `24px` | 一般的な UI アイコン、ボタン内 |
| `icon.lg` | `32px` | セクションヘッダー、強調 |
| `icon.xl` | `48px` | エンプティステート、オンボーディング |

---

### 6.2 ダークモードアイコン不透明度

| 状態 | 不透明度 | 備考 |
|:---|:---|:---|
| Default | `0.5` | 控えめだが認識可能 |
| Hover | `0.7` | 操作可能であることを示す |
| Active / Selected | `#DFFF4F` | ネオンライムで「発見」を示す |
| Disabled | `0.2` | ほぼ不可視 |

```css
.icon {
  color: rgba(255, 255, 255, 0.5);
  transition: color 0.15s ease, opacity 0.15s ease;
}

.icon:hover {
  color: rgba(255, 255, 255, 0.7);
}

.icon--active,
.icon--selected {
  color: #DFFF4F;
}

.icon--disabled {
  color: rgba(255, 255, 255, 0.2);
  pointer-events: none;
}

/* ライトモード */
.light-mode .icon {
  color: #111111;
}

.light-mode .icon--active {
  color: #DFFF4F;
}
```

#### アイコン使用のルール

- アイコン単体使用時は `aria-label` を付与
- テキストラベル併用時は `aria-hidden="true"`
- ダークモードではアイコンの色は不透明度スケールに準拠
- ネオンライム（`#DFFF4F`）は **アクティブ状態** と **選択状態** のみ

---

### 6.3 Pan-graphy 的写真表現

写真の「境界」を視覚的に表現するための技法。Pan-graphy のコンセプトをデジタルインターフェース上で具現化する。

#### 境界フェード（Boundary Fade）

写真の端がキャンバスに溶け込むグラデーション。「写真と写真でないものの境界」を曖昧にする。

```css
.photo--boundary-fade {
  mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
  -webkit-mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
}

/* 水平方向のフェード */
.photo--boundary-fade-horizontal {
  mask-image: linear-gradient(to right, transparent 0%, black 10%, black 90%, transparent 100%);
  -webkit-mask-image: linear-gradient(to right, transparent 0%, black 10%, black 90%, transparent 100%);
}
```

#### 彩度低減（Desaturation）

Pan-graphy の「記録」としての写真は、鮮やかさよりも情報としての存在感を重視する。

```css
.photo--record {
  filter: saturate(0.6) contrast(1.1);
}

/* さらに控えめ——「想起」としての写真 */
.photo--memory {
  filter: saturate(0.3) contrast(1.05) brightness(0.95);
}
```

#### ブラー装飾（Blur Decoration）

パンフォーカスの対概念としてのボケ。背景要素やオーバーレイに使用。

```css
.photo--blur-accent {
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}

/* 写真の一部をボケで装飾 */
.photo--selective-blur::after {
  content: "";
  position: absolute;
  inset: 0;
  backdrop-filter: blur(8px);
  mask-image: radial-gradient(circle at center, transparent 40%, black 100%);
}
```

> **注意:** `backdrop-filter: blur()` は許容されるが、`box-shadow` の blur（ドロップシャドウ）は引き続き禁止。この二つは概念的に異なる。

---

### 6.4 写真・画像スタイル

#### 写真のスタイルガイドライン

| 要素 | ガイドライン |
|:---|:---|
| コントラスト | ハイコントラスト。暗部と明部の差を強調する |
| スタイル | ドキュメンタリースタイル。「境界の採集」としてのフィールドワーク記録 |
| 被写体 | 「メイキング」ショット、Pan-graphy 的な境界上の存在 |
| 構図 | クロースアップとワイドショットの混在 |
| 加工 | 彩度控えめ（`saturate: 0.6〜0.8`）、コントラスト強め |
| フォーマット（ダーク） | `border-radius: 12px`、境界フェード適用可 |
| フォーマット（ライト） | `border-radius: 0px`（シャープエッジ） |

```css
/* ダークモード 画像コンテナ */
.image-container {
  overflow: hidden;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  filter: saturate(0.7) contrast(1.05);
}

/* ライトモード */
.light-mode .image-container {
  border-radius: 0px;
  border: 1px solid #111111;
}

.light-mode .image-container img {
  filter: contrast(1.05) saturate(0.9);
}
```

---

### 6.5 f∞ ロゴ使用ルール

| ルール | 説明 |
|:---|:---|
| **正用法1** | Deep Canvas（`#0A0A0F`）にネオンライム（`#DFFF4F`）のロゴ |
| **正用法2** | White（`#FFFFFF`）に `#0A0A0F` のロゴ |
| **正用法3** | `#0A0A0F` に White のロゴ |
| **禁止** | グレースケールでの表示 |
| **禁止** | 低コントラストの色の組み合わせ |
| **禁止** | グラデーションや装飾効果の適用 |
| **禁止** | ロゴの変形・回転・トリミング |

> **v1.0 からの変更:** ネオンライム背景にロゴを配置するパターンは廃止（大面積ネオン使用禁止のため）。

#### ロゴの最小サイズ / クリアスペース

v1.0 から変更なし。デジタル最小幅 `32px`、印刷最小幅 `12mm`。クリアスペースはロゴ高さの 50% 以上。

---

## 7. プラットフォーム別実装ガイド

> 各プラットフォームで f∞ studio v2.0 のビジュアルアイデンティティを忠実に再現するための
> 具体的なコードサンプルとガイドライン。**ダークモードがデフォルト実装。**

---

### 7.1 iOS（SwiftUI）

#### カラー定義

```swift
import SwiftUI

extension Color {
    // MARK: - f∞ studio v2.0 Canvas Colors
    static let fooCanvas       = Color(hex: "#0A0A0F")  // Deep Canvas
    static let fooSurface      = Color(hex: "#1A1A2E")  // Surface

    // MARK: - Accent
    static let fooAccentNeon   = Color(hex: "#DFFF4F")  // Neon Lime (accent only, ≤5%)

    // MARK: - Light Mode
    static let fooBlack        = Color(hex: "#111111")
    static let fooCream        = Color(hex: "#E8E6D9")
    static let fooWhite        = Color(hex: "#FFFFFF")

    // MARK: - Functional Colors
    static let fooError        = Color(hex: "#FF4F4F")
    static let fooSuccess      = Color(hex: "#4FFF8C")
    static let fooWarning      = Color(hex: "#FFD24F")
}

// MARK: - Opacity Helpers
extension Color {
    static func fooText(_ alpha: Double) -> Color {
        Color.white.opacity(alpha)
    }
    static func fooSurfaceAlpha(_ alpha: Double) -> Color {
        Color.white.opacity(alpha)
    }
    static func fooBorder(_ alpha: Double) -> Color {
        Color.white.opacity(alpha)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

#### ボタンスタイル

```swift
// MARK: - f∞ v2.0 Primary Button (Dark Mode)
struct FooPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .tracking(0.7)
            .textCase(.uppercase)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.white.opacity(configuration.isPressed ? 0.15 : 0.1))
            .foregroundColor(.white.opacity(0.85))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

// MARK: - f∞ v2.0 CTA Button (Neon Accent)
struct FooCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .tracking(0.7)
            .textCase(.uppercase)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(
                configuration.isPressed
                    ? Color.fooAccentNeon.opacity(0.1)
                    : Color.clear
            )
            .foregroundColor(.fooAccentNeon)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.fooAccentNeon, lineWidth: 1)
            )
    }
}

// MARK: - f∞ v2.0 Light Mode Primary Button
struct FooLightPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .tracking(0.7)
            .textCase(.uppercase)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color.fooAccentNeon : Color.fooBlack)
            .foregroundColor(configuration.isPressed ? Color.fooBlack : Color.white)
            .clipShape(Capsule())
            .offset(
                x: configuration.isPressed ? 1 : 0,
                y: configuration.isPressed ? 1 : 0
            )
    }
}

// 使用例
Button("Explore") {}
    .buttonStyle(FooPrimaryButtonStyle())

Button("Discover") {}
    .buttonStyle(FooCTAButtonStyle())
```

#### カードビュー

```swift
// MARK: - f∞ v2.0 Module Card (Dark Mode)
struct FooModuleCard: View {
    let title: String
    let description: String
    let category: String
    let date: String
    let location: String
    let imageContent: () -> AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 画像エリア
            imageContent()
                .frame(maxWidth: .infinity)
                .aspectRatio(16/10, contentMode: .fill)
                .clipped()
                .saturation(0.7)
                .contrast(1.05)

            // コンテンツエリア
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))

                Text(description)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)

                HStack(spacing: 8) {
                    FooChip(label: category)
                }
            }
            .padding(16)

            // メタデータフッター
            Divider()
                .background(Color.white.opacity(0.08))

            HStack {
                Text("\(date)  ─  \(category.uppercased())  ─  \(location.uppercased())")
                    .font(.system(size: 12, design: .monospaced))
                    .tracking(0.6)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

#### チップ

```swift
// MARK: - f∞ v2.0 Chip (Dark Mode)
struct FooChip: View {
    let label: String
    var isSelected: Bool = false

    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 12, design: .monospaced))
            .tracking(0.6)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(isSelected ? Color.fooAccentNeon.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .fooAccentNeon : .white.opacity(0.6))
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                            ? Color.fooAccentNeon.opacity(0.3)
                            : Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            )
            .clipShape(Capsule())
    }
}
```

#### iOS 固有のガイドライン

| ガイドライン | 説明 |
|:---|:---|
| **ダークモードデフォルト** | `.preferredColorScheme(.dark)` をルートビューに設定 |
| **触覚フィードバック** | `UIImpactFeedbackGenerator(style: .medium)` — v1.0 の `.heavy` から変更 |
| **ステータスバー** | ダークモード: `.lightContent`（デフォルト）。ライトモード: `.darkContent` |
| **SafeArea** | `#0A0A0F` をステータスバー領域まで拡張 |
| **標準 List を避ける** | `LazyVStack` + カスタムセルで不透明度ベースのスタイリングを実現 |

```swift
// ダークモードデフォルト設定
struct FooApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

// 触覚フィードバック（v2.0: medium）
func triggerMediumHaptic() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.prepare()
    generator.impactOccurred()
}
```

---

### 7.2 Android（Jetpack Compose / Material3）

#### カラー定義

```kotlin
package com.foostudio.designsystem.theme

import androidx.compose.ui.graphics.Color

// f∞ studio v2.0 Canvas Colors
val FooCanvas       = Color(0xFF0A0A0F)
val FooSurface      = Color(0xFF1A1A2E)

// Accent
val FooAccentNeon   = Color(0xFFDFFF4F)  // ≤5% usage

// Light Mode
val FooBlack        = Color(0xFF111111)
val FooCream        = Color(0xFFE8E6D9)
val FooWhite        = Color(0xFFFFFFFF)

// Functional Colors
val FooError        = Color(0xFFFF4F4F)
val FooSuccess      = Color(0xFF4FFF8C)
val FooWarning      = Color(0xFFFFD24F)

// Opacity helpers
fun fooText(alpha: Float): Color = Color.White.copy(alpha = alpha)
fun fooSurfaceAlpha(alpha: Float): Color = Color.White.copy(alpha = alpha)
fun fooBorder(alpha: Float): Color = Color.White.copy(alpha = alpha)
```

#### テーマ定義

```kotlin
package com.foostudio.designsystem.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

// f∞ studio v2.0 カラースキーム（ダークファースト）
private val FooDarkColorScheme = darkColorScheme(
    primary = FooAccentNeon,
    onPrimary = FooCanvas,
    secondary = FooSurface,
    onSecondary = Color.White,
    background = FooCanvas,
    onBackground = Color.White,
    surface = FooSurface,
    onSurface = Color.White,
    error = FooError,
    onError = Color.White,
)

private val FooLightColorScheme = lightColorScheme(
    primary = FooBlack,
    onPrimary = FooWhite,
    secondary = FooCream,
    onSecondary = FooBlack,
    background = FooWhite,
    onBackground = FooBlack,
    surface = FooWhite,
    onSurface = FooBlack,
    error = FooError,
    onError = FooWhite,
)

// f∞ studio v2.0 タイポグラフィ
val FooTypography = Typography(
    displayLarge = TextStyle(
        fontWeight = FontWeight.Thin,    // w200 — 問い
        fontSize = 48.sp,
        letterSpacing = (-0.2).sp,
    ),
    displayMedium = TextStyle(
        fontWeight = FontWeight.Light,   // w300 — 語り
        fontSize = 32.sp,
        letterSpacing = (-0.1).sp,
    ),
    titleLarge = TextStyle(
        fontWeight = FontWeight.Medium,  // w500 — 注目
        fontSize = 24.sp,
        letterSpacing = 0.sp,
    ),
    titleMedium = TextStyle(
        fontWeight = FontWeight.Light,   // w300
        fontSize = 18.sp,
        letterSpacing = 0.sp,
    ),
    bodyLarge = TextStyle(
        fontWeight = FontWeight.Light,   // w300 — 語り
        fontSize = 16.sp,
        lineHeight = 26.sp,
    ),
    labelLarge = TextStyle(
        fontWeight = FontWeight.Medium,  // w500
        fontSize = 14.sp,
        letterSpacing = 0.5.sp,
    ),
    labelSmall = TextStyle(
        fontWeight = FontWeight.SemiBold, // w600 — 秩序
        fontSize = 12.sp,
        letterSpacing = 1.5.sp,
    ),
)

@Composable
fun FooStudioTheme(
    darkTheme: Boolean = true,  // ダークモードがデフォルト
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) FooDarkColorScheme else FooLightColorScheme

    MaterialTheme(
        colorScheme = colorScheme,
        typography = FooTypography,
        content = content,
    )
}
```

#### ボタン

```kotlin
// f∞ v2.0 Primary Button (Dark Mode)
@Composable
fun FooPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Button(
        onClick = onClick,
        modifier = modifier,
        shape = RoundedCornerShape(999.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.White.copy(alpha = 0.1f),
            contentColor = Color.White.copy(alpha = 0.85f),
        ),
        border = BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
        contentPadding = PaddingValues(horizontal = 32.dp, vertical = 12.dp),
    ) {
        Text(
            text = text.uppercase(),
            fontWeight = FontWeight.Medium,
            fontSize = 14.sp,
            letterSpacing = 0.5.sp,
        )
    }
}

// f∞ v2.0 CTA Button (Neon Accent)
@Composable
fun FooCTAButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    OutlinedButton(
        onClick = onClick,
        modifier = modifier,
        shape = RoundedCornerShape(999.dp),
        colors = ButtonDefaults.outlinedButtonColors(
            contentColor = FooAccentNeon,
        ),
        border = BorderStroke(1.dp, FooAccentNeon),
        contentPadding = PaddingValues(horizontal = 32.dp, vertical = 12.dp),
    ) {
        Text(
            text = text.uppercase(),
            fontWeight = FontWeight.Medium,
            fontSize = 14.sp,
            letterSpacing = 0.5.sp,
        )
    }
}
```

#### カード

```kotlin
// f∞ v2.0 Module Card (Dark Mode)
@Composable
fun FooModuleCard(
    title: String,
    description: String,
    category: String,
    date: String,
    location: String,
    imageContent: @Composable () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .background(
                Color.White.copy(alpha = 0.05f),
                RoundedCornerShape(12.dp),
            )
            .border(
                1.dp,
                Color.White.copy(alpha = 0.12f),
                RoundedCornerShape(12.dp),
            )
            .clip(RoundedCornerShape(12.dp))
    ) {
        // 画像エリア
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(16f / 10f)
                .clip(RoundedCornerShape(topStart = 12.dp, topEnd = 12.dp))
        ) {
            imageContent()
        }

        // コンテンツエリア
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(
                text = title,
                fontSize = 24.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White.copy(alpha = 0.85f),
            )
            Text(
                text = description,
                fontSize = 16.sp,
                fontWeight = FontWeight.Light,
                color = Color.White.copy(alpha = 0.7f),
                maxLines = 2,
            )
        }

        // メタデータフッター
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(Color.White.copy(alpha = 0.08f))
        )

        Text(
            text = "$date  ─  ${category.uppercase()}  ─  ${location.uppercase()}",
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
            fontFamily = FontFamily.Monospace,
            fontSize = 12.sp,
            letterSpacing = 0.5.sp,
            color = Color.White.copy(alpha = 0.5f),
        )
    }
}
```

#### Android 固有のガイドライン

| ガイドライン | 説明 |
|:---|:---|
| **ダークモードデフォルト** | `FooStudioTheme(darkTheme = true)` |
| **Surface 形状** | ダーク: `RoundedCornerShape(12.dp)`、ライト: `RectangleShape` |
| **トランジション** | `150ms〜250ms`、キレのある動き |
| **触覚フィードバック** | `HapticFeedbackConstants.CONFIRM`（v1.0 の `LONG_PRESS` から変更） |
| **ステータスバー** | `#0A0A0F`（ダーク）、ライトアイコン |
| **エッジ to エッジ** | `WindowCompat.setDecorFitsSystemWindows(window, false)` |

---

### 7.3 Web（CSS / Tailwind CSS）

#### CSS Custom Properties（v2.0 完全定義）

```css
:root {
  /* ============================
     f∞ studio Design System v2.0
     CSS Custom Properties
     ============================ */

  /* --- Canvas Colors --- */
  --foo-canvas:          #0A0A0F;
  --foo-surface:         #1A1A2E;
  --foo-canvas-light:    #FFFFFF;
  --foo-cream:           #E8E6D9;

  /* --- Accent --- */
  --foo-accent-neon:         #DFFF4F;
  --foo-accent-neon-muted:   rgba(223, 255, 79, 0.15);

  /* --- Light Mode Base --- */
  --foo-black:           #111111;

  /* --- Functional Colors --- */
  --foo-error:           #FF4F4F;
  --foo-success:         #4FFF8C;
  --foo-warning:         #FFD24F;

  /* --- Text Opacity (white-based, dark mode) --- */
  --foo-text-hero:       rgba(255, 255, 255, 1.0);
  --foo-text-high:       rgba(255, 255, 255, 0.85);
  --foo-text-body:       rgba(255, 255, 255, 0.7);
  --foo-text-secondary:  rgba(255, 255, 255, 0.6);
  --foo-text-tertiary:   rgba(255, 255, 255, 0.5);
  --foo-text-caption:    rgba(255, 255, 255, 0.4);
  --foo-text-muted:      rgba(255, 255, 255, 0.3);
  --foo-text-ghost:      rgba(255, 255, 255, 0.2);
  --foo-text-whisper:    rgba(255, 255, 255, 0.1);

  /* --- Surface Opacity (white-based) --- */
  --foo-surface-elevated:  rgba(255, 255, 255, 0.12);
  --foo-surface-container: rgba(255, 255, 255, 0.08);
  --foo-surface-subtle:    rgba(255, 255, 255, 0.05);
  --foo-surface-faint:     rgba(255, 255, 255, 0.03);

  /* --- Border Opacity (white-based) --- */
  --foo-border-strong:   rgba(255, 255, 255, 0.3);
  --foo-border-medium:   rgba(255, 255, 255, 0.2);
  --foo-border-default:  rgba(255, 255, 255, 0.12);
  --foo-border-subtle:   rgba(255, 255, 255, 0.08);
  --foo-border-faint:    rgba(255, 255, 255, 0.05);

  /* --- Typography: Font Families --- */
  --foo-font-primary:  'Inter', 'Noto Sans JP', sans-serif;
  --foo-font-mono:     'JetBrains Mono', 'Roboto Mono', 'SF Mono', monospace;

  /* --- Typography: Font Sizes --- */
  --foo-size-display:   48px;
  --foo-size-headline:  32px;
  --foo-size-title:     24px;
  --foo-size-subtitle:  18px;
  --foo-size-body:      16px;
  --foo-size-label:     14px;
  --foo-size-section:   12px;
  --foo-size-mono:      12px;

  /* --- Typography: Font Weights --- */
  --foo-weight-thin:      200;
  --foo-weight-light:     300;
  --foo-weight-medium:    500;
  --foo-weight-semibold:  600;
  --foo-weight-bold:      700;

  /* --- Typography: Letter Spacing --- */
  --foo-tracking-tight:   -0.02em;
  --foo-tracking-normal:  0;
  --foo-tracking-wide:    0.05em;
  --foo-tracking-section: 0.15em;

  /* --- Typography: Line Height --- */
  --foo-leading-tight:    1.0;
  --foo-leading-snug:     1.2;
  --foo-leading-normal:   1.4;
  --foo-leading-relaxed:  1.6;

  /* --- Spacing (4px base, 10 levels) --- */
  --foo-space-xxs:  4px;
  --foo-space-xs:   8px;
  --foo-space-sm:   12px;
  --foo-space-md:   16px;
  --foo-space-lg:   20px;
  --foo-space-xl:   24px;
  --foo-space-2xl:  32px;
  --foo-space-3xl:  48px;
  --foo-space-4xl:  64px;
  --foo-space-5xl:  96px;

  /* --- Border Radius (5 levels) --- */
  --foo-radius-sharp:     0px;
  --foo-radius-technical: 4px;
  --foo-radius-container: 12px;
  --foo-radius-surface:   16px;
  --foo-radius-pill:      999px;

  /* --- Shadows (Light Mode Only) --- */
  --foo-shadow-sm:   2px 2px 0px var(--foo-black);
  --foo-shadow-md:   4px 4px 0px var(--foo-black);
  --foo-shadow-lg:   8px 8px 0px var(--foo-black);

  /* --- Borders (Light Mode) --- */
  --foo-border-light-thin:  1px solid var(--foo-black);
  --foo-border-light-thick: 2px solid var(--foo-black);

  /* --- Transitions --- */
  --foo-transition-fast:   0.1s ease;
  --foo-transition-normal: 0.15s ease;
  --foo-transition-slow:   0.25s ease-out;
}
```

#### Tailwind CSS コンフィグ（v2.0）

```javascript
// tailwind.config.js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        foo: {
          canvas:    '#0A0A0F',
          surface:   '#1A1A2E',
          neon:      '#DFFF4F',
          black:     '#111111',
          cream:     '#E8E6D9',
          white:     '#FFFFFF',
          error:     '#FF4F4F',
          success:   '#4FFF8C',
          warning:   '#FFD24F',
        },
      },
      fontFamily: {
        primary: ['"Inter"', '"Noto Sans JP"', 'sans-serif'],
        mono:    ['"JetBrains Mono"', '"Roboto Mono"', '"SF Mono"', 'monospace'],
      },
      fontSize: {
        'display':  ['48px', { lineHeight: '1.0',  letterSpacing: '-0.02em', fontWeight: '200' }],
        'headline': ['32px', { lineHeight: '1.1',  letterSpacing: '-0.01em', fontWeight: '300' }],
        'title':    ['24px', { lineHeight: '1.2',  letterSpacing: '0',       fontWeight: '500' }],
        'subtitle': ['18px', { lineHeight: '1.3',  letterSpacing: '0',       fontWeight: '300' }],
        'body':     ['16px', { lineHeight: '1.6',  letterSpacing: '0',       fontWeight: '300' }],
        'label':    ['14px', { lineHeight: '1.2',  letterSpacing: '0.05em',  fontWeight: '500' }],
        'section':  ['12px', { lineHeight: '1.2',  letterSpacing: '0.15em',  fontWeight: '600' }],
        'mono':     ['12px', { lineHeight: '1.4',  letterSpacing: '0.05em',  fontWeight: '400' }],
      },
      fontWeight: {
        thin:     '200',
        light:    '300',
        medium:   '500',
        semibold: '600',
        bold:     '700',
      },
      spacing: {
        'foo-xxs': '4px',
        'foo-xs':  '8px',
        'foo-sm':  '12px',
        'foo-md':  '16px',
        'foo-lg':  '20px',
        'foo-xl':  '24px',
        'foo-2xl': '32px',
        'foo-3xl': '48px',
        'foo-4xl': '64px',
        'foo-5xl': '96px',
      },
      borderRadius: {
        'sharp':     '0px',
        'technical': '4px',
        'container': '12px',
        'surface':   '16px',
        'pill':      '999px',
      },
      boxShadow: {
        'hard-sm':   '2px 2px 0px #111111',
        'hard-md':   '4px 4px 0px #111111',
        'hard-lg':   '8px 8px 0px #111111',
        'none':      'none',
      },
    },
  },
  plugins: [],
}
```

#### 主要コンポーネントの CSS 実装

```css
/* ============================
   f∞ studio v2.0 Component Library
   ダークモードがデフォルト
   ============================ */

/* --- ボタン（ダーク） --- */
.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 12px 32px;
  background-color: var(--foo-surface-container);
  color: var(--foo-text-high);
  border: 1px solid var(--foo-border-default);
  border-radius: var(--foo-radius-pill);
  font-family: var(--foo-font-primary);
  font-size: var(--foo-size-label);
  font-weight: var(--foo-weight-medium);
  letter-spacing: var(--foo-tracking-wide);
  text-transform: uppercase;
  cursor: pointer;
  transition: background-color var(--foo-transition-normal),
              color var(--foo-transition-normal);
}

.btn-primary:hover {
  background-color: var(--foo-surface-elevated);
  color: var(--foo-text-hero);
}

.btn-cta {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 12px 32px;
  background-color: transparent;
  color: var(--foo-accent-neon);
  border: 1px solid var(--foo-accent-neon);
  border-radius: var(--foo-radius-pill);
  font-family: var(--foo-font-primary);
  font-size: var(--foo-size-label);
  font-weight: var(--foo-weight-medium);
  letter-spacing: var(--foo-tracking-wide);
  text-transform: uppercase;
  cursor: pointer;
  transition: background-color var(--foo-transition-normal);
}

.btn-cta:hover {
  background-color: var(--foo-accent-neon-muted);
}

/* --- ボタン（ライト） --- */
.light-mode .btn-primary {
  background-color: var(--foo-black);
  color: var(--foo-canvas-light);
  border: none;
}

.light-mode .btn-primary:hover {
  background-color: var(--foo-accent-neon);
  color: var(--foo-black);
}

/* --- カード（ダーク） --- */
.card {
  background-color: var(--foo-surface-subtle);
  border: 1px solid var(--foo-border-default);
  border-radius: var(--foo-radius-container);
  overflow: hidden;
  transition: background-color var(--foo-transition-normal),
              border-color var(--foo-transition-normal);
}

.card:hover {
  background-color: var(--foo-surface-container);
  border-color: var(--foo-border-medium);
}

.card__title {
  font-family: var(--foo-font-primary);
  font-size: var(--foo-size-title);
  font-weight: var(--foo-weight-medium);
  color: var(--foo-text-high);
}

.card__description {
  font-size: var(--foo-size-body);
  font-weight: var(--foo-weight-light);
  color: var(--foo-text-body);
}

.card__meta {
  border-top: 1px solid var(--foo-border-subtle);
  padding: 12px var(--foo-space-md);
  font-family: var(--foo-font-mono);
  font-size: var(--foo-size-mono);
  letter-spacing: var(--foo-tracking-wide);
  text-transform: uppercase;
  color: var(--foo-text-tertiary);
}

/* --- カード（ライト） --- */
.light-mode .card {
  background-color: var(--foo-canvas-light);
  border: var(--foo-border-light-thin);
  box-shadow: var(--foo-shadow-md);
  border-radius: var(--foo-radius-sharp);
}

.light-mode .card:hover {
  transform: translate(-2px, -2px);
  box-shadow: 6px 6px 0px var(--foo-black);
}

.light-mode .card__title {
  color: var(--foo-black);
  font-weight: var(--foo-weight-bold);
}

.light-mode .card__meta {
  border-top-color: var(--foo-black);
  color: var(--foo-black);
}

/* --- チップ（ダーク） --- */
.chip {
  display: inline-flex;
  align-items: center;
  padding: 4px 12px;
  border: 1px solid var(--foo-border-default);
  border-radius: var(--foo-radius-pill);
  font-family: var(--foo-font-mono);
  font-size: var(--foo-size-mono);
  letter-spacing: var(--foo-tracking-wide);
  text-transform: uppercase;
  color: var(--foo-text-secondary);
  background-color: transparent;
}

.chip--selected {
  background-color: var(--foo-accent-neon-muted);
  border-color: rgba(223, 255, 79, 0.3);
  color: var(--foo-accent-neon);
}

/* --- チップ（ライト） --- */
.light-mode .chip {
  border: 1px solid var(--foo-black);
  border-radius: var(--foo-radius-technical);
  color: var(--foo-black);
}

/* --- ナビゲーション（ダーク = デフォルト） --- */
.nav-header {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  padding: 0 var(--foo-space-xl);
  background-color: var(--foo-canvas);
  border-bottom: 1px solid var(--foo-border-subtle);
}

.nav-header__logo {
  font-family: var(--foo-font-primary);
  font-size: 24px;
  font-weight: var(--foo-weight-medium);
  color: var(--foo-text-high);
  text-decoration: none;
}

.nav-header__link {
  padding: 8px 16px;
  font-size: var(--foo-size-label);
  font-weight: var(--foo-weight-medium);
  letter-spacing: var(--foo-tracking-wide);
  text-transform: uppercase;
  text-decoration: none;
  color: var(--foo-text-secondary);
  transition: color var(--foo-transition-normal);
}

.nav-header__link:hover {
  color: var(--foo-text-hero);
}

.nav-header__link--active {
  color: var(--foo-accent-neon);
  border-bottom: 1px solid var(--foo-accent-neon);
}

/* --- ナビゲーション（ライト） --- */
.light-mode .nav-header {
  background-color: var(--foo-canvas-light);
  border-bottom: var(--foo-border-light-thin);
}

.light-mode .nav-header__logo {
  color: var(--foo-black);
  font-weight: var(--foo-weight-bold);
}

.light-mode .nav-header__link {
  color: var(--foo-black);
}

.light-mode .nav-header__link:hover {
  background-color: var(--foo-black);
  color: var(--foo-accent-neon);
}

/* --- セクションタイトル --- */
.section-title {
  font-family: var(--foo-font-primary);
  font-size: var(--foo-size-section);
  font-weight: var(--foo-weight-semibold);
  letter-spacing: var(--foo-tracking-section);
  text-transform: uppercase;
  color: var(--foo-text-tertiary);
  margin-bottom: var(--foo-space-sm);
}

.light-mode .section-title {
  color: rgba(17, 17, 17, 0.6);
}

/* --- 入力フィールド（ダーク） --- */
.input-field {
  padding: 12px 16px;
  border: 1px solid var(--foo-border-default);
  border-radius: var(--foo-radius-technical);
  font-family: var(--foo-font-primary);
  font-size: var(--foo-size-body);
  font-weight: var(--foo-weight-light);
  color: var(--foo-text-high);
  background-color: transparent;
  outline: none;
  transition: border-color var(--foo-transition-normal);
}

.input-field:focus {
  border-color: var(--foo-accent-neon);
}

/* --- 入力フィールド（ライト） --- */
.light-mode .input-field {
  border: 2px solid var(--foo-black);
  color: var(--foo-black);
  background-color: var(--foo-canvas-light);
}

.light-mode .input-field:focus {
  border-color: var(--foo-accent-neon);
  box-shadow: 4px 4px 0px var(--foo-accent-neon);
}

/* --- モーダル（ダーク） --- */
.modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 300;
  background-color: rgba(10, 10, 15, 0.7);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal {
  width: min(480px, 90vw);
  background-color: var(--foo-surface);
  border: 1px solid var(--foo-border-default);
  border-radius: var(--foo-radius-surface);
  padding: var(--foo-space-xl);
}

/* --- モーダル（ライト） --- */
.light-mode .modal-overlay {
  background-color: rgba(17, 17, 17, 0.6);
  backdrop-filter: none;
}

.light-mode .modal {
  background-color: var(--foo-canvas-light);
  border: var(--foo-border-light-thick);
  box-shadow: var(--foo-shadow-lg);
  border-radius: var(--foo-radius-sharp);
}

/* --- リストアイテム --- */
.list-item {
  display: flex;
  justify-content: space-between;
  padding: var(--foo-space-md) 0;
  border-bottom: 1px solid var(--foo-border-subtle);
  transition: background-color var(--foo-transition-normal);
}

.list-item:hover {
  background-color: var(--foo-surface-faint);
}

.light-mode .list-item {
  border-bottom-color: var(--foo-black);
}

.light-mode .list-item:hover {
  background-color: rgba(223, 255, 79, 0.05);
}
```

#### Tailwind CSS ユーティリティクラスの使用例

```html
<!-- ダークモード Primary Button -->
<button class="inline-flex items-center px-8 py-3
               bg-white/10 text-white/85 border border-white/12
               rounded-pill font-primary text-label font-medium uppercase tracking-wide
               hover:bg-white/15 hover:text-white
               transition-colors duration-150">
  EXPLORE
</button>

<!-- CTA Button (ネオンアクセント) -->
<button class="inline-flex items-center px-8 py-3
               bg-transparent text-foo-neon border border-foo-neon
               rounded-pill font-primary text-label font-medium uppercase tracking-wide
               hover:bg-foo-neon/15
               transition-colors duration-150">
  DISCOVER
</button>

<!-- ダークモード Card -->
<article class="bg-white/5 border border-white/12 rounded-container
                overflow-hidden hover:bg-white/8 hover:border-white/20
                transition-all duration-150">
  <img src="project.jpg" alt="" class="w-full aspect-[16/10] object-cover saturate-[0.7] contrast-[1.05]" />
  <div class="p-foo-md flex flex-col gap-foo-xs">
    <h3 class="font-primary text-title font-medium text-white/85">Project Title</h3>
    <p class="font-primary text-body font-light text-white/70 line-clamp-2">Description text.</p>
    <div class="flex gap-foo-xs">
      <span class="chip">BOUNDARY</span>
      <span class="chip">PAN-GRAPHY</span>
    </div>
  </div>
  <div class="border-t border-white/8 px-foo-md py-3
              font-mono text-mono uppercase tracking-wide text-white/50">
    2026.02.07 ─ RESEARCH ─ TOKYO
  </div>
</article>

<!-- Section Title -->
<h4 class="font-primary text-section font-semibold uppercase tracking-[0.15em] text-white/50 mb-foo-sm">
  EXPERIMENT LOG
</h4>

<!-- ライトモード Card -->
<article class="light-mode bg-white border border-foo-black shadow-hard-md
                rounded-sharp overflow-hidden
                hover:-translate-x-0.5 hover:-translate-y-0.5
                hover:shadow-[6px_6px_0px_#111111] transition-all duration-150">
  <img src="project.jpg" alt="" class="w-full aspect-[16/10] object-cover" />
  <div class="p-foo-md flex flex-col gap-foo-xs">
    <h3 class="font-primary text-title font-bold text-foo-black">Project Title</h3>
    <p class="font-primary text-body text-foo-black line-clamp-2">Description text.</p>
  </div>
  <div class="border-t border-foo-black px-foo-md py-3
              font-mono text-mono uppercase tracking-wide text-foo-black">
    2026.02.07 ─ WORKSHOP ─ TOKYO
  </div>
</article>
```

#### Web フォント読み込み

```html
<!-- Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@200;300;400;500;600;700;800&family=JetBrains+Mono:wght@400;600&family=Noto+Sans+JP:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<!-- Material Symbols -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@24,400,0,0&family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
```

> **v1.0 からの変更:** Archivo Black を除去。Inter に w200（Thin）〜w800 の幅広いウェイトを追加。Material Symbols Outlined を追加。

#### レスポンシブブレークポイント

| ブレークポイント | 幅 | レイアウト変更 |
|:---|:---|:---|
| Mobile | `< 768px` | 1カラム、ハンバーガーメニュー、フルスクリーンオーバーレイ |
| Tablet | `768px – 1024px` | 2カラムグリッド、スティッキーヘッダー |
| Desktop | `> 1024px` | 3〜4カラムグリッド、フルナビゲーション |

```css
.grid-modules {
  display: grid;
  gap: var(--foo-space-xl);
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .grid-modules {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .grid-modules {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

---

## バージョン履歴

| バージョン | 日付 | 変更内容 |
|:---|:---|:---|
| v1.0 | 2026-02-07 | 初版作成 — "Experimental Industrialism" コンセプトによるデザインシステム |
| v2.0 | 2026-02-08 | 全面改訂 — "Boundary Lab" コンセプトへ移行。ダークファースト、不透明度階層、軽量タイポグラフィ導入。ネオンライムをアクセント（5%以下）に降格。Inter（w200-w800）統一。ボーダーラディウス5段階化。全コンポーネントのダーク/ライト デュアルモード対応。 |

---

本ドキュメントは f∞ studio のブランドアイデンティティと Pan-graphy（汎写真）のコンセプトに基づき、プロジェクト横断的な再利用を目的として構築されたデザインシステムです。
