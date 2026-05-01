import 'package:flutter/material.dart';

/// A single "trace" - the ambient data captured at a moment
class TraceLog {
  final String id;

  /// When the photo was originally taken (from EXIF or live capture).
  /// Nullable since v1.2.1: imports of photos without EXIF date no longer
  /// fall back to "now" — the field stays absent so the UI can hide the
  /// timestamp instead of showing a misleading current time.
  final DateTime? capturedAt;

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
  final String? originalFileName;
  final String? aiProviderUsed;

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
    this.originalFileName,
    this.aiProviderUsed,
  }) : createdAt = createdAt ?? capturedAt ?? DateTime.now();

  /// Get colors as Color objects
  List<Color> get colors => colorPalette.map((c) => Color(c)).toList();

  /// True if a real capture timestamp is known (from EXIF or live shot).
  bool get hasCapturedAt => capturedAt != null;

  /// Formatted captured time, or null when [capturedAt] is unknown.
  String? get formattedTime {
    final at = capturedAt;
    if (at == null) return null;
    final hour = at.hour.toString().padLeft(2, '0');
    final minute = at.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Atmospheric (fuzzy) time label in English, or null when [capturedAt]
  /// is unknown.
  String? get atmosphericTime {
    final at = capturedAt;
    if (at == null) return null;
    final hour = at.hour;
    if (hour >= 0 && hour < 4) return 'Late Night';
    if (hour >= 4 && hour < 6) return 'Dawn';
    if (hour >= 6 && hour < 10) return 'Morning';
    if (hour >= 10 && hour < 14) return 'Midday';
    if (hour >= 14 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 19) return 'Dusk';
    if (hour >= 19 && hour < 22) return 'Evening';
    return 'Late Night';
  }

  /// Atmospheric (fuzzy) time label in Japanese, or null when [capturedAt]
  /// is unknown.
  String? get atmosphericTimeJa {
    final at = capturedAt;
    if (at == null) return null;
    final hour = at.hour;
    if (hour >= 0 && hour < 4) return '深夜';
    if (hour >= 4 && hour < 6) return '早朝';
    if (hour >= 6 && hour < 10) return '朝';
    if (hour >= 10 && hour < 14) return '昼';
    if (hour >= 14 && hour < 17) return '午後';
    if (hour >= 17 && hour < 19) return '夕暮れ';
    if (hour >= 19 && hour < 22) return '夜';
    return '深夜';
  }

  /// Atmospheric time for the given language, or null when [capturedAt]
  /// is unknown.
  String? atmosphericTimeForLanguage(String languageCode) {
    return languageCode.startsWith('ja') ? atmosphericTimeJa : atmosphericTime;
  }

  /// Formatted captured date, or null when [capturedAt] is unknown.
  String? get formattedDate {
    final at = capturedAt;
    if (at == null) return null;
    return '${at.year}/${at.month.toString().padLeft(2, '0')}/${at.day.toString().padLeft(2, '0')}';
  }

  TraceLog copyWith({
    String? id,
    DateTime? capturedAt,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    String? placeName,
    double? temperature,
    String? weatherCondition,
    double? noiseLevel,
    int? stepCount,
    List<String>? imageLabels,
    List<int>? colorPalette,
    String? aiDescription,
    String? originalFileName,
    String? aiProviderUsed,
  }) {
    return TraceLog(
      id: id ?? this.id,
      capturedAt: capturedAt ?? this.capturedAt,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      temperature: temperature ?? this.temperature,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      stepCount: stepCount ?? this.stepCount,
      imageLabels: imageLabels ?? this.imageLabels,
      colorPalette: colorPalette ?? this.colorPalette,
      aiDescription: aiDescription ?? this.aiDescription,
      originalFileName: originalFileName ?? this.originalFileName,
      aiProviderUsed: aiProviderUsed ?? this.aiProviderUsed,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'capturedAt': capturedAt?.toIso8601String(),
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
    'originalFileName': originalFileName,
    'aiProviderUsed': aiProviderUsed,
  };

  /// Create from JSON
  factory TraceLog.fromJson(Map<String, dynamic> json) => TraceLog(
    id: json['id'] as String,
    capturedAt: json['capturedAt'] != null
        ? DateTime.parse(json['capturedAt'] as String)
        : null,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    placeName: json['placeName'] as String?,
    temperature: (json['temperature'] as num?)?.toDouble(),
    weatherCondition: json['weatherCondition'] as String?,
    noiseLevel: (json['noiseLevel'] as num?)?.toDouble(),
    stepCount: json['stepCount'] as int?,
    imageLabels: List<String>.from(json['imageLabels'] ?? []),
    colorPalette: List<int>.from(json['colorPalette'] ?? []),
    aiDescription: json['aiDescription'] as String?,
    originalFileName: json['originalFileName'] as String?,
    aiProviderUsed: json['aiProviderUsed'] as String?,
  );
}
