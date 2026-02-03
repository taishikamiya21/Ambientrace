import 'package:flutter/material.dart';
import '../models/trace_log.dart';

class TraceCard extends StatelessWidget {
  final TraceLog trace;

  const TraceCard({super.key, required this.trace});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trace.formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  trace.formattedDate,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Color palette
            if (trace.colorPalette.isNotEmpty) ...[
              Row(
                children: trace.colorPalette.take(5).map((colorValue) {
                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Location
            if (trace.placeName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trace.placeName!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Ambient traces (labels)
            if (trace.imageLabels.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: trace.imageLabels.take(4).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  // Use color from palette if available
                  final accentColor = trace.colorPalette.isNotEmpty
                      ? Color(trace.colorPalette[index % trace.colorPalette.length])
                          .withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              // No labels available
              Text(
                'No ambient traces captured',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Sensor data row
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (trace.temperature != null)
                  _buildDataChip(
                    Icons.thermostat_outlined,
                    '${trace.temperature!.round()}°',
                  ),
                if (trace.noiseLevel != null)
                  _buildDataChip(
                    Icons.volume_up_outlined,
                    '${trace.noiseLevel!.round()}dB',
                  ),
                if (trace.weatherCondition != null)
                  _buildDataChip(
                    Icons.cloud_outlined,
                    trace.weatherCondition!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataChip(IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
