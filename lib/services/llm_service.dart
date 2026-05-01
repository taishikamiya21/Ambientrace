import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'prompt_preset_service.dart';
import 'secure_key_storage.dart';

enum LlmProvider { gemini, openai, claude }

abstract class LlmService {
  static SecureKeyStorage secureStorage = SecureKeyStorage();
  static PromptPresetService presetService = PromptPresetService();

  String get providerName;
  String get apiKeyPrefKey;

  String? apiKey;

  Future<void> init() async {
    final secureKey = SecureKeyStorage.keyForProvider(_secureProviderId);
    if (secureKey != null) {
      apiKey = await secureStorage.read(secureKey);
    }
  }

  String get _secureProviderId {
    switch (apiKeyPrefKey) {
      case 'gemini_api_key':
        return 'gemini';
      case 'openai_api_key':
        return 'openai';
      case 'claude_api_key':
        return 'claude';
      default:
        return providerName.toLowerCase();
    }
  }

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  Future<void> setApiKey(String key) async {
    final secureKey = SecureKeyStorage.keyForProvider(_secureProviderId);
    if (secureKey != null) {
      await secureStorage.write(secureKey, key);
    }
    apiKey = key;
  }

  Future<void> clearApiKey() async {
    final secureKey = SecureKeyStorage.keyForProvider(_secureProviderId);
    if (secureKey != null) {
      await secureStorage.delete(secureKey);
    }
    apiKey = null;
  }

  String? get maskedApiKey {
    if (apiKey == null || apiKey!.length < 8) return null;
    return '${apiKey!.substring(0, 4)}...${apiKey!.substring(apiKey!.length - 4)}';
  }

  Future<List<String>> analyzeImage(
    String imagePath, {
    String languageCode = 'en',
  });

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
      print(
        '$providerName: Original image size: ${originalBytes.length} bytes',
      );

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
        print(
          '$providerName: Resized from ${image.width}x${image.height} to ${resized.width}x${resized.height}',
        );
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
    print(
      '$providerName: Final image size for API: ${imageBytes.length} bytes',
    );
    return base64Encode(imageBytes);
  }

  /// Build prompt for image analysis based on language
  String buildAnalysisPrompt(String languageCode) {
    return presetService.analysisPrompt(presetService.current, languageCode);
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
    return presetService.storyPrompt(
      preset: presetService.current,
      time: time,
      ambientTraces: ambientTraces,
      colorDescriptions: colorDescriptions,
      weather: weather,
      temperature: temperature,
      placeName: placeName,
      languageCode: languageCode,
    );
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
