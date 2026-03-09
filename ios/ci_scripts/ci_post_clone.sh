#!/bin/sh
# Xcode Cloud: クローン後に Flutter SDK・依存関係・CocoaPods をセットアップ
set -e

FLUTTER_VERSION="3.32.0"
FLUTTER_DIR="$HOME/flutter"
FLUTTER="$FLUTTER_DIR/bin/flutter"

echo "▶ Flutter SDK をインストール中 ($FLUTTER_VERSION)..."
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch "stable" \
    "$FLUTTER_DIR"
fi

export PATH="$PATH:$FLUTTER_DIR/bin"

echo "▶ Flutter バージョン確認..."
flutter --version

echo "▶ flutter pub get を実行中..."
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

echo "▶ pod install を実行中..."
cd ios
pod install

echo "✓ セットアップ完了"
