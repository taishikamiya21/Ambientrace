/// State machine for a single image inside a bulk-capture job.
///
/// `pending` → picked but not started.
/// `analyzing` → currently being processed (color extraction, AI label, weather).
/// `generated` → trace persisted, terminal.
/// `failed` → exception thrown, terminal (with `errorMessage`).
/// `cancelled` → user cancelled before this item ran, terminal.
enum BulkJobStatus { pending, analyzing, generated, failed, cancelled }

/// Single image queued in a bulk-capture job. Mutated in place by the service
/// because the job is the unit of UI subscription; cloning per state change
/// would force the screen to diff a list of N items per tick.
class BulkJobItem {
  BulkJobItem({
    required this.localPhotoPath,
    required this.originalFileName,
    this.status = BulkJobStatus.pending,
    this.errorMessage,
    this.createdTraceId,
    this.startedAt,
    this.finishedAt,
  });

  final String localPhotoPath;
  final String originalFileName;
  BulkJobStatus status;
  String? errorMessage;
  String? createdTraceId;
  DateTime? startedAt;
  DateTime? finishedAt;
}

/// One bulk-capture run. v1.2 keeps these in memory only — restart-resume
/// (via the `bulk_jobs` SharedPreferences key in the design doc) is deferred
/// to v1.3. The screen subscribes to `BulkCaptureService` for ticks instead.
class BulkJob {
  BulkJob({
    required this.id,
    required this.items,
    required this.createdAt,
    this.targetFolderId,
  });

  final String id;
  final String? targetFolderId;
  final List<BulkJobItem> items;
  final DateTime createdAt;

  int get total => items.length;
  int get completed => items
      .where((i) =>
          i.status == BulkJobStatus.generated ||
          i.status == BulkJobStatus.failed ||
          i.status == BulkJobStatus.cancelled)
      .length;
  int get successCount =>
      items.where((i) => i.status == BulkJobStatus.generated).length;
  int get failedCount =>
      items.where((i) => i.status == BulkJobStatus.failed).length;
  int get cancelledCount =>
      items.where((i) => i.status == BulkJobStatus.cancelled).length;
}
