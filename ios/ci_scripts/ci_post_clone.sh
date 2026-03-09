#!/bin/sh
# Xcode Cloud: クローン後に Flutter の依存関係と CocoaPods をセットアップ
# Pods/ は .gitignore 対象のため CI 環境では手動インストールが必要
set -e

# Flutter SDK のパスを確認
FLUTTER_BIN="$HOME/flutter/bin/flutter"
if [ ! -f "$FLUTTER_BIN" ]; then
  # Homebrew 経由のインストール先にフォールバック
  FLUTTER_BIN=$(which flutter)
fi

echo "Flutter: $FLUTTER_BIN"

# プロジェクトルートへ移動
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Flutter パッケージ取得（Generated.xcconfig を生成）
"$FLUTTER_BIN" pub get

# CocoaPods インストール
cd ios
pod install
