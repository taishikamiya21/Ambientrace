import 'dart:async';
import 'dart:io';
import 'package:noise_meter/noise_meter.dart';

class NoiseService {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _subscription;
  final List<double> _samples = [];

  /// Start measuring noise for a short duration and return the average decibel level
  /// Returns null if microphone is not available or permission denied
  Future<double?> measureNoiseLevel({Duration duration = const Duration(seconds: 2)}) async {
    // Skip on macOS as microphone access is limited in Flutter
    if (Platform.isMacOS) {
      print('NoiseService: Skipping on macOS');
      return null;
    }

    try {
      _noiseMeter ??= NoiseMeter();
      _samples.clear();

      final completer = Completer<double?>();

      _subscription = _noiseMeter!.noise.listen(
        (NoiseReading reading) {
          // Collect samples
          if (reading.meanDecibel.isFinite && reading.meanDecibel > 0) {
            _samples.add(reading.meanDecibel);
            print('NoiseService: Sample ${_samples.length}: ${reading.meanDecibel.toStringAsFixed(1)} dB');
          }
        },
        onError: (error) {
          print('NoiseService: Error - $error');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      // Wait for the duration then calculate average
      await Future.delayed(duration);

      // Stop listening
      await _subscription?.cancel();
      _subscription = null;

      if (_samples.isEmpty) {
        print('NoiseService: No samples collected');
        return null;
      }

      // Calculate average noise level
      final average = _samples.reduce((a, b) => a + b) / _samples.length;
      print('NoiseService: Average noise level: ${average.toStringAsFixed(1)} dB from ${_samples.length} samples');

      if (!completer.isCompleted) {
        completer.complete(average);
      }

      return average;
    } catch (e) {
      print('NoiseService: Error measuring noise - $e');
      await _subscription?.cancel();
      _subscription = null;
      return null;
    }
  }

  /// Stop any ongoing measurement
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
