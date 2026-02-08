# TestFlight Distribution Guide

このガイドでは、開発メンバーにTestFlight経由でアプリを配布する手順を説明します。

## 1. 前提条件と準備
- **Apple Developer Programへの登録:** 年額$99の登録が必要です。
- **Xcode:** Macにインストールされている必要があります。
- **Bundle ID:** `com.taishikamiya.ambientrace` (仮定) が一意である必要があります。

## 2. App Store Connectでのアプリ作成
1.  [App Store Connect](https://appstoreconnect.apple.com/) にアクセスし、ログインします。
2.  「My Apps」をクリックし、「+」ボタン > 「新規App」を選択します。
3.  以下の情報を入力します:
    -   **プラットフォーム:** iOS
    -   **名前:** Ambientrace
    -   **プライマリ言語:** 日本語
    -   **バンドルID:** Xcodeで設定したものを選択（見つからない場合はXcodeでSignature設定を確認）
    -   **SKU:** 任意のID（例: `ambientrace_ios_001`）
    -   **ユーザアクセス:** 制限なし（または適切に設定）

## 3. Xcodeでのアーカイブとアップロード
1.  **バージョン設定:**
    -   `pubspec.yaml` の `version` を確認します（例: `1.0.0+1`）。
    -   TestFlightに新しいビルドを上げるたびに、`+` の後の数字（ビルド番号）を増やす必要があります（例: `1.0.0+2`）。
2.  **Signing & Capabilities:**
    -   Xcodeで `ios/Runner.xcworkspace` を開きます。
    -   左側のナビゲーターで `Runner` プロジェクトを選択 > TARGETSの `Runner` を選択 > `Signing & Capabilities` タブを開きます。
    -   **Team:** 自分のApple Developerアカウントを選択します。
    -   **Bundle Identifier:** App Store Connectで登録したものと一致させます。
3.  **アーカイブ:**
    -   Productメニュー > **Destination** > **Any iOS Device (arm64)** を選択します（シミュレーターではアーカイブできません）。
    -   Productメニュー > **Archive** を選択します。
4.  **アップロード:**
    -   アーカイブが完了するとOrganizerウィンドウが開きます。
    -   最新のアーカイブを選択し、**"Distribute App"** をクリックします。
    -   **"App Store Connect"** > **"Upload"** を選択し、指示に従って進みます（基本的にはデフォルト設定でOKです）。
    -   "Upload" が成功したら完了です。

## 4. TestFlightでの内部テスト開始
1.  [App Store Connect](https://appstoreconnect.apple.com/) に戻り、「My Apps」>「Ambientrace」>「TestFlight」タブを開きます。
2.  アップロードしたビルドが表示されるまで待ちます（"処理中"から数分〜数十分かかります）。
3.  **内部テスターの追加:**
    -   左メニューの「内部テスト (Internal Testing)」の「+」をクリックし、グループを作成（例: "Dev Team"）。
    -   「テスター」タブで「+」をクリックし、メンバーのApple ID（メールアドレス）を追加します。
    -   **重要:** 内部テスターに追加されたメンバーには招待メールが届きます。
4.  **テスト開始:**
    -   メンバーは自分のiPhoneに「TestFlight」アプリをインストールします。
    -   招待メールのリンク、またはコードを入力して `Ambientrace` をインストールできます。

## 5. 更新手順
アプリを更新して再配布する場合は以下を繰り返します:
1.  `pubspec.yaml` のバージョンを上げる（`1.0.0+1` -> `1.0.0+2`）。
2.  `flutter build ios` (またはXcodeでArchive)。
3.  App Store Connectへアップロード。
4.  TestFlightで新しいビルドが自動的にテスターに通知されます（設定による）。
