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

  group('TraceLog v1.2.1 nullable capturedAt', () {
    test('hasCapturedAt reflects whether the field is set', () {
      final withTime = TraceLog(id: 'a', capturedAt: DateTime(2026, 5, 2));
      final without = TraceLog(id: 'b', capturedAt: null);
      expect(withTime.hasCapturedAt, isTrue);
      expect(without.hasCapturedAt, isFalse);
    });

    test('formatters and atmospheric labels return null when capturedAt is null',
        () {
      final t = TraceLog(id: 'a', capturedAt: null);
      expect(t.formattedTime, isNull);
      expect(t.formattedDate, isNull);
      expect(t.atmosphericTime, isNull);
      expect(t.atmosphericTimeJa, isNull);
      expect(t.atmosphericTimeForLanguage('en'), isNull);
      expect(t.atmosphericTimeForLanguage('ja'), isNull);
    });

    test('createdAt falls back to now() when both inputs are null', () {
      final before = DateTime.now();
      final t = TraceLog(id: 'a', capturedAt: null);
      final after = DateTime.now();
      expect(t.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(t.createdAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });

    test('toJson emits null capturedAt without throwing', () {
      final t = TraceLog(
        id: 'a',
        capturedAt: null,
        createdAt: DateTime(2026, 5, 2),
      );
      final json = t.toJson();
      expect(json['capturedAt'], isNull);
      expect(json['createdAt'], '2026-05-02T00:00:00.000');
    });

    test('fromJson round-trips a trace with null capturedAt', () {
      final source = TraceLog(
        id: 'imported-without-exif',
        capturedAt: null,
        createdAt: DateTime(2026, 5, 2, 10, 0),
        imageLabels: const ['quiet'],
        colorPalette: const [0xFF112233],
        originalFileName: 'untitled.heic',
      );
      final round = TraceLog.fromJson(source.toJson());
      expect(round.capturedAt, isNull);
      expect(round.createdAt, DateTime(2026, 5, 2, 10, 0));
      expect(round.originalFileName, 'untitled.heic');
      expect(round.imageLabels, ['quiet']);
    });

    test('fromJson without capturedAt key produces a trace with null', () {
      final json = {
        'id': 'no-time',
        'createdAt': '2026-05-02T09:00:00.000',
        'imageLabels': [],
        'colorPalette': [],
      };
      final t = TraceLog.fromJson(json);
      expect(t.capturedAt, isNull);
      expect(t.hasCapturedAt, isFalse);
    });
  });
}
