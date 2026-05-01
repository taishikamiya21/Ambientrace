import 'package:shared_preferences/shared_preferences.dart';

import 'secure_key_storage.dart';

class MigrationService {
  static const int currentSchemaVersion = 2;
  static const String _schemaKey = 'schema_version';

  final SharedPreferences prefs;
  final SecureKeyStorage secure;

  MigrationService({required this.prefs, required this.secure});

  Future<void> run() async {
    final v = prefs.getInt(_schemaKey) ?? 1;
    if (v >= currentSchemaVersion) return;
    if (v < 2) await _migrateToV2();
    await prefs.setInt(_schemaKey, currentSchemaVersion);
  }

  Future<void> _migrateToV2() async {
    const legacy = {
      'gemini_api_key': SecureKeyStorage.geminiKey,
      'openai_api_key': SecureKeyStorage.openaiKey,
      'claude_api_key': SecureKeyStorage.claudeKey,
    };
    for (final entry in legacy.entries) {
      final value = prefs.getString(entry.key);
      if (value != null && value.isNotEmpty) {
        await secure.write(entry.value, value);
        await prefs.remove(entry.key);
      }
    }
  }
}
