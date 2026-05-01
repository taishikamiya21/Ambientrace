import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ambientrace/models/folder.dart';
import 'package:ambientrace/models/trace_log.dart';
import 'package:ambientrace/services/export_service.dart';

void main() {
  group('ExportService.toJson', () {
    test('emits schemaVersion, traces, and folders', () {
      final t = TraceLog(id: 'a', capturedAt: DateTime(2026, 5, 1));
      final f = Folder(
        id: 'f',
        name: 'Spring',
        createdAt: DateTime(2026, 5, 1),
        traceIds: const ['a'],
      );
      final out = ExportService.buildJson(
        traces: [t],
        folders: [f],
        appVersion: '1.2.0',
      );
      final decoded = json.decode(out);
      expect(decoded['schemaVersion'], 2);
      expect(decoded['appVersion'], '1.2.0');
      expect((decoded['traces'] as List).length, 1);
      expect((decoded['folders'] as List).length, 1);
    });
  });

  group('ExportService.toCsv', () {
    test('renders header row and one trace row', () {
      final t = TraceLog(
        id: 'a',
        capturedAt: DateTime.utc(2026, 5, 1, 12),
        latitude: 35.0,
        longitude: 139.0,
        placeName: 'Tokyo, Japan',
        imageLabels: const ['quiet morning', 'soft light'],
        colorPalette: const [0xFFFFAABB],
        originalFileName: 'IMG_0001.jpg',
        aiProviderUsed: 'gemini',
      );
      final csv = ExportService.buildCsv(
        traces: [t],
        folders: const [],
        languageCode: 'en',
      );
      final lines = csv.split('\n');
      expect(lines.first, contains('id'));
      expect(lines.first, contains('originalFileName'));
      expect(lines[1], contains('a'));
      expect(lines[1], contains('IMG_0001.jpg'));
      expect(lines[1], contains('quiet morning;soft light'));
      expect(lines[1], contains('#FFAABB'));
      expect(lines[1], contains('gemini'));
    });
  });
}
