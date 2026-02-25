import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white.withValues(alpha: AppOpacity.textHigh)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.trace.imageLabels.isNotEmpty
              ? widget.trace.imageLabels.first
              : widget.trace.atmosphericTime,
          style: AppTypography.body(opacity: AppOpacity.textBody),
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
                      color: Colors.white
                          .withValues(alpha: AppOpacity.textTertiary),
                    ),
                  )
                : Icon(Icons.share_outlined,
                    color: Colors.white
                        .withValues(alpha: AppOpacity.textBody)),
            onPressed: _isSharing ? null : _shareTrace,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color gradient hero
            if (widget.trace.colorPalette.isNotEmpty)
              _buildColorGradientHero(),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // 1. MEANING: Ambient Tags as hero
                  if (widget.trace.imageLabels.isNotEmpty) ...[
                    Text(
                      widget.trace.imageLabels.first,
                      style: AppTypography.headline(),
                    ),
                    if (widget.trace.imageLabels.length > 1) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children:
                            widget.trace.imageLabels.skip(1).map((label) {
                          final index =
                              widget.trace.imageLabels.indexOf(label);
                          final accentColor = widget
                                  .trace.colorPalette.isNotEmpty
                              ? Color(widget.trace.colorPalette[index %
                                      widget.trace.colorPalette.length])
                                  .withValues(alpha: 0.3)
                              : Colors.white.withValues(
                                  alpha: AppOpacity.surfaceElevated);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(
                                  AppRadius.pill),
                              border: Border.all(
                                color: Colors.white.withValues(
                                    alpha: AppOpacity.borderDefault),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              label,
                              style: AppTypography.label(
                                  opacity: AppOpacity.textHigh),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ] else ...[
                    Text(
                      'No ambient traces captured',
                      style: AppTypography.body(
                              opacity: AppOpacity.textMuted)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // 2. FEELING: Color swatches
                  if (widget.trace.colorPalette.isNotEmpty) ...[
                    _buildSectionTitle('Colors'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children:
                          widget.trace.colorPalette.map((colorValue) {
                        return Expanded(
                          child: Container(
                            height: 60,
                            margin: const EdgeInsets.only(
                                right: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: Color(colorValue),
                              borderRadius: BorderRadius.circular(
                                  AppRadius.container),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // 3. CONTEXT: Atmospheric Time + exact time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.trace.atmosphericTime,
                        style: AppTypography.body(
                            opacity: AppOpacity.textSecondary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${widget.trace.formattedTime}  ${widget.trace.formattedDate}',
                        style: AppTypography.mono(
                            opacity: AppOpacity.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Location
                  if (widget.trace.placeName != null) ...[
                    _buildSectionTitle('Location'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoCard(
                      icon: Icons.location_on_outlined,
                      value: widget.trace.placeName!,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Weather & Atmosphere
                  if (widget.trace.temperature != null ||
                      widget.trace.weatherCondition != null ||
                      widget.trace.noiseLevel != null) ...[
                    _buildSectionTitle('Atmosphere'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        if (widget.trace.temperature != null)
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.thermostat_outlined,
                              value:
                                  '${widget.trace.temperature!.round()}\u00B0C',
                            ),
                          ),
                        if (widget.trace.temperature != null &&
                            widget.trace.weatherCondition != null)
                          const SizedBox(width: AppSpacing.sm),
                        if (widget.trace.weatherCondition != null)
                          Expanded(
                            child: _buildInfoCard(
                              icon: _getWeatherIcon(
                                  widget.trace.weatherCondition!),
                              value: widget.trace.weatherCondition!,
                            ),
                          ),
                      ],
                    ),
                    if (widget.trace.noiseLevel != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoCard(
                        icon: Icons.volume_up_outlined,
                        value:
                            '${widget.trace.noiseLevel!.round()} dB',
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  // AI Story Generation
                  _buildStorySection(),
                  const SizedBox(height: AppSpacing.xxl),

                  // Coordinates
                  if (widget.trace.latitude != null &&
                      widget.trace.longitude != null) ...[
                    _buildSectionTitle('Coordinates'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoCard(
                      icon: Icons.explore_outlined,
                      value:
                          '${widget.trace.latitude!.toStringAsFixed(4)}, ${widget.trace.longitude!.toStringAsFixed(4)}',
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGradientHero() {
    final colors =
        widget.trace.colorPalette.map((c) => Color(c)).toList();

    // Build gradient stops from the palette
    final List<Color> gradientColors;
    if (colors.length == 1) {
      gradientColors = [
        colors.first,
        colors.first.withValues(alpha: 0.6)
      ];
    } else {
      gradientColors = colors;
    }

    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      // Fade to background at bottom
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.canvasPrimary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.3, 1.0],
        ),
      ),
    );
  }

  Widget _buildStorySection() {
    final isLlmConfigured =
        widget.imageLabelingService.activeLlmService.isConfigured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('Reconstructed Memory'),
            const SizedBox(width: AppSpacing.xs),
            Tooltip(
              message: ui.PlatformDispatcher.instance.locale
                          .languageCode ==
                      'ja'
                  ? 'AIが環境データ（時間・色・ラベル）からストーリーを生成します。'
                  : 'AI creates a story from the atmospheric data (Time, Color, Labels).',
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(seconds: 3),
              child: Icon(
                Icons.help_outline,
                color: Colors.white
                    .withValues(alpha: AppOpacity.textMuted),
                size: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        if (_generatedStory != null) ...[
          // Display generated story
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white
                      .withValues(alpha: AppOpacity.surfaceContainer),
                  Colors.white
                      .withValues(alpha: AppOpacity.surfaceFaint),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(AppRadius.surface),
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: AppOpacity.borderDefault),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.warning.withValues(alpha: 0.7),
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'AI GENERATED',
                      style: AppTypography.section()
                          .copyWith(color: AppColors.warning.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _generatedStory!,
                  style: AppTypography.body(
                          opacity: AppOpacity.textHigh)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Regenerate button
          Center(
            child: TextButton.icon(
              onPressed:
                  _isGeneratingStory ? null : _generateStory,
              icon: Icon(
                Icons.refresh,
                size: 16,
                color: Colors.white
                    .withValues(alpha: AppOpacity.textTertiary),
              ),
              label: Text(
                'Regenerate',
                style: AppTypography.mono(
                    opacity: AppOpacity.textTertiary),
              ),
            ),
          ),
        ] else if (_isGeneratingStory) ...[
          // Loading state
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: AppOpacity.surfaceSubtle),
              borderRadius:
                  BorderRadius.circular(AppRadius.surface),
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: AppOpacity.borderSubtle),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        AppColors.warning.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Generating memory...',
                  style: AppTypography.mono(
                      opacity: AppOpacity.textTertiary),
                ),
              ],
            ),
          ),
        ] else if (_storyError != null) ...[
          // Error state
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppRadius.container),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _storyError!,
                    style: AppTypography.mono().copyWith(
                      color:
                          AppColors.error.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: _generateStory,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
            ),
          ),
        ] else ...[
          // Generate button — pill style
          GestureDetector(
            onTap: isLlmConfigured ? _generateStory : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: AppOpacity.surfaceSubtle),
                borderRadius:
                    BorderRadius.circular(AppRadius.surface),
                border: Border.all(
                  color: Colors.white
                      .withValues(alpha: AppOpacity.borderSubtle),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: isLlmConfigured
                        ? AppColors.warning
                            .withValues(alpha: 0.7)
                        : Colors.white.withValues(
                            alpha: AppOpacity.textMuted),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isLlmConfigured
                        ? 'Generate Memory'
                        : 'API Key Required',
                    style: AppTypography.label(
                      opacity: isLlmConfigured
                          ? AppOpacity.textHigh
                          : AppOpacity.textCaption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _generateStory() async {
    setState(() {
      _isGeneratingStory = true;
      _storyError = null;
    });

    try {
      final languageCode =
          ui.PlatformDispatcher.instance.locale.languageCode;

      // Convert color palette to descriptions
      final colorDescriptions =
          widget.trace.colorPalette.map((colorValue) {
        final color = Color(colorValue);
        return _describeColor(color);
      }).toList();

      final story = await widget
          .imageLabelingService.activeLlmService
          .generateStory(
        time: widget.trace.formattedTime,
        ambientTraces: widget.trace.imageLabels,
        colorDescriptions: colorDescriptions,
        weather: widget.trace.weatherCondition,
        temperature: widget.trace.temperature != null
            ? '${widget.trace.temperature!.round()}\u00B0C'
            : null,
        placeName: widget.trace.placeName,
        languageCode: languageCode,
      );

      if (mounted) {
        setState(() {
          _generatedStory = story != null ? _sanitizeStory(story) : null;
          _isGeneratingStory = false;
          if (story == null) {
            _storyError =
                'Failed to generate memory. Please try again.';
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

  /// Truncate story to the last complete sentence to prevent mid-sentence cutoff
  String _sanitizeStory(String story) {
    final trimmed = story.trim();
    // Check if already ends with sentence-ending punctuation
    if (trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?') ||
        trimmed.endsWith('。') ||
        trimmed.endsWith('！') ||
        trimmed.endsWith('？')) {
      return trimmed;
    }

    // Find the last sentence-ending punctuation
    int lastEnd = -1;
    for (final punct in ['.', '!', '?', '。', '！', '？']) {
      final idx = trimmed.lastIndexOf(punct);
      if (idx > lastEnd) lastEnd = idx;
    }

    if (lastEnd > 0) {
      return trimmed.substring(0, lastEnd + 1);
    }

    // No sentence-ending punctuation found at all — return as-is
    return trimmed;
  }

  Future<void> _shareTrace() async {
    setState(() => _isSharing = true);

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Create the shareable card widget and render it
      final card = ShareableTraceCard(
        trace: widget.trace,
        story: _generatedStory,
      );

      // Use a temporary overlay to render the widget
      final imageBytes = await _captureWidgetAsImage(card);

      if (imageBytes != null) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();

        // Ensure the directory exists
        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }

        final file = File(
            '${tempDir.path}/ambientrace_${widget.trace.id}.png');
        await file.writeAsBytes(imageBytes);

        if (!mounted) return;

        // Share the image (sharePositionOrigin required for iPad)
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null;

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Captured with Ambientrace',
          sharePositionOrigin: sharePositionOrigin,
        );

        // Haptic feedback on success
        HapticFeedback.mediumImpact();
      }
    } catch (e, stackTrace) {
      print('Share error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Failed to share: ${e.toString().length > 50 ? e.toString().substring(0, 50) : e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.canvasSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppRadius.container)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<List<int>?> _captureWidgetAsImage(Widget widget) async {
    // Create a repaint boundary key
    final repaintKey = GlobalKey();

    // Create an overlay entry to render the widget off-screen
    final overlayState = Overlay.of(context);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -2000, // Off-screen (further away for safety)
        top: -2000,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: repaintKey,
            child: SizedBox(
              width: 400, // Fixed width for consistent rendering
              child: widget,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Wait for the widget to be rendered (longer delay for real devices)
    await Future.delayed(const Duration(milliseconds: 300));

    // Wait for the frame to be rendered
    await WidgetsBinding.instance.endOfFrame;

    try {
      // Capture the image
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        print('Share error: RenderRepaintBoundary is null');
        return null;
      }

      if (!boundary.hasSize) {
        print('Share error: RenderRepaintBoundary has no size');
        return null;
      }

      print(
          'Share: Capturing image with size ${boundary.size}');
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('Share error: byteData is null');
        return null;
      }

      print(
          'Share: Image captured successfully, size: ${byteData.lengthInBytes} bytes');
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Share error in _captureWidgetAsImage: $e');
      rethrow;
    } finally {
      overlayEntry.remove();
    }
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.section(),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white
            .withValues(alpha: AppOpacity.surfaceSubtle),
        borderRadius:
            BorderRadius.circular(AppRadius.container),
        border: Border.all(
          color: Colors.white
              .withValues(alpha: AppOpacity.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: Colors.white
                  .withValues(alpha: AppOpacity.textTertiary),
              size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_outlined;
      case 'cloudy':
        return Icons.cloud_outlined;
      case 'rain':
      case 'showers':
      case 'drizzle':
        return Icons.water_drop_outlined;
      case 'snow':
      case 'snow showers':
        return Icons.ac_unit_outlined;
      case 'thunderstorm':
      case 'thunderstorm with hail':
        return Icons.flash_on_outlined;
      case 'foggy':
        return Icons.foggy;
      default:
        return Icons.cloud_outlined;
    }
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.surface)),
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
                  color: Colors.white
                      .withValues(alpha: AppOpacity.textGhost),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Delete Trace?',
                style: AppTypography.subtitle(
                    opacity: AppOpacity.textHero),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This trace will be permanently deleted.',
                style: AppTypography.body(
                    opacity: AppOpacity.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Delete button — pill shape
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: AppTypography.label().copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Cancel button — pill shape
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white
                        .withValues(alpha: AppOpacity.surfaceSubtle),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppRadius.pill),
                      side: BorderSide(
                        color: Colors.white.withValues(
                            alpha: AppOpacity.borderDefault),
                      ),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTypography.label(
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
