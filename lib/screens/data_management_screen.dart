import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/trace_log.dart';
import '../services/bulk_capture_service.dart';
import '../services/color_service.dart';
import '../services/export_service.dart';
import '../services/image_labeling_service.dart';
import '../services/import_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shareable_trace_card.dart';
import 'bulk_progress_screen.dart';

/// Output formats offered to the user when exporting card images. Logical
/// dimensions feed into `MediaQuery` and the offstage `SizedBox` so layout is
/// identical across devices; `pixelRatio` controls the rasterised PNG size.
///
/// `a4` and `a3` are added in v1.2 Phase B (C-7) for print-grade output.
/// The card artwork (text/gradient/swatches) renders at the target
/// resolution via Flutter's rasterizer, so source-photo resolution does not
/// limit the print size.
enum CardExportFormat { businessCard, standard, postcard, a4, a3 }

/// v1.2.1: image import now offers a choice between the iOS Photo Library
/// (native `image_picker`) and the iOS Files app (`file_picker`). Files
/// covers iCloud Drive and other Files-app providers that are not exposed
/// via the Photo Library API.
enum _ImportSource { photoLibrary, files }

class _CardFormatSpec {
  final double logicalWidth;
  final double logicalHeight;
  final double pixelRatio;
  final int outputWidth;
  final int outputHeight;
  const _CardFormatSpec({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.pixelRatio,
    required this.outputWidth,
    required this.outputHeight,
  });
}

extension on CardExportFormat {
  // 300dpi business-card portrait: 55×91mm = 650×1075px. Logical box keeps
  // text rendering at the same DP size as on-screen so typography matches.
  _CardFormatSpec get spec {
    switch (this) {
      case CardExportFormat.businessCard:
        return const _CardFormatSpec(
          logicalWidth: 360,
          logicalHeight: 596,
          pixelRatio: 1.806,
          outputWidth: 650,
          outputHeight: 1076,
        );
      case CardExportFormat.standard:
        return const _CardFormatSpec(
          logicalWidth: 360,
          logicalHeight: 540,
          pixelRatio: 3.0,
          outputWidth: 1080,
          outputHeight: 1620,
        );
      case CardExportFormat.postcard:
        return const _CardFormatSpec(
          logicalWidth: 360,
          logicalHeight: 533,
          pixelRatio: 3.444,
          outputWidth: 1240,
          outputHeight: 1836,
        );
      case CardExportFormat.a4:
        // 210x297mm @ 300dpi = 2480 × 3508 px, portrait
        return const _CardFormatSpec(
          logicalWidth: 360,
          logicalHeight: 509,
          pixelRatio: 6.889,
          outputWidth: 2480,
          outputHeight: 3508,
        );
      case CardExportFormat.a3:
        // 297x420mm @ 300dpi = 3508 × 4961 px, portrait
        return const _CardFormatSpec(
          logicalWidth: 360,
          logicalHeight: 509,
          pixelRatio: 9.744,
          outputWidth: 3508,
          outputHeight: 4961,
        );
    }
  }
}

class _CardExportOptions {
  final CardExportFormat format;
  final bool includeMemory;
  final bool showOriginalFileName;
  const _CardExportOptions({
    required this.format,
    required this.includeMemory,
    required this.showOriginalFileName,
  });
}

/// Sanitize a filename per spec §8-2: strip extension, replace OS-forbidden
/// characters with `_`, cap at 60 chars. Empty input → empty string so
/// callers fall back to `card_{traceId}.png`.
String _sanitizeName(String? input) {
  if (input == null || input.isEmpty) return '';
  final dot = input.lastIndexOf('.');
  final stem = dot > 0 ? input.substring(0, dot) : input;
  final escaped = stem.replaceAll(RegExp(r'[\/\\:\*\?"<>\|]'), '_');
  return escaped.length > 60 ? escaped.substring(0, 60) : escaped;
}

/// Memory-friendly ZIP filename for the export bundle. Spec leaves the outer
/// name unspecified; we use a sortable timestamp.
String _zipFileName(DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'ambientrace_cards_'
      '${now.year}${two(now.month)}${two(now.day)}'
      '_${two(now.hour)}${two(now.minute)}${two(now.second)}.zip';
}

