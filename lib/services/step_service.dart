import 'dart:async';
import 'dart:io';
import 'package:pedometer/pedometer.dart';

class StepService {
  StreamSubscription<StepCount>? _subscription;
  int? _initialStepCount;
  int? _currentStepCount;

  /// Get the current step count since midnight (today's steps)
  /// Returns null if pedometer is not available or permission denied
  Future<int?> getTodayStepCount() async {
    // Skip on macOS as pedometer is not available
    if (Platform.isMacOS) {
      print('StepService: Skipping on macOS');
      return null;
    }

    try {
      final completer = Completer<int?>();

      // Get pedestrian status first to check if available
      final statusStream = Pedometer.pedestrianStatusStream;
      StreamSubscription<PedestrianStatus>? statusSubscription;

      statusSubscription = statusStream.listen(
        (status) {
          print('StepService: Pedestrian status: ${status.status}');
          statusSubscription?.cancel();
        },
        onError: (error) {
          print('StepService: Status error - $error');
          statusSubscription?.cancel();
        },
      );

      // Get step count
      _subscription = Pedometer.stepCountStream.listen(
        (StepCount stepCount) {
          _currentStepCount = stepCount.steps;
          print('StepService: Step count: ${stepCount.steps} at ${stepCount.timeStamp}');

          // Cancel subscription after getting the count
          _subscription?.cancel();
          _subscription = null;

          if (!completer.isCompleted) {
            // Return the step count
            // Note: This is total steps since device boot/last reset
            // For "today's steps", you'd need to track midnight reset
            completer.complete(stepCount.steps);
          }
        },
        onError: (error) {
          print('StepService: Error - $error');
          _subscription?.cancel();
          _subscription = null;
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      // Timeout after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          print('StepService: Timeout');
          _subscription?.cancel();
          _subscription = null;
          completer.complete(null);
        }
      });

      return completer.future;
    } catch (e) {
      print('StepService: Error getting step count - $e');
      return null;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
