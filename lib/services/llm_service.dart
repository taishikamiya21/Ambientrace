import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

enum LlmProvider { gemini, openai, claude }

abstract class LlmService {
  String get providerName;
  String get apiKeyPrefKey;

  String? apiKey;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString(apiKeyPrefKey);
  }

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(apiKeyPrefKey, key);
    apiKey = key;
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(apiKeyPrefKey);
    apiKey = null;
  }

  String? get maskedApiKey {
    if (apiKey == null || apiKey!.length < 8) return null;
    return '${apiKey!.substring(0, 4)}...${apiKey!.substring(apiKey!.length - 4)}';
  }

  Future<List<String>> analyzeImage(String imagePath, {String languageCode = 'en'});

  Future<String?> generateStory({
    required String time,
    required List<String> ambientTraces,
    required List<String> colorDescriptions,
    String? weather,
    String? temperature,
    String? placeName,
    required String languageCode,
  });

  /// Compress image to reduce size for API calls
  Future<List<int>?> compressImage(String imagePath) async {
    try {
      final originalBytes = await File(imagePath).readAsBytes();
      print('$providerName: Original image size: ${originalBytes.length} bytes');

      final image = img.decodeImage(originalBytes);
      if (image == null) {
        print('$providerName: Failed to decode image');
        return originalBytes;
      }

      const maxDimension = 1024;
      img.Image resized;
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          resized = img.copyResize(image, width: maxDimension);
        } else {
          resized = img.copyResize(image, height: maxDimension);
        }
        print('$providerName: Resized from ${image.width}x${image.height} to ${resized.width}x${resized.height}');
      } else {
        resized = image;
      }

      final compressed = img.encodeJpg(resized, quality: 80);
      print('$providerName: Compressed image size: ${compressed.length} bytes');
      return compressed;
    } catch (e) {
      print('$providerName: Error compressing image: $e');
      return null;
    }
  }

  /// Prepare base64-encoded image bytes
  Future<String?> prepareImageBase64(String imagePath) async {
    final compressedBytes = await compressImage(imagePath);
    if (compressedBytes == null) {
      print('$providerName: Failed to compress image, using original');
    }
    final imageBytes = compressedBytes ?? await File(imagePath).readAsBytes();
    print('$providerName: Final image size for API: ${imageBytes.length} bytes');
    return base64Encode(imageBytes);
  }

  /// Build prompt for image analysis based on language
  String buildAnalysisPrompt(String languageCode) {
    if (languageCode.startsWith('ja')) {
      return '''この画像を分析し、雰囲気、光、質感、文脈を捉えた短い日本語のフレーズを5〜7個生成してください。
単なる物体のリストではなく、シーンの「空気感」に焦点を当ててください。
例: 「やわらかな午後の陽射し」「静かな朝の空気」「コーヒーの豊かな香り」「古びた木の温もり」「穏やかな時間の流れ」
各フレーズは必ず「〜の（名詞）」や「〜な（名詞）」のような、「体言止め」または完結した名詞句にしてください。
「〜の」で終わるような中途半端なフレーズは絶対に禁止です。
カンマ区切りのフレーズのみを返してください。''';
    }
    return '''Analyze this image and generate 5-7 short, complete phrases that capture the atmosphere, lighting, textures, and context.
Do not just list objects. Focus on the 'feeling' of the scene.
Examples: 'Warm afternoon light', 'Quiet morning', 'Coffee aroma', 'Aged wood warmth', 'Peaceful moment'
Each phrase must be a complete, self-contained expression (1-4 words). Never end with articles like 'a', 'an', 'the'.
Return ONLY comma-separated phrases.''';
  }

  /// Build prompt for story generation based on language
  String buildStoryPrompt({
    required String time,
    required List<String> ambientTraces,
    required List<String> colorDescriptions,
    String? weather,
    String? temperature,
    String? placeName,
    required String languageCode,
  }) {
    final tracesText = ambientTraces.isNotEmpty
        ? ambientTraces.join(', ')
        : 'unknown atmosphere';
    final colorsText = colorDescriptions.isNotEmpty
        ? colorDescriptions.join(', ')
        : 'muted tones';
    final weatherText = weather != null
        ? '$weather${temperature != null ? ', $temperature' : ''}'
        : 'unknown weather';
    final placeText = placeName ?? 'somewhere';

    if (languageCode.startsWith('ja')) {
      return '''以下のデータから、その瞬間の空気感を描写する短い詩的な文章を生成してください。

時刻: $time / 雰囲気: $tracesText / 色彩: $colorsText / 天気: $weatherText / 場所: $placeText

条件:
- 2文の短い散文（合計100文字以内）
- 感覚的・詩的な表現を使用
- 過去形または現在進行形
- 必ず完結した文で終わること''';
    }

    return '''Write a short, poetic narrative from this ambient data. Imagine the scene.

Time: $time / Atmosphere: $tracesText / Colors: $colorsText / Weather: $weatherText / Place: $placeText

Rules:
- Exactly 2 sentences, under 50 words total
- Sensory and poetic, not descriptive
- Past tense or present continuous
- Must end with a complete sentence''';
  }

  /// Parse comma-separated response text into label list
  List<String> parseLabelsResponse(String text) {
    return text
        .replaceAll('\n', ',')
        .replaceAll('、', ',')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length < 50)
        .take(7)
        .toList();
  }

  /// Get stored selected provider
  static Future<LlmProvider> getSelectedProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('selected_llm_provider') ?? 0;
    if (index >= 0 && index < LlmProvider.values.length) {
      return LlmProvider.values[index];
    }
    return LlmProvider.gemini;
  }

  /// Store selected provider
  static Future<void> setSelectedProvider(LlmProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_llm_provider', provider.index);
  }
}