class DataManagementScreen extends StatefulWidget {
  final StorageService storageService;
  final ImageLabelingService? imageLabelingService;

  const DataManagementScreen({
    super.key,
    required this.storageService,
    this.imageLabelingService,
  });

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _includeLocation = true;
  bool _busy = false;

  /// Cancel flag for the C-7 ZIP export. Flipped by the progress dialog;
  /// the render loop checks it between cards.
  final ValueNotifier<bool> _exportCancel = ValueNotifier<bool>(false);

  final _imagePicker = ImagePicker();

  bool get _isJa => Localizations.localeOf(context).languageCode == 'ja';

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error.withValues(alpha: 0.9) : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── JSON / CSV エクスポート ─────────────────────────────

  Future<void> _exportJson() async {
    setState(() => _busy = true);
    try {
      final info = await PackageInfo.fromPlatform();
      final folders = await widget.storageService.folderService.listFolders();
      final traces = widget.storageService.getAllTraces();
      if (traces.isEmpty) {
        _toast(_isJa ? '書き出すトレースがありません' : 'No traces to export');
        return;
      }
      final body = ExportService.buildJson(
        traces: traces,
        folders: folders,
        appVersion: info.version,
        includeLocation: _includeLocation,
      );
      final file = await _writeTemp(
        'ambientrace_${DateTime.now().millisecondsSinceEpoch}.json',
        body,
      );
      await _shareFiles([XFile(file.path)]);
      _toast(
        _isJa
            ? 'JSONを書き出しました (${traces.length}件)'
            : 'Exported JSON (${traces.length} traces)',
      );
    } catch (e) {
      _toast(
        _isJa ? 'JSONの書き出しに失敗しました: $e' : 'Failed to export JSON: $e',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final folders = await widget.storageService.folderService.listFolders();
      final traces = widget.storageService.getAllTraces();
      if (traces.isEmpty) {
        _toast(_isJa ? '書き出すトレースがありません' : 'No traces to export');
        return;
      }
      final lang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final body = ExportService.buildCsv(
        traces: traces,
        folders: folders,
        languageCode: lang,
      );
      final file = await _writeTemp(
        'ambientrace_${DateTime.now().millisecondsSinceEpoch}.csv',
        '﻿$body',
      );
      await _shareFiles([XFile(file.path)]);
      _toast(
        _isJa
            ? 'CSVを書き出しました (${traces.length}件)'
            : 'Exported CSV (${traces.length} traces)',
      );
    } catch (e) {
      _toast(
        _isJa ? 'CSVの書き出しに失敗しました: $e' : 'Failed to export CSV: $e',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<File> _writeTemp(String name, String body) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(body, encoding: utf8);
    return file;
  }

  Future<void> _shareFiles(List<XFile> files, {String? text}) async {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    await Share.shareXFiles(
      files,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  // ── JSON インポート ───────────────────────────────────

  Future<void> _importJson() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    String raw;
    try {
      raw = await File(path).readAsString();
    } catch (e) {
      _toast(
        _isJa ? 'ファイルを読み込めませんでした: $e' : 'Failed to read file: $e',
        error: true,
      );
      return;
    }
    final result = ImportService.dryRun(raw);

    if (!mounted) return;
    final mode = await showDialog<ConflictMode>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(
          _isJa
              ? 'インポート: トレース${result.traceCount}件、フォルダ${result.folderCount}件'
                    '${result.problems.isEmpty ? '' : '\n問題: ${result.problems.length}件'}'
              : 'Import: ${result.traceCount} traces, ${result.folderCount} folders'
                    '${result.problems.isEmpty ? '' : '\nProblems: ${result.problems.length}'}',
        ),
        children: [
          for (final problem in result.problems.take(5))
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('- $problem'),
            ),
          for (final mode in ConflictMode.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, mode),
              child: Text(_conflictModeLabel(mode)),
            ),
        ],
      ),
    );
    if (mode == null) return;

    setState(() => _busy = true);
    try {
      final report = await ImportApply.apply(
        raw: raw,
        storage: widget.storageService,
        mode: mode,
      );
      if (!mounted) return;
      _toast(
        _isJa
            ? 'インポート完了: 新規${report.inserted} / 上書き${report.overwritten} / '
                  'スキップ${report.skipped} / 複製${report.duplicated} / '
                  'マージ${report.merged} / 失敗${report.failed}'
            : 'Imported: ${report.inserted} new, ${report.overwritten} overwritten, '
                  '${report.skipped} skipped, ${report.duplicated} duplicated, '
                  '${report.merged} merged, ${report.failed} failed',
      );
    } catch (e) {
      _toast(
        _isJa ? 'インポートに失敗しました: $e' : 'Failed to import: $e',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _conflictModeLabel(ConflictMode mode) {
    if (_isJa) {
      return switch (mode) {
        ConflictMode.skip => '既存を維持 (スキップ)',
        ConflictMode.overwrite => '上書き',
        ConflictMode.duplicate => '別IDで複製',
        ConflictMode.merge => '欠損項目をマージ',
      };
    }
    return mode.name;
  }

  // ── 画像インポート ─────────────────────────────────────

  /// C-3 一括カード化: pick photos (from Photo Library or Files), prompt for
  /// target folder, launch the progress screen which drives
  /// `BulkCaptureService` end-to-end.
  Future<void> _importImage() async {
    if (widget.imageLabelingService == null) {
      _toast(
        _isJa
            ? '画像インポートには画像ラベリングサービスが必要です'
            : 'Image import requires the image labeling service',
        error: true,
      );
      return;
    }
    final source = await _askImportSource();
    if (source == null) return;

    final picks = source == _ImportSource.photoLibrary
        ? await _pickFromPhotoLibrary()
        : await _pickFromFiles();
    if (picks.isEmpty) return;

    final folderId = await _askTargetFolder();
    if (!mounted) return;

    final service = BulkCaptureService(
      storageService: widget.storageService,
      imageLabelingService: widget.imageLabelingService!,
      colorService: ColorService(),
      locationService: LocationService(),
      weatherService: WeatherService(),
    );
    final lang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final job = await service.start(
      picks: picks,
      languageCode: lang,
      targetFolderId: folderId,
    );
    if (!mounted) {
      service.dispose();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BulkProgressScreen(service: service, initialJob: job),
      ),
    );
    service.dispose();
    if (!mounted) return;
    final isJa = _isJa;
    _toast(
      isJa
          ? '一括カード化: 成功${job.successCount} / 失敗${job.failedCount} / キャンセル${job.cancelledCount}'
          : 'Bulk capture: ${job.successCount} OK / ${job.failedCount} failed / ${job.cancelledCount} cancelled',
    );
  }

  /// Bottom sheet to choose between Photo Library and the iOS Files app.
  /// v1.2.1 added the Files path so users can import images stored in
  /// iCloud Drive or other Files-app providers.
  Future<_ImportSource?> _askImportSource() async {
    final isJa = _isJa;
    return showModalBottomSheet<_ImportSource>(
      context: context,
      backgroundColor: AppColors.canvasSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                isJa ? '取り込み元を選択' : 'Choose import source',
                style: AppTypography.body(
                  color: Colors.white,
                  opacity: AppOpacity.textBody,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Colors.white),
              title: Text(
                isJa ? '写真ライブラリから' : 'From Photo Library',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(ctx, _ImportSource.photoLibrary),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined,
                  color: Colors.white),
              title: Text(
                isJa ? 'ファイルから' : 'From Files',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                isJa
                    ? 'iCloud Drive やその他の場所にある画像'
                    : 'Images from iCloud Drive or other locations',
                style: TextStyle(
                  color: Colors.white
                      .withValues(alpha: AppOpacity.textTertiary),
                  fontSize: 12,
                ),
              ),
              onTap: () => Navigator.pop(ctx, _ImportSource.files),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<List<({String path, String originalFileName})>>
      _pickFromPhotoLibrary() async {
    final picked = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
    );
    return [
      for (final p in picked)
        (path: p.path, originalFileName: p.path.split('/').last),
    ];
  }

  Future<List<({String path, String originalFileName})>>
      _pickFromFiles() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (picked == null) return const [];
    return [
      for (final f in picked.files)
        if (f.path != null)
          (
            path: f.path!,
            originalFileName: f.name.isNotEmpty ? f.name : f.path!.split('/').last
          ),
    ];
  }

  Future<String?> _askTargetFolder() async {
    final folders = await widget.storageService.folderService.listFolders();
    if (!mounted) return null;
    final isJa = _isJa;
    return showDialog<String?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(isJa ? '取り込み先フォルダ' : 'Target folder'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(isJa ? 'フォルダなし' : 'No folder'),
          ),
          for (final folder in folders)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, folder.id),
              child: Text(folder.name),
            ),
        ],
      ),
    );
  }

  // ── カード画像エクスポート ─────────────────────────────

  /// C-7 カード ZIP 出力. Renders every trace through the offscreen
  /// `RepaintBoundary`, packages the PNGs into a ZIP with `cards/` plus an
  /// `index.csv` (originalFileName↔traceId↔outputFileName mapping) and a
  /// `manifest.json` describing the export params.
  Future<void> _exportCardImages() async {
    final traces = widget.storageService.getAllTraces();
    if (traces.isEmpty) {
      _toast(_isJa ? '書き出すトレースがありません' : 'No traces to export');
      return;
    }

    final options = await _askExportOptions();
    if (options == null) return;
    _exportCancel.value = false;
    setState(() => _busy = true);
    final progress = ValueNotifier<int>(0);
    final progressDialog = _showExportProgressDialog(traces.length, progress);

    try {
      final lang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final archive = Archive();
      final indexLines = <String>[
        'originalFileName,traceId,outputFileName',
      ];
      var failed = 0;
      for (var i = 0; i < traces.length; i++) {
        if (_exportCancel.value) break;
        final trace = traces[i];
        progress.value = i;
        try {
          final bytes = await _renderTraceCardToPng(
            trace: trace,
            lang: lang,
            format: options.format,
            includeMemory: options.includeMemory,
            showOriginalFileName: options.showOriginalFileName,
          );
          if (bytes == null) {
            failed++;
            continue;
          }
          final safe = _sanitizeName(trace.originalFileName);
          final outName = safe.isEmpty
              ? 'card_${trace.id}.png'
              : 'card_${safe}_${trace.id}.png';
          archive.addFile(
            ArchiveFile('cards/$outName', bytes.length, bytes),
          );
          indexLines.add(
            '${_csvEscape(trace.originalFileName ?? '')},'
            '${trace.id},'
            '${_csvEscape(outName)}',
          );
        } catch (_) {
          failed++;
        }
      }
      progress.value = traces.length;

      if (archive.isEmpty) {
        _toast(
          _exportCancel.value
              ? (_isJa ? '書き出しをキャンセルしました' : 'Export cancelled')
              : (_isJa ? 'カード画像の生成に失敗しました' : 'Failed to render cards'),
          error: !_exportCancel.value,
        );
        return;
      }

      final manifest = jsonEncode({
        'schemaVersion': 2,
        'exportedAt': DateTime.now().toIso8601String(),
        'params': {
          'format': options.format.name,
          'includeMemory': options.includeMemory,
          'showOriginalFileName': options.showOriginalFileName,
          'traceCount': archive.length,
        },
      });
      archive.addFile(ArchiveFile(
        'index.csv',
        utf8.encode(indexLines.join('\n')).length,
        utf8.encode(indexLines.join('\n')),
      ));
      archive.addFile(ArchiveFile(
        'manifest.json',
        utf8.encode(manifest).length,
        utf8.encode(manifest),
      ));

      final zipBytes = ZipEncoder().encode(archive);
      final dir = await getTemporaryDirectory();
      final zipPath = '${dir.path}/${_zipFileName(DateTime.now())}';
      await File(zipPath).writeAsBytes(zipBytes);
      await _shareFiles([XFile(zipPath)], text: 'Ambientrace cards');

      _toast(
        _isJa
            ? 'ZIP を書き出しました (${archive.length - 2}件 / 失敗$failed件)'
            : 'ZIP exported (${archive.length - 2} cards, $failed failed)',
      );
    } catch (e) {
      _toast(
        _isJa ? 'カード画像の書き出しに失敗しました: $e' : 'Failed to export cards: $e',
        error: true,
      );
    } finally {
      progressDialog?.call();
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Returns a closer that dismisses the progress dialog. Null when context
  /// is unavailable.
  VoidCallback? _showExportProgressDialog(
    int total,
    ValueListenable<int> progress,
  ) {
    if (!mounted) return null;
    final isJa = _isJa;
    final dialogContextCompleter = Completer<BuildContext>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        if (!dialogContextCompleter.isCompleted) {
          dialogContextCompleter.complete(ctx);
        }
        return AlertDialog(
          title: Text(isJa ? 'カード書き出し中' : 'Exporting cards'),
          content: ValueListenableBuilder<int>(
            valueListenable: progress,
            builder: (_, value, _) {
              final ratio = total == 0 ? 0.0 : value / total;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: ratio),
                  const SizedBox(height: 12),
                  Text(
                    isJa ? '$value / $total 件' : '$value / $total',
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => _exportCancel.value = true,
              child: Text(isJa ? 'キャンセル' : 'Cancel'),
            ),
          ],
        );
      },
    );
    return () async {
      if (dialogContextCompleter.isCompleted) {
        final dialogCtx = await dialogContextCompleter.future;
        if (dialogCtx.mounted) {
          Navigator.of(dialogCtx).pop();
        }
      }
    };
  }

  Future<_CardExportOptions?> _askExportOptions() async {
    final isJa = _isJa;
    var format = CardExportFormat.standard;
    var includeMemory = true;
    var showOriginalFileName = false;
    return showDialog<_CardExportOptions>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setSt) => AlertDialog(
          title: Text(isJa ? 'カード画像の書き出し' : 'Export card images'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isJa ? 'サイズ' : 'Size',
                  style: Theme.of(ctx).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                for (final f in CardExportFormat.values)
                  RadioListTile<CardExportFormat>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: f,
                    groupValue: format,
                    onChanged: (v) => setSt(() => format = v ?? format),
                    title: Text(_formatLabel(f)),
                    subtitle: Text(_formatDescription(f)),
                  ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    isJa ? '生成済みのメモリーを含める' : 'Include generated memory',
                  ),
                  subtitle: Text(
                    isJa
                        ? 'aiDescriptionが保存されているトレースのみに反映'
                        : 'Only applies when a story has been generated',
                  ),
                  value: includeMemory,
                  onChanged: (v) => setSt(() => includeMemory = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    isJa ? '元画像のファイル名を表示' : 'Show original filename',
                  ),
                  subtitle: Text(
                    isJa
                        ? '展示用途で写真とカードを照合しやすくします (既定 OFF)'
                        : 'Helps cross-reference photos with cards (off by default)',
                  ),
                  value: showOriginalFileName,
                  onChanged: (v) => setSt(() => showOriginalFileName = v),
                ),
                const SizedBox(height: 8),
                Text(
                  isJa
                      ? '※ カラーは sRGB 前提です。印刷時はプリンター側のカラーマネジメントに依存します。'
                      : 'Color output assumes sRGB; print fidelity depends on the printer.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isJa ? 'キャンセル' : 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                ctx,
                _CardExportOptions(
                  format: format,
                  includeMemory: includeMemory,
                  showOriginalFileName: showOriginalFileName,
                ),
              ),
              child: Text(isJa ? '書き出す' : 'Export'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(CardExportFormat f) {
    if (_isJa) {
      return switch (f) {
        CardExportFormat.businessCard => '名刺サイズ (55×91mm / 300dpi)',
        CardExportFormat.standard => '標準 (1080×1620)',
        CardExportFormat.postcard => 'ハガキサイズ (100×148mm / 300dpi)',
        CardExportFormat.a4 => 'A4 (210×297mm / 300dpi)',
        CardExportFormat.a3 => 'A3 (297×420mm / 300dpi)',
      };
    }
    return switch (f) {
      CardExportFormat.businessCard => 'Business card (55×91mm @300dpi)',
      CardExportFormat.standard => 'Standard (1080×1620)',
      CardExportFormat.postcard => 'Postcard (100×148mm @300dpi)',
      CardExportFormat.a4 => 'A4 (210×297mm @300dpi)',
      CardExportFormat.a3 => 'A3 (297×420mm @300dpi)',
    };
  }

  String _formatDescription(CardExportFormat f) {
    final spec = f.spec;
    return '${spec.outputWidth} × ${spec.outputHeight} px';
  }

  Future<Uint8List?> _renderTraceCardToPng({
    required TraceLog trace,
    required String lang,
    required CardExportFormat format,
    required bool includeMemory,
    bool showOriginalFileName = false,
  }) async {
    final spec = format.spec;
    final boundaryKey = GlobalKey();
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -10000,
        top: -10000,
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(spec.logicalWidth, spec.logicalHeight),
            devicePixelRatio: 1.0,
          ),
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: spec.logicalWidth,
              height: spec.logicalHeight,
              child: RepaintBoundary(
                key: boundaryKey,
                child: TraceCard(
                  trace: trace,
                  languageCode: lang,
                  story: includeMemory ? trace.aiDescription : null,
                  showOriginalFileName: showOriginalFileName,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);

    try {
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: spec.pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    } finally {
      entry.remove();
    }
  }

  // ── UI ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tc = context.onCanvasColor;
    final isJa = _isJa;
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: tc.withValues(alpha: AppOpacity.textHigh),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isJa ? 'データ管理' : 'Data Management',
          style: AppTypography.subtitle(
            color: tc,
            opacity: AppOpacity.textHigh,
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            if (_busy)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),

            _buildSectionHeader(isJa ? '書き出し' : 'Export'),
            SwitchListTile(
              title: Text(
                isJa ? '位置情報を含める' : 'Include location in export',
                style: AppTypography.body(
                  color: tc,
                  opacity: AppOpacity.textHigh,
                ),
              ),
              subtitle: Text(
                isJa
                    ? 'GPS座標と地名を出力ファイルに含めます'
                    : 'Include GPS coordinates and place names',
                style: AppTypography.mono(
                  color: tc,
                  opacity: AppOpacity.textCaption,
                ),
              ),
              value: _includeLocation,
              onChanged: _busy
                  ? null
                  : (v) => setState(() => _includeLocation = v),
            ),
            _buildAction(
              icon: Icons.code,
              title: isJa ? 'JSONを書き出す' : 'Export JSON',
              subtitle: isJa
                  ? '構造化データ (再インポート用)'
                  : 'Structured data (re-importable)',
              onTap: _exportJson,
            ),
            _buildAction(
              icon: Icons.table_chart_outlined,
              title: isJa ? 'CSVを書き出す' : 'Export CSV',
              subtitle: isJa
                  ? 'スプレッドシート用 (UTF-8 BOM付き)'
                  : 'For spreadsheets (UTF-8 with BOM)',
              onTap: _exportCsv,
            ),
            _buildAction(
              icon: Icons.image_outlined,
              title: isJa ? 'カード画像を書き出す' : 'Export card images',
              subtitle: isJa
                  ? '全トレースをPNG画像として共有'
                  : 'Share all traces as PNG images',
              onTap: _exportCardImages,
            ),

            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader(isJa ? '取り込み' : 'Import'),
            _buildAction(
              icon: Icons.upload_file_outlined,
              title: isJa ? 'JSONを取り込む' : 'Import JSON',
              subtitle: isJa
                  ? 'バックアップや他端末からの復元'
                  : 'Restore from backup or another device',
              onTap: _importJson,
            ),
            _buildAction(
              icon: Icons.add_photo_alternate_outlined,
              title: isJa ? '画像から取り込む' : 'Import from images',
              subtitle: isJa
                  ? '既存の写真を解析して新規トレースを作成 (写真自体は保存されません)'
                  : 'Analyse existing photos into new traces (photos are not stored)',
              onTap: _importImage,
            ),

            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                isJa
                    ? '注: APIキーは書き出しに含まれません。色はsRGBで出力されます。'
                    : 'Note: API keys are never included in exports. Output is sRGB; ICC profiles are not embedded.',
                style: AppTypography.mono(
                  color: tc,
                  opacity: AppOpacity.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final tc = context.onCanvasColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.section(
          color: tc,
          opacity: AppOpacity.textBody,
        ),
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final tc = context.onCanvasColor;
    return ListTile(
      leading: Icon(
        icon,
        color: tc.withValues(alpha: AppOpacity.textSecondary),
      ),
      title: Text(
        title,
        style: AppTypography.body(color: tc, opacity: AppOpacity.textHigh),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.mono(
          color: tc,
          opacity: AppOpacity.textCaption,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: tc.withValues(alpha: AppOpacity.textMuted),
      ),
      enabled: !_busy,
      onTap: _busy ? null : onTap,
    );
  }
}
