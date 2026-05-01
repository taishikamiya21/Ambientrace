import 'package:flutter/material.dart';

import '../models/bulk_job.dart';
import '../services/bulk_capture_service.dart';
import '../theme/app_theme.dart';

/// Live progress UI for a `BulkCaptureService` job. Subscribes to the
/// service's job stream so each item state transition rebuilds the list.
/// Cancel button flips the service's cancel flag; remaining `pending` items
/// finish in `cancelled` state. Per-item failures are surfaced inline.
class BulkProgressScreen extends StatefulWidget {
  const BulkProgressScreen({
    super.key,
    required this.service,
    required this.initialJob,
  });

  final BulkCaptureService service;
  final BulkJob initialJob;

  @override
  State<BulkProgressScreen> createState() => _BulkProgressScreenState();
}

class _BulkProgressScreenState extends State<BulkProgressScreen> {
  late BulkJob _job = widget.initialJob;

  bool get _isJa =>
      Localizations.localeOf(context).languageCode == 'ja';

  bool get _isFinished => _job.completed >= _job.total;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isFinished,
      child: ListenableBuilder(
        listenable: widget.service.jobListenable,
        builder: (context, _) {
          _job = widget.service.jobListenable.value ?? widget.initialJob;
          final tc = context.onCanvasColor;
          return Scaffold(
            backgroundColor: context.canvasColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                _isJa ? '一括カード化' : 'Bulk Card Capture',
                style: AppTypography.subtitle(
                  color: tc,
                  opacity: AppOpacity.textHigh,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(tc),
                  _buildNotices(tc),
                  Expanded(child: _buildItemList(tc)),
                  _buildFooter(tc),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Color tc) {
    final ratio = _job.total == 0 ? 0.0 : _job.completed / _job.total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isJa
                ? '${_job.completed} / ${_job.total} 件 完了'
                : '${_job.completed} / ${_job.total} done',
            style: AppTypography.headline(
              color: tc,
              opacity: AppOpacity.textHigh,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isJa
                ? '成功 ${_job.successCount} / 失敗 ${_job.failedCount} / キャンセル ${_job.cancelledCount}'
                : 'OK ${_job.successCount} / Failed ${_job.failedCount} / Cancelled ${_job.cancelledCount}',
            style: AppTypography.mono(
              color: tc,
              opacity: AppOpacity.textCaption,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: tc.withValues(alpha: AppOpacity.surfaceSubtle),
              valueColor: AlwaysStoppedAnimation<Color>(
                tc.withValues(alpha: AppOpacity.textBody),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotices(Color tc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _notice(
            Icons.battery_charging_full_outlined,
            _isJa
                ? 'アプリを開いたままにしてください。バックグラウンドでは進行が一時停止します。'
                : 'Keep the app open. Background processing is paused.',
            tc,
          ),
          _notice(
            Icons.location_on_outlined,
            _isJa
                ? '画像の EXIF から撮影日時と GPS 位置情報を読み取ります。'
                : 'EXIF capture date and GPS location are read from each photo.',
            tc,
          ),
        ],
      ),
    );
  }

  Widget _notice(IconData icon, String text, Color tc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: tc.withValues(alpha: AppOpacity.textMuted)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.mono(
                color: tc,
                opacity: AppOpacity.textCaption,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(Color tc) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      itemCount: _job.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (_, idx) {
        final item = _job.items[idx];
        return _buildItemRow(item, tc);
      },
    );
  }

  Widget _buildItemRow(BulkJobItem item, Color tc) {
    final (icon, color, label) = _statusVisual(item, tc);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tc.withValues(alpha: AppOpacity.surfaceSubtle),
        borderRadius: BorderRadius.circular(AppRadius.container),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.originalFileName,
                  style: AppTypography.body(
                    color: tc,
                    opacity: AppOpacity.textBody,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.errorMessage ?? label,
                  style: AppTypography.mono(
                    color: tc,
                    opacity: item.status == BulkJobStatus.failed
                        ? AppOpacity.textHigh
                        : AppOpacity.textCaption,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _statusVisual(BulkJobItem item, Color tc) {
    switch (item.status) {
      case BulkJobStatus.pending:
        return (
          Icons.schedule_outlined,
          tc.withValues(alpha: AppOpacity.textMuted),
          _isJa ? '待機中' : 'Pending',
        );
      case BulkJobStatus.analyzing:
        return (
          Icons.sync,
          tc.withValues(alpha: AppOpacity.textHigh),
          _isJa ? '解析中…' : 'Analyzing…',
        );
      case BulkJobStatus.generated:
        return (
          Icons.check_circle_outline,
          AppColors.success,
          _isJa ? '生成完了' : 'Generated',
        );
      case BulkJobStatus.failed:
        return (
          Icons.error_outline,
          AppColors.warning,
          _isJa ? '失敗' : 'Failed',
        );
      case BulkJobStatus.cancelled:
        return (
          Icons.block,
          tc.withValues(alpha: AppOpacity.textMuted),
          _isJa ? 'キャンセル' : 'Cancelled',
        );
    }
  }

  Widget _buildFooter(Color tc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: _isFinished
            ? FilledButton(
                onPressed: () => Navigator.of(context).pop(_job),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                child: Text(
                  _isJa ? '閉じる' : 'Close',
                ),
              )
            : OutlinedButton(
                onPressed: widget.service.cancel,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  side: BorderSide(
                    color: tc.withValues(alpha: AppOpacity.borderSubtle),
                  ),
                ),
                child: Text(
                  _isJa ? 'キャンセル' : 'Cancel',
                  style: AppTypography.label(
                    color: tc,
                    opacity: AppOpacity.textHigh,
                  ),
                ),
              ),
      ),
    );
  }
}
