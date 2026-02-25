import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trace_log.dart';
import '../theme/app_theme.dart';

class TraceCard extends StatefulWidget {
  final TraceLog trace;
  final VoidCallback? onTap;

  const TraceCard({super.key, required this.trace, this.onTap});

  @override
  State<TraceCard> createState() => _TraceCardState();
}

class _TraceCardState extends State<TraceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final trace = widget.trace;
    final paletteColors = trace.colorPalette.map((c) => Color(c)).toList();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: AppOpacity.surfaceSubtle),
            borderRadius: BorderRadius.circular(AppRadius.container),
            border: Border.all(
              color: Colors.white.withValues(alpha: AppOpacity.borderDefault),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero: Primary tag as card title
                if (trace.imageLabels.isNotEmpty) ...[
                  Text(
                    trace.imageLabels.first,
                    style: AppTypography.title(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Secondary: Atmospheric Time as subtitle
                  Text(
                    trace.atmosphericTime,
                    style: AppTypography.subtitle(
                        opacity: AppOpacity.textSecondary),
                  ),
                  if (trace.imageLabels.length > 1) ...[
                    SizedBox(height: AppSpacing.sm),
                    // Remaining tags as pill chips
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children:
                          trace.imageLabels.skip(1).take(3).map((label) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: Colors.white.withValues(
                                  alpha: AppOpacity.borderDefault),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            label.toUpperCase(),
                            style: AppTypography.mono(
                                opacity: AppOpacity.textSecondary),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ] else ...[
                  Text(
                    trace.atmosphericTime,
                    style: AppTypography.title(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white
                            .withValues(alpha: AppOpacity.textMuted),
                        size: 14,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          ui.PlatformDispatcher.instance.locale.languageCode
                                  .startsWith('ja')
                              ? 'AIプロバイダーを設定するとラベルが付きます'
                              : 'Set up an AI provider in Settings for richer labels',
                          style: AppTypography.body(
                                  opacity: AppOpacity.textGhost)
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: AppSpacing.md),

                // Color gradient bar + metadata footer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Color palette gradient bar
                    SizedBox(
                      width: 40,
                      child: _buildColorBar(paletteColors),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    // Footer metadata: exact time
                    Text(
                      trace.formattedTime.toUpperCase(),
                      style: AppTypography.mono(
                          opacity: AppOpacity.textTertiary),
                    ),
                    const Spacer(),
                    // Metadata inline
                    ..._buildMetaItems(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Horizontal gradient bar from palette colors
  Widget _buildColorBar(List<Color> paletteColors) {
    if (paletteColors.isEmpty) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: AppOpacity.surfaceSubtle),
          borderRadius: BorderRadius.circular(AppRadius.technical),
        ),
      );
    }

    final barColors = paletteColors.length == 1
        ? [paletteColors[0], paletteColors[0].withValues(alpha: 0.4)]
        : paletteColors.take(5).toList();

    return Container(
      height: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: barColors,
        ),
        borderRadius: BorderRadius.circular(AppRadius.technical),
      ),
    );
  }

  /// Inline metadata items for the bottom row
  List<Widget> _buildMetaItems() {
    final trace = widget.trace;
    final items = <Widget>[];

    if (trace.temperature != null) {
      items.add(Text(
        '${trace.temperature!.round()}°',
        style: AppTypography.mono(opacity: AppOpacity.textTertiary),
      ));
    }
    if (trace.weatherCondition != null) {
      if (items.isNotEmpty) {
        items.add(SizedBox(
          height: 10,
          child: VerticalDivider(
            color: Colors.white.withValues(alpha: AppOpacity.borderDefault),
            width: AppSpacing.md,
          ),
        ));
      }
      items.add(Text(
        trace.weatherCondition!.toUpperCase(),
        style: AppTypography.mono(opacity: AppOpacity.textTertiary),
      ));
    }

    return items;
  }
}
