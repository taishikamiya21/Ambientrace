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
            // Hero: Primary tag as card title
            if (trace.imageLabels.isNotEmpty) ...[
              Text(
                trace.imageLabels.first,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
              if (trace.imageLabels.length > 1) ...[
                const SizedBox(height: 12),
                // Remaining tags as pills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trace.imageLabels.skip(1).take(3).map((label) {
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
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ] else
              Text(
                'No ambient traces captured',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 16),

            // Color gradient bar + atmospheric time + exact time
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Color palette gradient bar
                SizedBox(
                  width: 40,
                  child: _buildColorBar(paletteColors),
                ),
                const SizedBox(width: 12),
                // Atmospheric Time
                Text(
                  trace.atmosphericTime,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 10),
                // Exact time
                Text(
                  trace.formattedTime,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
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

  /// Inline metadata items for the bottom row
  List<Widget> _buildMetaItems() {
    final items = <Widget>[];

    if (trace.temperature != null) {
      items.add(Text(
        '${trace.temperature!.round()}°',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 11,
        ),
      ));
    }
    if (trace.weatherCondition != null) {
      if (items.isNotEmpty) {
        items.add(SizedBox(
          height: 10,
          child: VerticalDivider(
            color: Colors.white.withValues(alpha: 0.15),
            width: 16,
          ),
        ));
      }
      items.add(Text(
        trace.weatherCondition!,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 11,
        ),
      ));
    }

    return items;
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
