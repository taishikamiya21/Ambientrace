import 'package:flutter/material.dart';
import '../models/trace_log.dart';

class TraceCard extends StatelessWidget {
  final TraceLog trace;

  const TraceCard({super.key, required this.trace});

  @override
  Widget build(BuildContext context) {
    final paletteColors = trace.colorPalette.map((c) => Color(c)).toList();

    // Subtle card background gradient from first two palette colors
    final bgColor1 = paletteColors.isNotEmpty
        ? _desaturateAndDarken(paletteColors[0])
        : Colors.white.withValues(alpha: 0.03);
    final bgColor2 = paletteColors.length > 1
        ? _desaturateAndDarken(paletteColors[1])
        : Colors.white.withValues(alpha: 0.02);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor1, bgColor2],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: color gradient bar + exact time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color palette gradient bar
                Expanded(
                  child: _buildColorBar(paletteColors),
                ),
                const SizedBox(width: 12),
                // Exact time - small, secondary
                Text(
                  trace.formattedTime,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Atmospheric Time - the hero text
            Text(
              trace.atmosphericTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 14),

            // Ambient labels - pill chips
            if (trace.imageLabels.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trace.imageLabels.take(3).map((label) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                'No ambient traces captured',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 14),

            // Bottom metadata row: location + weather + temp
            _buildMetadataRow(),
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
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(4),
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
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Bottom row with location, weather, temperature
  Widget _buildMetadataRow() {
    final items = <Widget>[];

    if (trace.placeName != null) {
      items.add(_buildMetaItem(Icons.location_on_outlined, trace.placeName!));
    }
    if (trace.weatherCondition != null) {
      items.add(_buildMetaItem(Icons.cloud_outlined, trace.weatherCondition!));
    }
    if (trace.temperature != null) {
      items.add(
          _buildMetaItem(Icons.thermostat_outlined, '${trace.temperature!.round()}°'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: items,
    );
  }

  Widget _buildMetaItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Takes a color and returns a very dark, low-saturation version for card background
  Color _desaturateAndDarken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation * 0.3).clamp(0.0, 1.0))
        .withLightness(0.08)
        .toColor()
        .withValues(alpha: 0.6);
  }
}
