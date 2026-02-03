import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check and request location permissions
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get place name from coordinates
  Future<String?> getPlaceName(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      return null;
    }

    // Geocoding is not fully supported on macOS
    if (Platform.isMacOS) {
      print('Geocoding: Skipping on macOS (not fully supported)');
      return null;
    }

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];

        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          parts.add(place.subLocality!);
        }
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          parts.add(place.thoroughfare!);
        }

        return parts.isNotEmpty ? parts.join(', ') : null;
      }
    } catch (e) {
      print('Error getting place name: $e');
    }
    return null;
  }
}
