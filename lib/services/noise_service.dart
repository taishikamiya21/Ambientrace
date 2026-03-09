// noise_meter パッケージは audio_streamer への依存により iOS 26 の dyld と非互換。
// iOS 26 対応版がリリースされるまで null を返すスタブとして動作させる。

class NoiseService {
  Future<double?> measureNoiseLevel(
      {Duration duration = const Duration(seconds: 2)}) async {
    return null;
  }

  Future<void> stop() async {}

  void dispose() {}
}
