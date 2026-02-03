import 'package:flutter/material.dart';

/// A single "trace" - the ambient data captured at a moment
class TraceLog {
  final String id;
  final DateTime capturedAt;
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
  });

  /// Get colors as Color objects
  List<Color> get colors => colorPalette.map((c) => Color(c)).toList();

  /// Format the captured time
  String get formattedTime {
    final hour = capturedAt.hour.toString().padLeft(2, '0');
    final minute = capturedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format the captured date
  String get formattedDate {
    return '${capturedAt.year}/${capturedAt.month.toString().padLeft(2, '0')}/${capturedAt.day.toString().padLeft(2, '0')}';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'capturedAt': capturedAt.toIso8601String(),
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
