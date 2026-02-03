import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKeyPref = 'gemini_api_key';

  String? _apiKey;
  final http.Client _httpClient;

  GeminiService({http.Client? httpClient, String? apiKey})
      : _httpClient = httpClient ?? http.Client(),
        _apiKey = apiKey;

  /// Initialize and load saved API key
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPref);
  }

  /// Check if API key is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Save API key
  Future<void> setApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
    _apiKey = apiKey;
  }

  /// Clear API key
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPref);
    _apiKey = null;
  }

  /// Get current API key (masked)
  String? get maskedApiKey {
    if (_apiKey == null || _apiKey!.length < 8) return null;
    return '${_apiKey!.substring(0, 4)}...${_apiKey!.substring(_apiKey!.length - 4)}';
  }

  /// Compress image to reduce size for API calls
  /// Returns compressed JPEG bytes, or null if compression fails
  Future<List<int>?> _compressImage(String imagePath) async {
    try {
      final originalBytes = await File(imagePath).readAsBytes();
      print('Gemini: Original image size: ${originalBytes.length} bytes');

      // Decode image
      final image = img.decodeImage(originalBytes);
      if (image == null) {
        print('Gemini: Failed to decode image');
        return originalBytes;
      }

      // Resize if larger than 1024px on longest side
      const maxDimension = 1024;
      img.Image resized;
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          resized = img.copyResize(image, width: maxDimension);
        } else {
          resized = img.copyResize(image, height: maxDimension);
        }
        print('Gemini: Resized from ${image.width}x${image.height} to ${resized.width}x${resized.height}');
      } else {
        resized = image;
      }

      // Encode as JPEG with 80% quality
      final compressed = img.encodeJpg(resized, quality: 80);
      print('Gemini: Compressed image size: ${compressed.length} bytes');
      return compressed;
    } catch (e) {
      print('Gemini: Error compressing image: $e');
      return null;
    }
  }

  /// Build prompt based on language
  String _buildPrompt(String languageCode) {
    if (languageCode.startsWith('ja')) {
      return '''この画像を分析し、雰囲気、光、質感、文脈を捉えた短い日本語のフレーズを5〜7個生成してください。
単なる物体のリストではなく、シーンの「空気感」に焦点を当ててください。
例: 「やわらかな午後の光」「静かな朝」「コーヒーの香り」「古びた木の温もり」「穏やかな時間」
各フレーズは必ず完結した短い表現にしてください。途中で切れた文は禁止です。
カンマ区切りのフレーズのみを返してください。''';
    }
    return '''Analyze this image and generate 5-7 short, complete phrases that capture the atmosphere, lighting, textures, and context.
Do not just list objects. Focus on the 'feeling' of the scene.
Examples: 'Warm afternoon light', 'Quiet morning', 'Coffee aroma', 'Aged wood warmth', 'Peaceful moment'
Each phrase must be a complete, self-contained expression (1-4 words). Never end with articles like 'a', 'an', 'the'.
Return ONLY comma-separated phrases.''';
  }

  /// Analyze image and get labels
  /// [languageCode] should be the device locale (e.g., 'ja', 'en', 'ja_JP')
  Future<List<String>> analyzeImage(String imagePath, {String languageCode = 'en'}) async {
    if (!isConfigured) {
      print('Gemini: API key not configured');
      return [];
    }

    try {
      // Compress image before sending to API
      final compressedBytes = await _compressImage(imagePath);
      if (compressedBytes == null) {
        print('Gemini: Failed to compress image, using original');
      }

      final imageBytes = compressedBytes ?? await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);
      print('Gemini: Final image size for API: ${imageBytes.length} bytes');

      // Always use JPEG mime type since we compress to JPEG
      const mimeType = 'image/jpeg';

      // Use gemini-2.5-flash model (latest multimodal model)
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey'
      );

      final prompt = _buildPrompt(languageCode);
      print('Gemini: Using language: $languageCode');
      print('Gemini: Calling API...');

      final body = {
        'contents': [
          {
            'parts': [
              {
                'inlineData': {
                  'mimeType': mimeType,
                  'data': base64Image,
                }
              },
              {
                'text': prompt
              },
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 200,
        }
      };

      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('Gemini: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        
        print('Gemini: Response text: $text');
        
        if (text != null) {
          // Parse comma-separated ambient phrases
          final labels = text
              .replaceAll('\n', ',')
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty && s.length < 50)
              .take(7)
              .toList();
          print('Gemini: Parsed ambient traces: $labels');
          return labels;
        }
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error analyzing image with Gemini: $e');
    }

    return [];
  }

  /// Generate a narrative story from trace data
  /// [traceData] should contain: time, ambientTraces, colors, weather, placeName
  Future<String?> generateStory({
    required String time,
    required List<String> ambientTraces,
    required List<String> colorDescriptions,
    String? weather,
    String? temperature,
    String? placeName,
    required String languageCode,
  }) async {
    if (!isConfigured) {
      print('Gemini: API key not configured');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey'
      );

      final prompt = _buildStoryPrompt(
        time: time,
        ambientTraces: ambientTraces,
        colorDescriptions: colorDescriptions,
        weather: weather,
        temperature: temperature,
        placeName: placeName,
        languageCode: languageCode,
      );

      print('Gemini: Generating story...');

      final body = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 300,
        }
      };

      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('Gemini: Story response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        print('Gemini: Generated story: $text');
        return text?.trim();
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating story with Gemini: $e');
    }

    return null;
  }

  /// Generate an abstract/artistic image from trace data
  /// Returns base64-encoded image data, or null if generation fails
  Future<String?> generateAISketch({
    required List<String> ambientTraces,
    required List<String> colorDescriptions,
    String? weather,
    String? placeName,
    required String languageCode,
  }) async {
    if (!isConfigured) {
      print('Gemini: API key not configured');
      return null;
    }

    try {
      // Use Gemini 2.0 Flash with image generation capability
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$_apiKey'
      );

      final prompt = _buildSketchPrompt(
        ambientTraces: ambientTraces,
        colorDescriptions: colorDescriptions,
        weather: weather,
        placeName: placeName,
        languageCode: languageCode,
      );

      print('Gemini: Generating AI sketch...');
      print('Gemini: Prompt: $prompt');

      final body = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['image', 'text'],
          'responseMimeType': 'image/png',
        }
      };

      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 90));

      print('Gemini: Sketch response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content?['parts'] as List?;
          if (parts != null) {
            for (final part in parts) {
              final inlineData = part['inlineData'];
              if (inlineData != null) {
                final imageData = inlineData['data'] as String?;
                if (imageData != null) {
                  print('Gemini: Successfully generated sketch');
                  return imageData;
                }
              }
            }
          }
        }
        print('Gemini: No image data in response');
        print('Gemini: Response: ${response.body}');
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating AI sketch with Gemini: $e');
    }

    return null;
  }

  String _buildSketchPrompt({
    required List<String> ambientTraces,
    required List<String> colorDescriptions,
    String? weather,
    String? placeName,
    required String languageCode,
  }) {
    final tracesText = ambientTraces.isNotEmpty
        ? ambientTraces.take(5).join(', ')
        : 'peaceful moment';
    final colorsText = colorDescriptions.isNotEmpty
        ? colorDescriptions.take(4).join(', ')
        : 'muted tones';
    final weatherText = weather ?? '';
    final placeText = placeName ?? '';

    // Create an artistic prompt for abstract/impressionistic image generation
    return '''Create an abstract, impressionistic digital painting that evokes the feeling of: $tracesText.
Use a color palette dominated by: $colorsText.
${weatherText.isNotEmpty ? 'Weather atmosphere: $weatherText.' : ''}
${placeText.isNotEmpty ? 'Inspired by the essence of: $placeText.' : ''}
Style: Abstract expressionism, dreamlike, soft gradients, no text, no recognizable faces or people, focus on mood and atmosphere rather than literal representation.''';
  }

  String _buildStoryPrompt({
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
写真そのものは見えませんが、残されたデータから想像して書いてください。

時刻: $time
雰囲気: $tracesText
色彩: $colorsText
天気: $weatherText
場所: $placeText

2〜3文の短い散文で、その瞬間の「空気」を感じられるように書いてください。
客観的な説明ではなく、感覚的・詩的な表現を使ってください。
「〜だった」「〜している」など、過去形や現在進行形で書いてください。''';
    }

    return '''Generate a short, poetic narrative that captures the atmosphere of this moment based on the following data.
You cannot see the photo, but imagine the scene from the remaining data.

Time: $time
Atmosphere: $tracesText
Colors: $colorsText
Weather: $weatherText
Place: $placeText

Write 2-3 sentences of evocative prose that makes the reader feel the 'air' of that moment.
Use sensory and poetic language, not objective descriptions.
Write in past tense or present continuous, as if recalling a memory.''';
  }
}
