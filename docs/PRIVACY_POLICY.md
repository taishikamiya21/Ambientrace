# Privacy Policy for Ambientrace

**Last Updated:** May 2, 2026

## Overview

Ambientrace ("the App") is designed with privacy as a core principle. Unlike traditional photo apps, Ambientrace intentionally does not store your photos. Instead, it extracts environmental data (the "ambient trace") from your images and then permanently deletes the original photo.

## Data We Collect

### Data Extracted from Photos
When you capture a moment, the App extracts:
- **Color palette** — The dominant colors in the image
- **Ambient labels** — Descriptive tags about the atmosphere (e.g., "Quiet Morning", "Urban Scene")
- **Noise level** — The ambient sound level in decibels (if microphone permission is granted)

### Location Data (Optional)
If you grant location permission:
- **GPS coordinates** — Your approximate location
- **Place name** — City/area name derived from coordinates

### Weather Data
If location is available, the App fetches:
- **Temperature** — Current temperature at your location
- **Weather condition** — Current weather (sunny, cloudy, etc.)

Weather data is obtained from Open-Meteo, a free weather API that does not require personal information.

## Data We Do NOT Collect

- **Photos** — Images are processed locally and immediately deleted after extracting ambient data
- **Personal information** — No names, emails, or account information
- **Usage analytics** — No tracking or analytics services
- **Advertising data** — No ad networks or identifiers

## Third-Party Services

### Google ML Kit (On-Device)
The App uses Google ML Kit for on-device image labeling. This processing happens entirely on your device, and no image data is sent to Google servers.

### AI Provider APIs (Optional)
The App supports three AI providers for enhanced ambient labeling and Reconstructed Memory generation — Gemini (Google), ChatGPT (OpenAI), and Claude (Anthropic). If you supply an API key for any of them in Settings:
- Image data and prompts may be sent to the selected provider's API
- This is subject to the provider's own privacy policy:
  - Google Gemini: https://ai.google.dev/gemini-api/terms
  - OpenAI: https://openai.com/policies/privacy-policy
  - Anthropic: https://www.anthropic.com/legal/privacy
- You can use the App without any AI provider by relying on on-device ML Kit alone

### Open-Meteo Weather API
- Only GPS coordinates are sent (no personal data)
- Used to fetch weather information
- See: https://open-meteo.com/en/terms

## Data Storage

All ambient trace data is stored **locally on your device only**:
- Data is saved in the app's private storage
- No cloud sync or backup to external servers
- Deleting the app removes all data

## API Key Storage (v1.2+)

When you enter an API key for an AI provider, it is stored in the iOS Keychain (Apple's secure system storage), not in plain-text app preferences. Keys are accessible only to Ambientrace on your device and are removed when the app is uninstalled.

## Data Export (v1.2+)

You can export your trace data from Settings → Data Management in the following formats:
- **JSON** — a full backup including all traces and folders
- **CSV** — a flat list intended for spreadsheets or quick review
- **ZIP archive** — print-ready Trace Cards (A4 / A3 / 300dpi) bundled with `index.csv` and `manifest.json`

Exported files are written to your device's local storage and are shared only when you explicitly use the iOS share sheet. Ambientrace itself does not transmit exported data to any server.

## Your Rights

You can:
- **Delete individual traces** — Swipe or use the delete button
- **Delete all data** — Uninstall the app
- **Deny permissions** — The app works with limited functionality without camera, location, or microphone access

## Children's Privacy

Ambientrace does not knowingly collect data from children under 13. The App is rated 4+ and contains no objectionable content.

## Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be reflected in the "Last Updated" date above.

## Contact

For questions about this Privacy Policy:
- GitHub Issues: https://github.com/taishikamiya21/Ambientrace/issues

---

# プライバシーポリシー（日本語）

**最終更新日:** 2026年5月2日

## 概要

Ambientrace（「本アプリ」）は、プライバシーを核心的な原則として設計されています。従来の写真アプリとは異なり、Ambientraleは意図的に写真を保存しません。代わりに、画像から環境データ（「アンビエントトレース」）を抽出し、元の写真は完全に削除されます。

## 収集するデータ

### 写真から抽出されるデータ
撮影時に抽出されるもの：
- **カラーパレット** — 画像の主要な色
- **アンビエントラベル** — 雰囲気を表すタグ（例：「静かな朝」「都会の風景」）
- **騒音レベル** — 周囲の音量（マイク権限が許可された場合）

### 位置情報（オプション）
位置情報の権限を許可した場合：
- **GPS座標** — おおよその位置
- **地名** — 座標から取得した市区町村名

### 天気データ
位置情報が利用可能な場合：
- **気温** — 現在地の気温
- **天候** — 現在の天気

天気データはOpen-Meteo（個人情報を必要としない無料API）から取得されます。

## 収集しないデータ

- **写真** — 画像はローカルで処理され、抽出後すぐに削除されます
- **個人情報** — 名前、メールアドレス、アカウント情報
- **利用統計** — トラッキングや分析サービスなし
- **広告データ** — 広告ネットワークや識別子なし

## サードパーティサービス

### Google ML Kit（オンデバイス）
画像ラベリングにGoogle ML Kitを使用しますが、処理は完全にデバイス上で行われ、画像データはGoogleサーバーに送信されません。

### AIプロバイダーAPI（オプション）
本アプリは、Reconstructed Memory（雰囲気文章生成）と高度なラベリングのために 3 つの AI プロバイダーに対応しています — Gemini (Google) / ChatGPT (OpenAI) / Claude (Anthropic)。設定でいずれかの API キーを入力した場合：
- 画像データやプロンプトが、選択中のプロバイダーの API に送信される場合があります
- 各社のプライバシーポリシーが適用されます：
  - Google Gemini: https://ai.google.dev/gemini-api/terms
  - OpenAI: https://openai.com/policies/privacy-policy
  - Anthropic: https://www.anthropic.com/legal/privacy
- いずれの API キーも未設定の場合は、オンデバイスの ML Kit のみで動作します

### Open-Meteo天気API
- GPS座標のみ送信（個人データなし）
- 天気情報の取得に使用

## データ保存

すべてのデータは**デバイス上にのみローカル保存**されます：
- アプリのプライベートストレージに保存
- クラウド同期や外部サーバーへのバックアップなし
- アプリを削除するとすべてのデータが削除されます

## API キーの保存（v1.2 以降）

AI プロバイダーの API キーを入力すると、平文のアプリ設定ではなく **iOS Keychain**（Apple のセキュアな保存領域）に格納されます。キーは本アプリのみがアクセス可能で、アプリを削除すると同時に消去されます。

## データエクスポート（v1.2 以降）

設定 → データ管理 から、トレースデータを以下のフォーマットで書き出せます：
- **JSON** — トレースとフォルダを含むフルバックアップ
- **CSV** — 表計算・分析用のフラットリスト
- **ZIP アーカイブ** — `index.csv` / `manifest.json` を同梱したプリント対応カード（A4 / A3 / 300dpi）

書き出したファイルはデバイスのローカルストレージに保存され、iOS のシェアシートを使って明示的に共有した場合のみ外部に渡ります。本アプリ自体は書き出しデータをいかなるサーバーにも送信しません。

## お問い合わせ

このプライバシーポリシーに関するご質問：
- GitHub Issues: https://github.com/taishikamiya21/Ambientrace/issues
