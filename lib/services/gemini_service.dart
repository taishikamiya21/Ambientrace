import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'llm_service.dart';

class GeminiService extends LlmService {
  final http.Client _httpClient;

  GeminiService({http.Client? httpClient, String? apiKey})
      : _httpClient = httpClient ?? http.Client() {
    if (apiKey != null) {
      this.apiKey = apiKey;
    }
  }

  @override
  String get providerName => 'Gemini';

  @override
  String get apiKeyPrefKey => 'gemini_api_key';

  @override
  Future<List<String>> analyzeImage(String imagePath, {String languageCode = 'en'}) async {
    if (!isConfigured) {
      print('Gemini: API key not configured');
      return [];
    }

    try {
      final compressedBytes = await compressImage(imagePath);
      if (compressedBytes == null) {
        print('Gemini: Failed to compress image, using original');
      }

      final imageBytes = compressedBytes ?? await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);
      print('Gemini: Final image size for API: ${imageBytes.length} bytes');

      const mimeType = 'image/jpeg';

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'
      );

      final prompt = buildAnalysisPrompt(languageCode);
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
          'maxOutputTokens': 300,
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
          final labels = parseLabelsResponse(text);
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

  @override
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
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'
      );

      final prompt = buildStoryPrompt(
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
          'maxOutputTokens': 800,
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
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey'
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

    return '''Create an abstract, impressionistic digital painting that evokes the feeling of: $tracesText.
Use a color palette dominated by: $colorsText.
${weatherText.isNotEmpty ? 'Weather atmosphere: $weatherText.' : ''}
${placeText.isNotEmpty ? 'Inspired by the essence of: $placeText.' : ''}
Style: Abstract expressionism, dreamlike, soft gradients, no text, no recognizable faces or people, focus on mood and atmosphere rather than literal representation.''';
  }
}
