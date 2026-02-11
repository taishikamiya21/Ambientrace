import 'package:flutter/material.dart';
import '../models/trace_log.dart';
import '../theme/app_theme.dart';

class TraceCard extends StatelessWidget {
  final TraceLog trace;

  const TraceCard({super.key, required this.trace});

  @override
  Widget build(BuildContext context) {
    final paletteColors = trace.colorPalette.map((c) => Color(c)).toList();

    return Container(
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
                  children: trace.imageLabels.skip(1).take(3).map((label) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: Colors.white
                              .withValues(alpha: AppOpacity.borderDefault),
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
            ] else
              Text(
                'No ambient traces captured',
                style: AppTypography.body(opacity: AppOpacity.textGhost)
                    .copyWith(fontStyle: FontStyle.italic),
              ),

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
                  style: AppTypography.mono(opacity: AppOpacity.textTertiary),
                ),
                const Spacer(),
                // Metadata inline
                ..._buildMetaItems(),
              ],
            ),
          ],
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
