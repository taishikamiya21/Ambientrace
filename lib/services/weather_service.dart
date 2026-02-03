import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using Open-Meteo API (free, no API key required)
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Get current weather for a location
  Future<WeatherData?> getCurrentWeather(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,weather_code'
        '&timezone=auto',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        
        if (current != null) {
          return WeatherData(
            temperature: (current['temperature_2m'] as num).toDouble(),
            weatherCode: current['weather_code'] as int,
          );
        }
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }
}

class WeatherData {
  final double temperature;
  final int weatherCode;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
  });

  /// Get weather condition string from WMO weather code
  String get condition {
    // WMO Weather interpretation codes
    // https://open-meteo.com/en/docs
    switch (weatherCode) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow Grains';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 85:
      case 86:
        return 'Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Unknown';
    }
  }
}
