import 'dart:convert';

import 'package:csv/csv.dart';

import '../models/folder.dart';
import '../models/trace_log.dart';

class ExportService {
  static const int schemaVersion = 2;
  static const List<String> _csvHeaders = [
    'id',
    'schemaVersion',
    'capturedAt',
    'createdAt',
    'originalFileName',
    'latitude',
    'longitude',
    'placeName',
    'weatherCondition',
    'temperature',
    'noiseLevel',
    'stepCount',
    'atmosphericTime',
    'imageLabels',
    'colorPaletteHex',
    'aiDescription',
    'aiProviderUsed',
    'folderNames',
  ];

  static String buildJson({
    required List<TraceLog> traces,
    required List<Folder> folders,
    required String appVersion,
    bool includeLocation = true,
  }) {
    final cleanedTraces = includeLocation
        ? traces
        : traces
              .map(
                (t) => TraceLog(
                  id: t.id,
                  capturedAt: t.capturedAt,
                  createdAt: t.createdAt,
                  latitude: null,
                  longitude: null,
                  placeName: null,
                  temperature: t.temperature,
                  weatherCondition: t.weatherCondition,
                  noiseLevel: t.noiseLevel,
                  stepCount: t.stepCount,
                  imageLabels: t.imageLabels,
                  colorPalette: t.colorPalette,
                  aiDescription: t.aiDescription,
                  originalFileName: t.originalFileName,
                  aiProviderUsed: t.aiProviderUsed,
                ),
              )
              .toList();

    return json.encode({
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': appVersion,
      'traces': cleanedTraces.map((t) => t.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
    });
  }

  static String buildCsv({
    required List<TraceLog> traces,
    required List<Folder> folders,
    required String languageCode,
  }) {
    final rows = <List<dynamic>>[_csvHeaders];
    for (final t in traces) {
      final folderNames = folders
          .where((f) => f.traceIds.contains(t.id))
          .map((f) => f.name)
          .join(';');
      rows.add([
        t.id,
        schemaVersion,
        t.capturedAt?.toIso8601String() ?? '',
        t.createdAt.toIso8601String(),
        t.originalFileName ?? '',
        t.latitude ?? '',
        t.longitude ?? '',
        t.placeName ?? '',
        t.weatherCondition ?? '',
        t.temperature ?? '',
        t.noiseLevel ?? '',
        t.stepCount ?? '',
        t.atmosphericTimeForLanguage(languageCode) ?? '',
        t.imageLabels.join(';'),
        t.colorPalette
            .map(
              (c) =>
                  '#${(c & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
            )
            .join(';'),
        t.aiDescription ?? '',
        t.aiProviderUsed ?? '',
        folderNames,
      ]);
    }
    return const ListToCsvConverter(eol: '\n').convert(rows);
  }
}
