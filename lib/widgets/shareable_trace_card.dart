import 'package:flutter/material.dart';
import '../models/trace_log.dart';
import '../theme/app_theme.dart';

class ShareableTraceCard extends StatelessWidget {
  final TraceLog trace;
  final String? story;

  const ShareableTraceCard({
    super.key,
    required this.trace,
    this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: _buildBackgroundGradient(),
        borderRadius: BorderRadius.circular(AppRadius.surface),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MEANING: Primary tag as hero title
          if (trace.imageLabels.isNotEmpty) ...[
            Text(
              trace.imageLabels.first,
              style: AppTypography.headline(),
            ),
            if (trace.imageLabels.length > 1) ...[
              const SizedBox(height: 14),
              // Remaining tags as pills
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: trace.imageLabels.skip(1).take(4).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final accentColor = trace.colorPalette.isNotEmpty
                      ? Color(trace.colorPalette[(index + 1) % trace.colorPalette.length])
                          .withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: AppOpacity.surfaceElevated);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: AppOpacity.borderMedium),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.label(opacity: AppOpacity.textHero),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],

          // 2. FEELING: Color palette
          if (trace.colorPalette.isNotEmpty) ...[
            Row(
              children: trace.colorPalette.map((colorValue) {
                return Expanded(
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      borderRadius: BorderRadius.circular(AppRadius.container),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: AppOpacity.borderMedium),
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // 3. CONTEXT: Atmospheric time + exact time + location/weather
          Row(
            children: [
              Text(
                trace.atmosphericTime,
                style: AppTypography.mono(opacity: AppOpacity.textTertiary),
              ),
              const SizedBox(width: 10),
              Text(
                '${trace.formattedTime}  ${trace.formattedDate}',
                style: AppTypography.mono(opacity: AppOpacity.textMuted),
              ),
            ],
          ),
          if (trace.placeName != null ||
              trace.temperature != null ||
              trace.weatherCondition != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                if (trace.placeName != null)
                  _buildInfoChip(Icons.location_on_outlined, trace.placeName!),
                if (trace.temperature != null)
                  _buildInfoChip(
                      Icons.thermostat_outlined, '${trace.temperature!.round()}°C'),
                if (trace.weatherCondition != null)
                  _buildInfoChip(Icons.cloud_outlined, trace.weatherCondition!),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Story (if available)
          if (story != null && story!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: AppOpacity.surfaceContainer),
                borderRadius: BorderRadius.circular(AppRadius.container),
                border: Border.all(
                  color: Colors.white.withValues(alpha: AppOpacity.borderSubtle),
                ),
              ),
              child: Text(
                story!,
                style: AppTypography.body(opacity: AppOpacity.textHigh)
                    .copyWith(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air,
                color: Colors.white.withValues(alpha: AppOpacity.textCaption),
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'AMBIENTRACE',
                style: AppTypography.section(opacity: AppOpacity.textCaption),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _buildBackgroundGradient() {
    if (trace.colorPalette.isEmpty) {
      return const LinearGradient(
        colors: [AppColors.canvasSecondary, AppColors.canvasPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    // Create a gradient from the first two colors in the palette
    final color1 = Color(trace.colorPalette.first);
    final color2 = trace.colorPalette.length > 1
        ? Color(trace.colorPalette[1])
        : color1;

    // Darken the colors for the background
    final darkColor1 = HSLColor.fromColor(color1)
        .withLightness(0.1)
        .withSaturation(0.3)
        .toColor();
    final darkColor2 = HSLColor.fromColor(color2)
        .withLightness(0.05)
        .withSaturation(0.2)
        .toColor();

    return LinearGradient(
      colors: [darkColor1, darkColor2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildInfoChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppOpacity.surfaceElevated),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: AppOpacity.textSecondary),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTypography.mono(opacity: AppOpacity.textHigh),
          ),
        ],
      ),
    );
  }
}
