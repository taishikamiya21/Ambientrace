import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'llm_service.dart';
import 'gemini_service.dart';
import 'openai_service.dart';
import 'claude_service.dart';

class LabelResult {
  final List<String> labels;
  final String? provider;

  const LabelResult(this.labels, this.provider);
}

/// Unified image labeling service that uses the best available method
class ImageLabelingService {
  final GeminiService geminiService = GeminiService();
  final OpenAIService openaiService = OpenAIService();
  final ClaudeService claudeService = ClaudeService();
  LlmProvider _selectedProvider = LlmProvider.gemini;
  ImageLabeler? _imageLabeler;
  bool _initialized = false;

  /// Get the active LLM service based on selected provider
  LlmService get activeLlmService => switch (_selectedProvider) {
    LlmProvider.gemini => geminiService,
    LlmProvider.openai => openaiService,
    LlmProvider.claude => claudeService,
  };

  /// Get/set the selected provider
  LlmProvider get selectedProvider => _selectedProvider;

  Future<void> setSelectedProvider(LlmProvider provider) async {
    _selectedProvider = provider;
    await LlmService.setSelectedProvider(provider);
  }

  /// Initialize the service
  Future<void> init() async {
    // Initialize all LLM services
    await geminiService.init();
    await openaiService.init();
    await claudeService.init();

    // Load saved provider selection
    _selectedProvider = await LlmService.getSelectedProvider();

    // Initialize ML Kit on mobile platforms
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        _imageLabeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: 0.5),
        );
        print('ImageLabelingService: ML Kit initialized');
      } catch (e) {
        print('ImageLabelingService: Failed to initialize ML Kit - $e');
      }
    }

    _initialized = true;
  }

  /// Check if any labeling method is available
  bool get isAvailable {
    if (Platform.isIOS || Platform.isAndroid) {
      return _imageLabeler != null || activeLlmService.isConfigured;
    }
    return activeLlmService.isConfigured;
  }

  /// Get labels from an image
  /// [languageCode] should be the device locale (e.g., 'ja', 'en', 'ja_JP')
  Future<List<String>> getLabels(
    String imagePath, {
    String languageCode = 'en',
  }) async {
    final result = await getLabelsWithProvider(
      imagePath,
      languageCode: languageCode,
    );
    return result.labels;
  }

  /// Get labels and the provider that produced them.
  /// [languageCode] should be the device locale (e.g., 'ja', 'en', 'ja_JP')
  Future<LabelResult> getLabelsWithProvider(
    String imagePath, {
    String languageCode = 'en',
  }) async {
    if (!_initialized) {
      await init();
    }

    print('ImageLabelingService: Getting labels for $imagePath');
    print(
      'ImageLabelingService: Platform is iOS=${Platform.isIOS}, Android=${Platform.isAndroid}',
    );
    print(
      'ImageLabelingService: Active provider=${activeLlmService.providerName}, configured=${activeLlmService.isConfigured}',
    );
    print('ImageLabelingService: ML Kit available=${_imageLabeler != null}');
    print('ImageLabelingService: Language code=$languageCode');

    // Prefer active LLM service if configured
    if (activeLlmService.isConfigured) {
      print('ImageLabelingService: Using ${activeLlmService.providerName} API');
      try {
        final labels = await activeLlmService.analyzeImage(
          imagePath,
          languageCode: languageCode,
        );
        if (labels.isNotEmpty) {
          print(
            'ImageLabelingService: Got ${activeLlmService.providerName} labels: $labels',
          );
          return LabelResult(labels, _providerToString(_selectedProvider));
        }
      } catch (e) {
        print(
          'ImageLabelingService: ${activeLlmService.providerName} failed - $e',
        );
      }
    }

    // Fall back to ML Kit on mobile devices
    if (_imageLabeler != null && (Platform.isIOS || Platform.isAndroid)) {
      print('ImageLabelingService: Using ML Kit');
      try {
        final inputImage = InputImage.fromFilePath(imagePath);
        final labels = await _imageLabeler!.processImage(inputImage);

        // Convert to ambient-style labels
        final ambientLabels = _convertToAmbientLabels(
          labels,
          languageCode: languageCode,
        );
        print('ImageLabelingService: Got ML Kit labels: $ambientLabels');
        return LabelResult(ambientLabels, 'mlkit');
      } catch (e) {
        print('ImageLabelingService: ML Kit error - $e');
      }
    }

    print(
      'ImageLabelingService: No labeling method available or all methods failed',
    );
    return const LabelResult([], null);
  }

  String _providerToString(LlmProvider p) {
    switch (p) {
      case LlmProvider.gemini:
        return 'gemini';
      case LlmProvider.openai:
        return 'openai';
      case LlmProvider.claude:
        return 'claude';
    }
  }

  /// Convert ML Kit labels to more "ambient" style labels (localized)
  List<String> _convertToAmbientLabels(
    List<ImageLabel> labels, {
    String languageCode = 'en',
  }) {
    final ambientMap = languageCode.startsWith('ja')
        ? _ambientMapJa
        : _ambientMapEn;

    final result = <String>[];
    for (final label in labels) {
      final text = label.label.toLowerCase();

      // Check if we have an ambient mapping
      for (final entry in ambientMap.entries) {
        if (text.contains(entry.key)) {
          if (!result.contains(entry.value)) {
            result.add(entry.value);
          }
          break;
        }
      }

      // If no mapping found and confidence is high, use the original label
      if (result.length < 5 && label.confidence > 0.7) {
        final capitalizedLabel =
            label.label[0].toUpperCase() + label.label.substring(1);
        if (!result.contains(capitalizedLabel)) {
          result.add(capitalizedLabel);
        }
      }

      // Limit to 5 labels
      if (result.length >= 5) break;
    }

    return result;
  }

  static const Map<String, String> _ambientMapEn = {
    'sky': 'Open Sky',
    'cloud': 'Cloudy Atmosphere',
    'tree': 'Natural Setting',
    'plant': 'Green Space',
    'flower': 'Floral Moment',
    'water': 'Waterside',
    'sea': 'Seaside',
    'beach': 'Beach Vibes',
    'mountain': 'Mountain View',
    'building': 'Urban Scene',
    'city': 'City Life',
    'street': 'Street Scene',
    'road': 'On the Road',
    'car': 'Mobile Moment',
    'food': 'Culinary Moment',
    'drink': 'Refreshment Time',
    'coffee': 'Coffee Break',
    'restaurant': 'Dining Out',
    'cafe': 'Cafe Atmosphere',
    'person': 'Human Presence',
    'people': 'Social Gathering',
    'animal': 'Animal Encounter',
    'dog': 'Canine Company',
    'cat': 'Feline Friend',
    'bird': 'Avian Presence',
    'sunrise': 'Dawn Light',
    'sunset': 'Golden Hour',
    'night': 'Night Scene',
    'indoor': 'Indoor Space',
    'outdoor': 'Outdoor Setting',
    'park': 'Park Setting',
    'garden': 'Garden Space',
    'home': 'Home Comfort',
    'office': 'Work Environment',
    'book': 'Reading Moment',
    'music': 'Musical Atmosphere',
    'art': 'Artistic Scene',
  };

  static const Map<String, String> _ambientMapJa = {
    'sky': '広がる空',
    'cloud': '曇り空',
    'tree': '木々のそば',
    'plant': '緑のある場所',
    'flower': '花のある瞬間',
    'water': '水辺',
    'sea': '海のそば',
    'beach': '砂浜の風',
    'mountain': '山の景色',
    'building': '街の風景',
    'city': '都会の息吹',
    'street': '通りの景色',
    'road': '道の途中',
    'car': '移動の途中',
    'food': '食のひととき',
    'drink': 'ひと休み',
    'coffee': 'コーヒーブレイク',
    'restaurant': '食事の時間',
    'cafe': 'カフェの空気',
    'person': '人の気配',
    'people': '集いの場',
    'animal': '動物との出会い',
    'dog': '犬のいる場所',
    'cat': '猫のいる場所',
    'bird': '鳥の気配',
    'sunrise': '朝の光',
    'sunset': '黄金の時間',
    'night': '夜の風景',
    'indoor': '室内の空間',
    'outdoor': '外の空気',
    'park': '公園の空気',
    'garden': '庭の緑',
    'home': '家の温もり',
    'office': '仕事場の空気',
    'book': '読書の時間',
    'music': '音楽のある空間',
    'art': '芸術の空間',
  };

  /// Dispose resources
  void dispose() {
    _imageLabeler?.close();
    _imageLabeler = null;
  }
}
