import 'package:flutter_test/flutter_test.dart';
import 'package:ambientrace/models/trace_log.dart';

void main() {
  group('TraceLog v1.2 fields', () {
    test('originalFileName and aiProviderUsed default to null', () {
      final t = TraceLog(id: 'a', capturedAt: DateTime(2026, 5, 1));
      expect(t.originalFileName, isNull);
      expect(t.aiProviderUsed, isNull);
    });

    test('toJson/fromJson round trip preserves new fields', () {
      final t = TraceLog(
        id: 'a',
        capturedAt: DateTime(2026, 5, 1),
        originalFileName: 'IMG_0001.jpg',
        aiProviderUsed: 'gemini',
      );
      final round = TraceLog.fromJson(t.toJson());
      expect(round.originalFileName, 'IMG_0001.jpg');
      expect(round.aiProviderUsed, 'gemini');
    });

    test('fromJson tolerates missing new fields (v1.1 data)', () {
      final json = {
        'id': 'old',
        'capturedAt': '2026-01-01T00:00:00Z',
        'imageLabels': [],
        'colorPalette': [],
      };
      final t = TraceLog.fromJson(json);
      expect(t.originalFileName, isNull);
      expect(t.aiProviderUsed, isNull);
    });
  });
}
