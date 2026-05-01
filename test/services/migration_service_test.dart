import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ambientrace/services/migration_service.dart';
import 'package:ambientrace/services/secure_key_storage.dart';

class _FakeSecureKeyStorage extends SecureKeyStorage {
  final Map<String, String> store = {};

  _FakeSecureKeyStorage() : super();

  @override
  Future<String?> read(String key) async => store[key];

  @override
  Future<void> write(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    store.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MigrationService', () {
    late SharedPreferences prefs;
    late _FakeSecureKeyStorage secure;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'gemini_api_key': 'g-key',
        'openai_api_key': 'o-key',
      });
      prefs = await SharedPreferences.getInstance();
      secure = _FakeSecureKeyStorage();
    });

    test('migrates v1 (no schema_version) to v2', () async {
      final svc = MigrationService(prefs: prefs, secure: secure);
      await svc.run();

      expect(prefs.getInt('schema_version'), 2);
      expect(secure.store['api_key_gemini'], 'g-key');
      expect(secure.store['api_key_openai'], 'o-key');
      expect(prefs.containsKey('gemini_api_key'), false);
      expect(prefs.containsKey('openai_api_key'), false);
    });

    test('skips migration when already v2', () async {
      await prefs.setInt('schema_version', 2);
      final svc = MigrationService(prefs: prefs, secure: secure);
      await svc.run();

      expect(secure.store, isEmpty);
      expect(prefs.getString('gemini_api_key'), 'g-key');
    });

    test('does not bump schema_version on failure', () async {
      final svc = MigrationService(prefs: prefs, secure: _ThrowingSecure());
      try {
        await svc.run();
      } catch (_) {}
      expect(prefs.getInt('schema_version'), null);
    });
  });
}

class _ThrowingSecure extends SecureKeyStorage {
  _ThrowingSecure() : super();

  @override
  Future<void> write(String key, String value) async {
    throw StateError('boom');
  }
}
