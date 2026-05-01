import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/folder.dart';
import '../models/trace_log.dart';
import 'storage_service.dart';

class ImportDryRunResult {
  final int traceCount;
  final int folderCount;
  final List<String> problems;

  const ImportDryRunResult({
    required this.traceCount,
    required this.folderCount,
    required this.problems,
  });
}

enum ConflictMode { skip, overwrite, duplicate, merge }

class ImportPayload {
  final List<TraceLog> traces;
  final List<Folder> folders;

  const ImportPayload({required this.traces, required this.folders});
}

class ImportService {
  static const int supportedSchema = 2;

  static ImportDryRunResult dryRun(String raw) {
    final problems = <String>[];
    Map<String, dynamic> data;
    try {
      data = json.decode(raw) as Map<String, dynamic>;
    } catch (e) {
      return ImportDryRunResult(
        traceCount: 0,
        folderCount: 0,
        problems: ['Invalid JSON: $e'],
      );
    }

    final version = data['schemaVersion'];
    if (version is! int) {
      problems.add('Missing schemaVersion');
    } else if (version > supportedSchema) {
      problems.add('Unsupported schemaVersion: $version');
    }

    final traces = (data['traces'] as List?) ?? const [];
    var traceCount = 0;
    for (var i = 0; i < traces.length; i++) {
      final rawTrace = traces[i];
      if (rawTrace is! Map<String, dynamic>) {
        problems.add('trace #$i is not an object');
        continue;
      }
      if (rawTrace['id'] == null || (rawTrace['id'] as String).isEmpty) {
        problems.add('trace #$i missing id');
        continue;
      }
      if (rawTrace['capturedAt'] == null) {
        problems.add('trace ${rawTrace['id']} missing capturedAt');
        continue;
      }
      try {
        DateTime.parse(rawTrace['capturedAt'] as String);
      } catch (_) {
        problems.add('trace ${rawTrace['id']} invalid capturedAt');
        continue;
      }
      traceCount++;
    }

    final folders = (data['folders'] as List?) ?? const [];
    var folderCount = 0;
    for (var i = 0; i < folders.length; i++) {
      final rawFolder = folders[i];
      if (rawFolder is! Map<String, dynamic>) {
        problems.add('folder #$i is not an object');
        continue;
      }
      if (rawFolder['id'] == null || rawFolder['name'] == null) {
        problems.add('folder #$i missing id or name');
        continue;
      }
      folderCount++;
    }

    return ImportDryRunResult(
      traceCount: traceCount,
      folderCount: folderCount,
      problems: problems,
    );
  }

  static ImportPayload parse(String raw) {
    final data = json.decode(raw) as Map<String, dynamic>;
    final traces = ((data['traces'] as List?) ?? const [])
        .map((j) => TraceLog.fromJson(j as Map<String, dynamic>))
        .toList();
    final folders = ((data['folders'] as List?) ?? const [])
        .map((j) => Folder.fromJson(j as Map<String, dynamic>))
        .toList();
    return ImportPayload(traces: traces, folders: folders);
  }
}

class ImportReport {
  int inserted = 0;
  int overwritten = 0;
  int skipped = 0;
  int duplicated = 0;
  int merged = 0;
  int failed = 0;
}

extension ImportApply on ImportService {
  static Future<ImportReport> apply({
    required String raw,
    required StorageService storage,
    required ConflictMode mode,
  }) async {
    final payload = ImportService.parse(raw);
    final report = ImportReport();
    final idMap = <String, String>{};
    const uuid = Uuid();

    for (final trace in payload.traces) {
      try {
        final existing = storage.findById(trace.id);
        if (existing == null) {
          await storage.upsertTrace(trace);
          idMap[trace.id] = trace.id;
          report.inserted++;
        } else {
          switch (mode) {
            case ConflictMode.skip:
              idMap[trace.id] = trace.id;
              report.skipped++;
              break;
            case ConflictMode.overwrite:
              await storage.upsertTrace(trace);
              idMap[trace.id] = trace.id;
              report.overwritten++;
              break;
            case ConflictMode.duplicate:
              final newId = uuid.v4();
              await storage.upsertTrace(_renameId(trace, newId));
              idMap[trace.id] = newId;
              report.duplicated++;
              break;
            case ConflictMode.merge:
              final merged = _merge(existing, trace);
              await storage.upsertTrace(merged);
              idMap[trace.id] = trace.id;
              report.merged++;
              break;
          }
        }
      } catch (_) {
        report.failed++;
      }
    }

    for (final folder in payload.folders) {
      final remappedFolder = _remapFolderTraceIds(folder, idMap);
      final allFolders = await storage.folderService.listFolders();
      Folder? existing;
      for (final current in allFolders) {
        if (current.id == remappedFolder.id) {
          existing = current;
          break;
        }
      }

      if (existing == null) {
        await storage.folderService.createFolderWithId(remappedFolder);
      } else {
        for (final traceId in remappedFolder.traceIds) {
          await storage.folderService.addTraceToFolder(traceId, remappedFolder.id);
        }
      }
    }

    return report;
  }

  static Folder _remapFolderTraceIds(Folder folder, Map<String, String> idMap) {
    return Folder(
      id: folder.id,
      name: folder.name,
      createdAt: folder.createdAt,
      traceIds: folder.traceIds.map((id) => idMap[id] ?? id).toList(),
    );
  }

  static TraceLog _renameId(TraceLog trace, String newId) => TraceLog(
    id: newId,
    capturedAt: trace.capturedAt,
    createdAt: trace.createdAt,
    latitude: trace.latitude,
    longitude: trace.longitude,
    placeName: trace.placeName,
    temperature: trace.temperature,
    weatherCondition: trace.weatherCondition,
    noiseLevel: trace.noiseLevel,
    stepCount: trace.stepCount,
    imageLabels: trace.imageLabels,
    colorPalette: trace.colorPalette,
    aiDescription: trace.aiDescription,
    originalFileName: trace.originalFileName,
    aiProviderUsed: trace.aiProviderUsed,
  );

  static TraceLog _merge(TraceLog existing, TraceLog incoming) => TraceLog(
    id: existing.id,
    capturedAt: existing.capturedAt,
    createdAt: existing.createdAt,
    latitude: existing.latitude ?? incoming.latitude,
    longitude: existing.longitude ?? incoming.longitude,
    placeName: existing.placeName ?? incoming.placeName,
    temperature: existing.temperature ?? incoming.temperature,
    weatherCondition: existing.weatherCondition ?? incoming.weatherCondition,
    noiseLevel: existing.noiseLevel ?? incoming.noiseLevel,
    stepCount: existing.stepCount ?? incoming.stepCount,
    imageLabels: existing.imageLabels.isNotEmpty
        ? existing.imageLabels
        : incoming.imageLabels,
    colorPalette: existing.colorPalette.isNotEmpty
        ? existing.colorPalette
        : incoming.colorPalette,
    aiDescription: existing.aiDescription ?? incoming.aiDescription,
    originalFileName: existing.originalFileName ?? incoming.originalFileName,
    aiProviderUsed: existing.aiProviderUsed ?? incoming.aiProviderUsed,
  );
}
