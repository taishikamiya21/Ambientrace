import 'dart:convert';
import 'package:http/http.dart' as http;
import 'llm_service.dart';

class OpenAIService extends LlmService {
  final http.Client _httpClient;

  OpenAIService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  String get providerName => 'ChatGPT';

  @override
  String get apiKeyPrefKey => 'openai_api_key';

  @override
  Future<List<String>> analyzeImage(String imagePath, {String languageCode = 'en'}) async {
    if (!isConfigured) {
      print('OpenAI: API key not configured');
      return [];
    }

    try {
      final base64Image = await prepareImageBase64(imagePath);
      if (base64Image == null) return [];

      final prompt = buildAnalysisPrompt(languageCode);
      print('OpenAI: Using language: $languageCode');
      print('OpenAI: Calling API...');

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      final body = {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
              {
                'type': 'text',
                'text': prompt,
              },
            ],
          }
        ],
        'max_tokens': 300,
        'temperature': 0.7,
      };

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('OpenAI: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;

        print('OpenAI: Response text: $text');

        if (text != null) {
          final labels = parseLabelsResponse(text);
          print('OpenAI: Parsed ambient traces: $labels');
          return labels;
        }
      } else {
        print('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error analyzing image with OpenAI: $e');
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
      print('OpenAI: API key not configured');
      return null;
    }

    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      final prompt = buildStoryPrompt(
        time: time,
        ambientTraces: ambientTraces,
        colorDescriptions: colorDescriptions,
        weather: weather,
        temperature: temperature,
        placeName: placeName,
        languageCode: languageCode,
      );

      print('OpenAI: Generating story...');

      final body = {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 400,
        'temperature': 0.8,
      };

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('OpenAI: Story response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        print('OpenAI: Generated story: $text');
        return text?.trim();
      } else {
        print('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating story with OpenAI: $e');
    }

    return null;
  }
}
