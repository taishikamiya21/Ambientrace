import 'dart:io';
import 'gemini_service.dart';

/// Unified image labeling service that uses the best available method
class ImageLabelingService {
  final GeminiService _geminiService = GeminiService();
  bool _initialized = false;

  /// Initialize the service
  Future<void> init() async {
    await _geminiService.init();
    _initialized = true;
  }

  /// Check if any labeling method is available
  bool get isAvailable {
    // On mobile, ML Kit would be available
    // On other platforms, check if Gemini is configured
    if (Platform.isIOS || Platform.isAndroid) {
      return true; // ML Kit available on real devices
    }
    return _geminiService.isConfigured;
  }

  /// Get the Gemini service for configuration
  GeminiService get geminiService => _geminiService;

  /// Get labels from an image
  /// [languageCode] should be the device locale (e.g., 'ja', 'en', 'ja_JP')
  Future<List<String>> getLabels(String imagePath, {String languageCode = 'en'}) async {
    if (!_initialized) {
      await init();
    }

    print('ImageLabelingService: Getting labels for $imagePath');
    print('ImageLabelingService: Platform is iOS=${Platform.isIOS}, Android=${Platform.isAndroid}');
    print('ImageLabelingService: Gemini configured=${_geminiService.isConfigured}');
    print('ImageLabelingService: Language code=$languageCode');

    // Use Gemini API if configured
    if (_geminiService.isConfigured) {
      print('ImageLabelingService: Using Gemini API');
      final labels = await _geminiService.analyzeImage(imagePath, languageCode: languageCode);
      print('ImageLabelingService: Got labels: $labels');
      return labels;
    }

    print('ImageLabelingService: No labeling method available');
    // No labeling available
    return [];
  }

  /// Dispose resources
  void dispose() {
    // Cleanup if needed
  }
}
