# Privacy Policy for Ambientrace

**Last Updated:** February 3, 2026

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

### Gemini API (Optional)
If you provide a Gemini API key in Settings:
- Image data may be sent to Google's Gemini API for enhanced ambient labeling
- This is subject to Google's Privacy Policy
- You can use the App without Gemini by relying on on-device ML Kit

### Open-Meteo Weather API
- Only GPS coordinates are sent (no personal data)
- Used to fetch weather information
- See: https://open-meteo.com/en/terms

## Data Storage

All ambient trace data is stored **locally on your device only**:
- Data is saved in the app's private storage
- No cloud sync or backup to external servers
- Deleting the app removes all data

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

**最終更新日:** 2026年2月3日

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

### Gemini API（オプション）
設定でGemini APIキーを入力した場合：
- 画像データがGoogleのGemini APIに送信される場合があります
- Googleのプライバシーポリシーが適用されます
- オンデバイスのML Kitのみでも利用可能です

### Open-Meteo天気API
- GPS座標のみ送信（個人データなし）
- 天気情報の取得に使用

## データ保存

すべてのデータは**デバイス上にのみローカル保存**されます：
- アプリのプライベートストレージに保存
- クラウド同期や外部サーバーへのバックアップなし
- アプリを削除するとすべてのデータが削除されます

## お問い合わせ

このプライバシーポリシーに関するご質問：
- GitHub Issues: https://github.com/taishikamiya21/Ambientrace/issues
