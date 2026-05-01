import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ambientrace/services/prompt_preset_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PromptPresetService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('default preset is Poetic', () async {
      final svc = PromptPresetService();
      await svc.init();
      expect(svc.current, PromptPreset.poetic);
    });

    test('persists selection', () async {
      final svc = PromptPresetService();
      await svc.init();
      await svc.set(PromptPreset.exhibition);

      final svc2 = PromptPresetService();
      await svc2.init();
      expect(svc2.current, PromptPreset.exhibition);
    });

    test('analysisPrompt differs per preset (en)', () {
      final p = PromptPresetService();
      final minimal = p.analysisPrompt(PromptPreset.minimal, 'en');
      final exhibition = p.analysisPrompt(PromptPreset.exhibition, 'en');
      expect(minimal, isNot(exhibition));
    });
  });
}
