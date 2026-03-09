import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/trace_log.dart';
import '../services/storage_service.dart';
import '../services/image_labeling_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shareable_trace_card.dart';

class TraceDetailScreen extends StatefulWidget {
  final TraceLog trace;
  final StorageService storageService;
  final ImageLabelingService imageLabelingService;
  final VoidCallback onDelete;

  const TraceDetailScreen({
    super.key,
    required this.trace,
    required this.storageService,
    required this.imageLabelingService,
    required this.onDelete,
  });

  @override
  State<TraceDetailScreen> createState() => _TraceDetailScreenState();
}

class _TraceDetailScreenState extends State<TraceDetailScreen> {
  String? _generatedStory;
  bool _isGeneratingStory = false;
  String? _storyError;
  bool _isSharing = false;
  bool _isSaving = false;
  final GlobalKey _cardKey = GlobalKey();

  // ストーリーコントロールエリアの固定高さ
  // idle: 上下 md(16) × 2 + ボタン 52px = 84px
  static const double _controlsHeight = 84.0;

  String get _languageCode =>
      ui.PlatformDispatcher.instance.locale.languageCode;

  @override
  Widget build(BuildContext context) {
    final tc = context.onCanvasColor;
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: tc.withValues(alpha: AppOpacity.textHigh)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.trace.imageLabels.isNotEmpty
              ? widget.trace.imageLabels.first
              : widget.trace.atmosphericTimeForLanguage(_languageCode),
          style: AppTypography.body(color: tc, opacity: AppOpacity.textBody),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: _isSharing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tc.withValues(alpha: AppOpacity.textTertiary),
                    ),
                  )
                : Icon(Icons.share_outlined,
                    color: tc.withValues(alpha: AppOpacity.textBody)),
            onPressed: _isSharing ? null : _shareTrace,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // カードエリア: Expanded で高さを固定
            Expanded(
              child: GestureDetector(
                onLongPress: _showCardActionSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: TraceCard(
                      trace: widget.trace,
                      story: _generatedStory,
                      languageCode: _languageCode,
                    ),
                  ),
                ),
              ),
            ),
            // ストーリーコントロール: 固定高さで card サイズを変えない
            SizedBox(
              height: _controlsHeight,
              child: _buildStoryControls(),
            ),
          ],
        ),
      ),
    );
  }

  // ── ストーリーコントロール ───────────────────────────

  Widget _buildStoryControls() {
    final isLlmConfigured =
        widget.imageLabelingService.activeLlmService.isConfigured;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildStoryControlsContent(isLlmConfigured),
    );
  }

  Widget _buildStoryControlsContent(bool isLlmConfigured) {
    final tc = context.onCanvasColor;
    if (_isGeneratingStory) {
      return SizedBox(
        key: const ValueKey('loading'),
        height: _controlsHeight,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.warning.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Generating...',
                style: AppTypography.mono(
                    color: tc, opacity: AppOpacity.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    if (_storyError != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: _controlsHeight,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _storyError!,
                style: AppTypography.mono()
                    .copyWith(color: AppColors.error.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
              TextButton.icon(
                onPressed: _generateStory,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_generatedStory != null) {
      return SizedBox(
        key: const ValueKey('regenerate'),
        height: _controlsHeight,
        child: Center(
          child: TextButton.icon(
            onPressed: _generateStory,
            icon: Icon(
              Icons.refresh,
              size: 16,
              color: tc.withValues(alpha: AppOpacity.textTertiary),
            ),
            label: Text(
              'Regenerate',
              style: AppTypography.mono(
                  color: tc, opacity: AppOpacity.textTertiary),
            ),
          ),
        ),
      );
    }

    // アイドル状態: 上下 md(16) + ボタン 52px = 84px
    return Padding(
      key: const ValueKey('idle'),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: GestureDetector(
        onTap: isLlmConfigured ? _generateStory : null,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: tc.withValues(alpha: AppOpacity.surfaceSubtle),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: tc.withValues(alpha: AppOpacity.borderSubtle),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: isLlmConfigured
                    ? AppColors.warning.withValues(alpha: 0.7)
                    : tc.withValues(alpha: AppOpacity.textMuted),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                isLlmConfigured ? 'Generate Memory' : 'API Key Required',
                style: AppTypography.label(
                  color: tc,
                  opacity: isLlmConfigured
                      ? AppOpacity.textHigh
                      : AppOpacity.textCaption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 長押し: アクションシート ────────────────────────

  Future<void> _showCardActionSheet() async {
    HapticFeedback.mediumImpact();
    await showModalBottomSheet(
      context: context,
      backgroundColor: context.canvasSecondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.surface)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ハンドル
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.onCanvasColor
                      .withValues(alpha: AppOpacity.textGhost),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // フォトライブラリに保存
              _buildActionButton(
                icon: Icons.photo_library_outlined,
                label: _languageCode == 'ja' ? 'フォトライブラリに保存' : 'Save to Library',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _saveToLibrary();
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              // 共有
              _buildActionButton(
                icon: Icons.share_outlined,
                label: _languageCode == 'ja' ? '共有する' : 'Share',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _shareTrace();
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              // キャンセル
              _buildActionButton(
                icon: Icons.close,
                label: _languageCode == 'ja' ? 'キャンセル' : 'Cancel',
                onTap: () => Navigator.pop(ctx),
                muted: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool muted = false,
  }) {
    final tc = context.onCanvasColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: tc.withValues(
              alpha: muted ? AppOpacity.surfaceFaint : AppOpacity.surfaceSubtle),
          borderRadius: BorderRadius.circular(AppRadius.container),
          border: Border.all(
            color: tc.withValues(alpha: AppOpacity.borderSubtle),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: tc.withValues(
                  alpha: muted ? AppOpacity.textCaption : AppOpacity.textBody),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.body(
                color: tc,
                opacity: muted ? AppOpacity.textCaption : AppOpacity.textHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToLibrary() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();
    try {
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) {
        if (mounted) _showSnackBar('写真ライブラリへのアクセスを許可してください。\n設定 > Ambientrace > 写真');
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      await Gal.putImageBytes(byteData.buffer.asUint8List());
      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSnackBar('画像を保存しました');
      }
    } catch (e) {
      if (mounted) _showSnackBar('保存に失敗しました');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── シェア ────────────────────────────────────────────

  Future<void> _shareTrace() async {
    setState(() => _isSharing = true);
    HapticFeedback.lightImpact();
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final file =
          File('${tempDir.path}/ambientrace_${widget.trace.id}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!mounted) return;

      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Captured with Ambientrace',
        sharePositionOrigin: sharePositionOrigin,
      );

      HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        _showSnackBar(
            '共有に失敗しました: ${e.toString().length > 40 ? e.toString().substring(0, 40) : e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // ── ストーリー生成 ────────────────────────────────────

  Future<void> _generateStory() async {
    setState(() {
      _isGeneratingStory = true;
      _storyError = null;
    });

    try {
      final colorDescriptions =
          widget.trace.colorPalette.map((colorValue) {
        final color = Color(colorValue);
        return _describeColor(color);
      }).toList();

      final story =
          await widget.imageLabelingService.activeLlmService.generateStory(
        time: widget.trace.formattedTime,
        ambientTraces: widget.trace.imageLabels,
        colorDescriptions: colorDescriptions,
        weather: widget.trace.weatherCondition,
        temperature: widget.trace.temperature != null
            ? '${widget.trace.temperature!.round()}\u00B0C'
            : null,
        placeName: widget.trace.placeName,
        languageCode: _languageCode,
      );

      if (mounted) {
        setState(() {
          _generatedStory =
              story != null ? _sanitizeStory(story) : null;
          _isGeneratingStory = false;
          if (story == null) {
            _storyError = 'Failed to generate memory. Please try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingStory = false;
          _storyError = 'An error occurred. Please try again.';
        });
      }
    }
  }

  String _sanitizeStory(String story) {
    final trimmed = story.trim();
    if (trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?') ||
        trimmed.endsWith('。') ||
        trimmed.endsWith('！') ||
        trimmed.endsWith('？')) {
      return trimmed;
    }

    int lastEnd = -1;
    for (final punct in ['.', '!', '?', '。', '！', '？']) {
      final idx = trimmed.lastIndexOf(punct);
      if (idx > lastEnd) lastEnd = idx;
    }

    if (lastEnd > 0) {
      return trimmed.substring(0, lastEnd + 1);
    }

    return trimmed;
  }

  String _describeColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final lightness = hsl.lightness;
    final saturation = hsl.saturation;
    final hue = hsl.hue;

    String brightness;
    if (lightness < 0.3) {
      brightness = 'dark';
    } else if (lightness > 0.7) {
      brightness = 'light';
    } else {
      brightness = '';
    }

    String colorName;
    if (saturation < 0.1) {
      if (lightness < 0.2) {
        colorName = 'black';
      } else if (lightness > 0.8) {
        colorName = 'white';
      } else {
        colorName = 'gray';
      }
    } else if (hue < 30) {
      colorName = 'red';
    } else if (hue < 60) {
      colorName = 'orange';
    } else if (hue < 90) {
      colorName = 'yellow';
    } else if (hue < 150) {
      colorName = 'green';
    } else if (hue < 210) {
      colorName = 'cyan';
    } else if (hue < 270) {
      colorName = 'blue';
    } else if (hue < 330) {
      colorName = 'purple';
    } else {
      colorName = 'red';
    }

    return brightness.isEmpty ? colorName : '$brightness $colorName';
  }

  // ── ユーティリティ ────────────────────────────────────

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.canvasSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.container)),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.canvasSecondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.surface)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.onCanvasColor
                      .withValues(alpha: AppOpacity.textGhost),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Delete Trace?',
                style: AppTypography.subtitle(
                    color: context.onCanvasColor,
                    opacity: AppOpacity.textHero),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This trace will be permanently deleted.',
                style: AppTypography.body(
                    color: context.onCanvasColor,
                    opacity: AppOpacity.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    await widget.storageService
                        .deleteTrace(widget.trace.id);
                    widget.onDelete();
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        AppColors.error.withValues(alpha: 0.15),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: AppTypography.label()
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: context.onCanvasColor
                        .withValues(alpha: AppOpacity.surfaceSubtle),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                      side: BorderSide(
                        color: context.onCanvasColor.withValues(
                            alpha: AppOpacity.borderDefault),
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTypography.label(
                        color: context.onCanvasColor,
                        opacity: AppOpacity.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
