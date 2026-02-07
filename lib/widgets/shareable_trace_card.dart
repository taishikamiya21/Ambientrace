import 'package:flutter/material.dart';
import '../models/trace_log.dart';

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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: _buildBackgroundGradient(),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MEANING: Primary tag as hero title
          if (trace.imageLabels.isNotEmpty) ...[
            Text(
              trace.imageLabels.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
                height: 1.3,
              ),
            ),
            if (trace.imageLabels.length > 1) ...[
              const SizedBox(height: 14),
              // Remaining tags as pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trace.imageLabels.skip(1).take(4).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final accentColor = trace.colorPalette.isNotEmpty
                      ? Color(trace.colorPalette[(index + 1) % trace.colorPalette.length])
                          .withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.15);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // 3. CONTEXT: Atmospheric time + exact time + location/weather
          Row(
            children: [
              Text(
                trace.atmosphericTime,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${trace.formattedTime}  ${trace.formattedDate}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (trace.placeName != null ||
              trace.temperature != null ||
              trace.weatherCondition != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
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
          const SizedBox(height: 20),

          // Story (if available)
          if (story != null && story!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                story!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Ambientrace',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                ),
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
        colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0F)],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.6),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
