import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'gemini_service.dart';

/// Unified image labeling service that uses the best available method
class ImageLabelingService {
  final GeminiService _geminiService = GeminiService();
  ImageLabeler? _imageLabeler;
  bool _initialized = false;

  /// Initialize the service
  Future<void> init() async {
    await _geminiService.init();

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
      return _imageLabeler != null || _geminiService.isConfigured;
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
    print('ImageLabelingService: ML Kit available=${_imageLabeler != null}');
    print('ImageLabelingService: Language code=$languageCode');

    // Prefer Gemini API if configured (better "ambient" labels)
    if (_geminiService.isConfigured) {
      print('ImageLabelingService: Using Gemini API');
      try {
        final labels = await _geminiService.analyzeImage(imagePath, languageCode: languageCode);
        if (labels.isNotEmpty) {
          print('ImageLabelingService: Got Gemini labels: $labels');
          return labels;
        }
      } catch (e) {
        print('ImageLabelingService: Gemini failed - $e');
      }
    }

    // Fall back to ML Kit on mobile devices
    if (_imageLabeler != null && (Platform.isIOS || Platform.isAndroid)) {
      print('ImageLabelingService: Using ML Kit');
      try {
        final inputImage = InputImage.fromFilePath(imagePath);
        final labels = await _imageLabeler!.processImage(inputImage);

        // Convert to ambient-style labels
        final ambientLabels = _convertToAmbientLabels(labels, languageCode: languageCode);
        print('ImageLabelingService: Got ML Kit labels: $ambientLabels');
        return ambientLabels;
      } catch (e) {
        print('ImageLabelingService: ML Kit error - $e');
      }
    }

    print('ImageLabelingService: No labeling method available or all methods failed');
    return [];
  }

  /// Convert ML Kit labels to more "ambient" style labels (localized)
  List<String> _convertToAmbientLabels(List<ImageLabel> labels, {String languageCode = 'en'}) {
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
        final capitalizedLabel = label.label[0].toUpperCase() + label.label.substring(1);
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
