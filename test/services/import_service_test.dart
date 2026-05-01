import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ambientrace/models/trace_log.dart';
import 'package:ambientrace/services/import_service.dart';
import 'package:ambientrace/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImportService.dryRun', () {
    test('valid file reports counts', () {
      final raw = json.encode({
        'schemaVersion': 2,
        'traces': [
          {
            'id': 'a',
            'capturedAt': '2026-05-01T00:00:00Z',
            'imageLabels': [],
            'colorPalette': [],
          },
          {
            'id': 'b',
            'capturedAt': '2026-05-01T00:00:00Z',
            'imageLabels': [],
            'colorPalette': [],
          },
        ],
        'folders': [
          {
            'id': 'f',
            'name': 'X',
            'createdAt': '2026-05-01T00:00:00Z',
            'traceIds': ['a'],
          },
        ],
      });
      final result = ImportService.dryRun(raw);
      expect(result.traceCount, 2);
      expect(result.folderCount, 1);
      expect(result.problems, isEmpty);
    });

    test('reports missing required fields', () {
      final raw = json.encode({
        'schemaVersion': 2,
        'traces': [
          {'capturedAt': '2026-05-01T00:00:00Z'},
        ],
        'folders': [],
      });
      final result = ImportService.dryRun(raw);
      expect(result.problems, isNotEmpty);
      expect(result.problems.first, contains('id'));
    });

    test('flags unsupported schema version', () {
      final raw = json.encode({
        'schemaVersion': 99,
        'traces': [],
        'folders': [],
      });
      final result = ImportService.dryRun(raw);
      expect(result.problems.any((p) => p.contains('schemaVersion')), true);
    });
  });

  group('ImportService.apply', () {
    test('skip mode keeps existing trace', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();
      final original = TraceLog(
        id: 'a',
        capturedAt: DateTime(2026, 1, 1),
        aiDescription: 'kept',
      );
      await storage.saveTrace(original);

      final raw = json.encode({
        'schemaVersion': 2,
        'traces': [
          {
            'id': 'a',
            'capturedAt': '2026-05-01T00:00:00Z',
            'aiDescription': 'replaced',
            'imageLabels': [],
            'colorPalette': [],
          },
        ],
        'folders': [],
      });
      final report = await ImportApply.apply(
        raw: raw,
        storage: storage,
        mode: ConflictMode.skip,
      );
      expect(report.skipped, 1);
      final after = storage.findById('a');
      expect(after!.aiDescription, 'kept');
    });

    test('overwrite mode replaces fields', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();
      await storage.saveTrace(
        TraceLog(
          id: 'a',
          capturedAt: DateTime(2026, 1, 1),
          aiDescription: 'old',
        ),
      );
      final raw = json.encode({
        'schemaVersion': 2,
        'traces': [
          {
            'id': 'a',
            'capturedAt': '2026-05-01T00:00:00Z',
            'aiDescription': 'new',
            'imageLabels': [],
            'colorPalette': [],
          },
        ],
        'folders': [],
      });
      await ImportApply.apply(
        raw: raw,
        storage: storage,
        mode: ConflictMode.overwrite,
      );
      expect(storage.findById('a')!.aiDescription, 'new');
    });
  });
}
