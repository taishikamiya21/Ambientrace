import 'package:palette_generator/palette_generator.dart';
import 'package:flutter/painting.dart';

class ColorService {
  /// Extract dominant colors from an image
  Future<List<int>> extractColors(ImageProvider imageProvider,
      {int maxColors = 5}) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: maxColors,
      );

      final colors = <int>[];

      // Add dominant color first
      if (paletteGenerator.dominantColor != null) {
        colors.add(paletteGenerator.dominantColor!.color.toARGB32());
      }

      // Add other palette colors
      for (final paletteColor in paletteGenerator.paletteColors) {
        if (colors.length >= maxColors) break;
        final colorValue = paletteColor.color.toARGB32();
        if (!colors.contains(colorValue)) {
          colors.add(colorValue);
        }
      }

      return colors;
    } catch (e) {
      print('Error extracting colors: $e');
      return [];
    }
  }
}
