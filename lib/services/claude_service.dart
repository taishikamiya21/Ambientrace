import 'dart:convert';
import 'package:http/http.dart' as http;
import 'llm_service.dart';

class ClaudeService extends LlmService {
  final http.Client _httpClient;

  ClaudeService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  String get providerName => 'Claude';

  @override
  String get apiKeyPrefKey => 'claude_api_key';

  @override
  Future<List<String>> analyzeImage(String imagePath, {String languageCode = 'en'}) async {
    if (!isConfigured) {
      print('Claude: API key not configured');
      return [];
    }

    try {
      final base64Image = await prepareImageBase64(imagePath);
      if (base64Image == null) return [];

      final prompt = buildAnalysisPrompt(languageCode);
      print('Claude: Using language: $languageCode');
      print('Claude: Calling API...');

      final url = Uri.parse('https://api.anthropic.com/v1/messages');

      final body = {
        'model': 'claude-sonnet-4-5',
        'max_tokens': 300,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': prompt,
              },
            ],
          }
        ],
      };

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('Claude: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'] as List?;
        final text = content?.firstWhere(
          (block) => block['type'] == 'text',
          orElse: () => null,
        )?['text'] as String?;

        print('Claude: Response text: $text');

        if (text != null) {
          final labels = parseLabelsResponse(text);
          print('Claude: Parsed ambient traces: $labels');
          return labels;
        }
      } else {
        print('Claude API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error analyzing image with Claude: $e');
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
      print('Claude: API key not configured');
      return null;
    }

    try {
      final url = Uri.parse('https://api.anthropic.com/v1/messages');

      final prompt = buildStoryPrompt(
        time: time,
        ambientTraces: ambientTraces,
        colorDescriptions: colorDescriptions,
        weather: weather,
        temperature: temperature,
        placeName: placeName,
        languageCode: languageCode,
      );

      print('Claude: Generating story...');

      final body = {
        'model': 'claude-sonnet-4-5',
        'max_tokens': 400,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
      };

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 30));

      print('Claude: Story response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'] as List?;
        final text = content?.firstWhere(
          (block) => block['type'] == 'text',
          orElse: () => null,
        )?['text'] as String?;
        print('Claude: Generated story: $text');
        return text?.trim();
      } else {
        print('Claude API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating story with Claude: $e');
    }

    return null;
  }
}
