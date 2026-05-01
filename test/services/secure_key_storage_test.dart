import 'package:flutter_test/flutter_test.dart';
import 'package:ambientrace/services/secure_key_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureKeyStorage', () {
    test('keys constant matches spec', () {
      expect(SecureKeyStorage.geminiKey, 'api_key_gemini');
      expect(SecureKeyStorage.openaiKey, 'api_key_openai');
      expect(SecureKeyStorage.claudeKey, 'api_key_claude');
    });

    test('keyForProvider returns correct mapping', () {
      expect(SecureKeyStorage.keyForProvider('gemini'), 'api_key_gemini');
      expect(SecureKeyStorage.keyForProvider('openai'), 'api_key_openai');
      expect(SecureKeyStorage.keyForProvider('claude'), 'api_key_claude');
    });
  });
}
