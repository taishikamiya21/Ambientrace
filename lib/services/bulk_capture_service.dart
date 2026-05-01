import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:native_exif/native_exif.dart';
import 'package:uuid/uuid.dart';

import '../models/bulk_job.dart';
import '../models/trace_log.dart';
import 'color_service.dart';
import 'image_labeling_service.dart';
import 'location_service.dart';
import 'storage_service.dart';
import 'weather_service.dart';

/// Sequential bulk-capture runner that owns the lifecycle of one `BulkJob` at
/// a time. Emits the live job through `stream` so the progress screen can
/// rebuild on each item state transition. v1.2 ships sequentially; the design
/// spec's 2-parallel + persistent queue + retry/backoff are deferred to v1.3.
class BulkCaptureService {
  BulkCaptureService({
    required this.storageService,
    required this.imageLabelingService,
    required this.colorService,
    required this.locationService,
    required this.weatherService,
  });

  final StorageService storageService;
  final ImageLabelingService imageLabelingService;
  final ColorService colorService;
  final LocationService locationService;
  final WeatherService weatherService;

  final _uuid = const Uuid();

  /// Live job state. The progress screen listens via `ListenableBuilder` so
  /// late subscribers always see the current snapshot — a `Stream` would
  /// have replay-loss issues if the screen attaches after the first emit.
  final BulkJobNotifier jobListenable = BulkJobNotifier();
  bool _cancelRequested = false;

  BulkJob? get activeJob => jobListenable.value;

  Future<BulkJob> start({
    required List<({String path, String originalFileName})> picks,
    required String languageCode,
    String? targetFolderId,
  }) async {
    _cancelRequested = false;
    final job = BulkJob(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      targetFolderId: targetFolderId,
      items: [
        for (final pick in picks)
          BulkJobItem(
            localPhotoPath: pick.path,
            originalFileName: pick.originalFileName,
          ),
      ],
    );
    jobListenable.value = job;
    unawaited(_run(job, languageCode));
    return job;
  }

  void cancel() {
    _cancelRequested = true;
  }

  void _notify() => jobListenable.notify();

  Future<void> _run(BulkJob job, String languageCode) async {
    for (final item in job.items) {
      if (_cancelRequested) {
        item.status = BulkJobStatus.cancelled;
        _notify();
        continue;
      }
      item.status = BulkJobStatus.analyzing;
      item.startedAt = DateTime.now();
      _notify();
      try {
        final traceId = await _processItem(
          item: item,
          languageCode: languageCode,
          targetFolderId: job.targetFolderId,
        );
        item.status = BulkJobStatus.generated;
        item.createdTraceId = traceId;
      } catch (e) {
        item.status = BulkJobStatus.failed;
        item.errorMessage = e.toString();
      } finally {
        item.finishedAt = DateTime.now();
        _notify();
      }
    }
  }

  Future<String> _processItem({
    required BulkJobItem item,
    required String languageCode,
    String? targetFolderId,
  }) async {
    final file = File(item.localPhotoPath);
    DateTime capturedAt = DateTime.now();
    double? lat;
    double? lon;
    try {
      final exif = await Exif.fromPath(item.localPhotoPath);
      final originalDate = await exif.getOriginalDate();
      final latLong = await exif.getLatLong();
      await exif.close();
      if (originalDate != null) capturedAt = originalDate;
      if (latLong != null) {
        lat = latLong.latitude;
        lon = latLong.longitude;
      }
    } catch (_) {
      // EXIF errors are non-fatal — fields stay null.
    }

    final colorsFuture = colorService.extractColors(FileImage(file));
    final labelsFuture = imageLabelingService.getLabelsWithProvider(
      item.localPhotoPath,
      languageCode: languageCode,
    );

    String? placeName;
    double? temperature;
    String? weatherCondition;
    if (lat != null && lon != null) {
      try {
        placeName = await locationService.getPlaceName(lat, lon);
        // v1.2 uses current weather only; historical lookup deferred.
        final w = await weatherService.getCurrentWeather(lat, lon);
        if (w != null) {
          temperature = w.temperature;
          weatherCondition = w.condition;
        }
      } catch (_) {
        // Network errors leave the metadata null.
      }
    }

    final colors = await colorsFuture;
    final labelResult = await labelsFuture;

    final trace = TraceLog(
      id: _uuid.v4(),
      capturedAt: capturedAt,
      createdAt: DateTime.now(),
      latitude: lat,
      longitude: lon,
      placeName: placeName,
      colorPalette: colors,
      imageLabels: labelResult.labels,
      aiProviderUsed: labelResult.provider,
      temperature: temperature,
      weatherCondition: weatherCondition,
      originalFileName: item.originalFileName,
    );
    await storageService.saveTrace(trace);
    if (targetFolderId != null) {
      await storageService.folderService
          .addTraceToFolder(trace.id, targetFolderId);
    }
    return trace.id;
  }

  void dispose() => jobListenable.dispose();
}

/// We mutate `BulkJobItem` in place (cloning per state change is wasteful
/// for N items × N transitions), so the default `ValueNotifier` equality
/// guard would suppress notifications. Subclass to expose a `notify` hook.
class BulkJobNotifier extends ValueNotifier<BulkJob?> {
  BulkJobNotifier() : super(null);
  void notify() => notifyListeners();
}
