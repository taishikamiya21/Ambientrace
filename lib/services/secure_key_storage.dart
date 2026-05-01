import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureKeyStorage {
  static const String geminiKey = 'api_key_gemini';
  static const String openaiKey = 'api_key_openai';
  static const String claudeKey = 'api_key_claude';

  final FlutterSecureStorage _storage;

  SecureKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  static String? keyForProvider(String provider) {
    switch (provider) {
      case 'gemini':
        return geminiKey;
      case 'openai':
        return openaiKey;
      case 'claude':
        return claudeKey;
      default:
        return null;
    }
  }

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);
}
