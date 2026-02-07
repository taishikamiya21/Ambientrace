import 'package:flutter/material.dart';

/// A single "trace" - the ambient data captured at a moment
class TraceLog {
  final String id;
  /// When the photo was originally taken (from EXIF or capture time)
  final DateTime capturedAt;
  /// When this trace card was created in the app
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? placeName;
  final double? temperature;
  final String? weatherCondition;
  final double? noiseLevel;
  final int? stepCount;
  final List<String> imageLabels;
  final List<int> colorPalette;
  final String? aiDescription;

  TraceLog({
    required this.id,
    required this.capturedAt,
    DateTime? createdAt,
    this.latitude,
    this.longitude,
    this.placeName,
    this.temperature,
    this.weatherCondition,
    this.noiseLevel,
    this.stepCount,
    this.imageLabels = const [],
    this.colorPalette = const [],
    this.aiDescription,
  }) : createdAt = createdAt ?? capturedAt;

  /// Get colors as Color objects
  List<Color> get colors => colorPalette.map((c) => Color(c)).toList();

  /// Format the captured time
  String get formattedTime {
    final hour = capturedAt.hour.toString().padLeft(2, '0');
    final minute = capturedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get atmospheric (fuzzy) time label in English
  String get atmosphericTime {
    final hour = capturedAt.hour;
    if (hour >= 0 && hour < 4) return 'Late Night';
    if (hour >= 4 && hour < 6) return 'Dawn';
    if (hour >= 6 && hour < 10) return 'Morning';
    if (hour >= 10 && hour < 14) return 'Midday';
    if (hour >= 14 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 19) return 'Dusk';
    if (hour >= 19 && hour < 22) return 'Evening';
    return 'Late Night';
  }

  /// Get atmospheric (fuzzy) time label in Japanese
  String get atmosphericTimeJa {
    final hour = capturedAt.hour;
    if (hour >= 0 && hour < 4) return '深夜';
    if (hour >= 4 && hour < 6) return '早朝';
    if (hour >= 6 && hour < 10) return '朝';
    if (hour >= 10 && hour < 14) return '昼';
    if (hour >= 14 && hour < 17) return '午後';
    if (hour >= 17 && hour < 19) return '夕暮れ';
    if (hour >= 19 && hour < 22) return '夜';
    return '深夜';
  }

  /// Get atmospheric time for given language code
  String atmosphericTimeForLanguage(String languageCode) {
    return languageCode.startsWith('ja') ? atmosphericTimeJa : atmosphericTime;
  }

  /// Format the captured date
  String get formattedDate {
    return '${capturedAt.year}/${capturedAt.month.toString().padLeft(2, '0')}/${capturedAt.day.toString().padLeft(2, '0')}';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'capturedAt': capturedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'placeName': placeName,
        'temperature': temperature,
        'weatherCondition': weatherCondition,
        'noiseLevel': noiseLevel,
        'stepCount': stepCount,
        'imageLabels': imageLabels,
        'colorPalette': colorPalette,
        'aiDescription': aiDescription,
      };

  /// Create from JSON
  factory TraceLog.fromJson(Map<String, dynamic> json) => TraceLog(
        id: json['id'] as String,
        capturedAt: DateTime.parse(json['capturedAt'] as String),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        placeName: json['placeName'] as String?,
        temperature: json['temperature'] as double?,
        weatherCondition: json['weatherCondition'] as String?,
        noiseLevel: json['noiseLevel'] as double?,
        stepCount: json['stepCount'] as int?,
        imageLabels: List<String>.from(json['imageLabels'] ?? []),
        colorPalette: List<int>.from(json['colorPalette'] ?? []),
        aiDescription: json['aiDescription'] as String?,
      );
}
