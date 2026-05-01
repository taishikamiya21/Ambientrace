import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';

class ColorService {
  static const double _stage2SatThreshold = 0.30;
  static const double _stage2ValThreshold = 0.20;
  static const double _stage1MaxSatGate = 0.25;
  static const int _maxColors = 5;

  Future<List<int>> extractColors(ImageProvider provider) async {
    final stage1 = await _stage1Vibrant(provider);
    final stage1MaxSat = stage1.fold<double>(
      0.0,
      (m, c) => _saturation(c) > m ? _saturation(c) : m,
    );

    List<int> stage2 = const [];
    if (stage1.length < 3 || stage1MaxSat < _stage1MaxSatGate) {
      stage2 = await _stage2HsvFilter(provider);
    }

    final merged = <int>[];
    for (final c in [...stage1, ...stage2]) {
      if (!merged.contains(c)) merged.add(c);
      if (merged.length >= _maxColors) break;
    }

    if (merged.length < _maxColors) {
      final fallback = await _dominantFallback(provider);
      for (final c in fallback) {
        if (!merged.contains(c)) merged.add(c);
        if (merged.length >= _maxColors) break;
      }
    }
    return merged;
  }

  Future<List<int>> _stage1Vibrant(ImageProvider p) async {
    try {
      // Vibrant-only targets bias the palette toward saturated colors.
      final pg = await PaletteGenerator.fromImageProvider(
        p,
        maximumColorCount: 16,
        targets: [
          PaletteTarget.vibrant,
          PaletteTarget.lightVibrant,
          PaletteTarget.darkVibrant,
        ],
      );
      // paletteColors are already filtered to the vibrant targets above.
      // Take top 3 by population.
      final sorted = pg.paletteColors.toList()
        ..sort((a, b) => b.population.compareTo(a.population));
      return sorted.take(3).map((pc) => pc.color.toARGB32()).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<int>> _stage2HsvFilter(ImageProvider provider) async {
    final bytes = await _imageBytes(provider);
    if (bytes == null) return const [];
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return const [];

    final long = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    final scale = long > 256 ? 256 / long : 1.0;
    final small = scale < 1
        ? img.copyResize(
            decoded,
            width: (decoded.width * scale).round(),
            height: (decoded.height * scale).round(),
          )
        : decoded;

    final filtered = <int>[];
    for (final pixel in small) {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final hsv = _rgbToHsv(r, g, b);
      if (hsv[1] > _stage2SatThreshold && hsv[2] > _stage2ValThreshold) {
        filtered.add(_argb(r, g, b));
      }
    }
    if (filtered.isEmpty) return const [];

    return _topByQuantizedBucket(filtered, k: 3);
  }

  Future<List<int>> _dominantFallback(ImageProvider p) async {
    final pg = await PaletteGenerator.fromImageProvider(
      p,
      maximumColorCount: _maxColors,
    );
    final out = <int>[];
    if (pg.dominantColor != null) out.add(pg.dominantColor!.color.toARGB32());
    for (final pc in pg.paletteColors) {
      final v = pc.color.toARGB32();
      if (!out.contains(v)) out.add(v);
      if (out.length >= _maxColors) break;
    }
    return out;
  }

  static List<double> _rgbToHsv(int r, int g, int b) {
    final rf = r / 255.0, gf = g / 255.0, bf = b / 255.0;
    final maxC = [rf, gf, bf].reduce((a, c) => a > c ? a : c);
    final minC = [rf, gf, bf].reduce((a, c) => a < c ? a : c);
    final d = maxC - minC;
    double h = 0;
    if (d > 0) {
      if (maxC == rf) {
        h = 60 * (((gf - bf) / d) % 6);
      } else if (maxC == gf) {
        h = 60 * (((bf - rf) / d) + 2);
      } else {
        h = 60 * (((rf - gf) / d) + 4);
      }
    }
    final s = maxC == 0 ? 0.0 : d / maxC;
    return [h, s, maxC];
  }

  static double _saturation(int argb) {
    final r = (argb >> 16) & 0xFF, g = (argb >> 8) & 0xFF, b = argb & 0xFF;
    return _rgbToHsv(r, g, b)[1];
  }

  static int _argb(int r, int g, int b) =>
      0xFF000000 | (r << 16) | (g << 8) | b;

  // Quantize 5 bits per channel; pick top K buckets by count.
  static List<int> _topByQuantizedBucket(List<int> colors, {required int k}) {
    final counts = <int, int>{};
    final sums = <int, List<int>>{};
    for (final c in colors) {
      final r = (c >> 16) & 0xFF, g = (c >> 8) & 0xFF, b = c & 0xFF;
      final key = ((r >> 3) << 10) | ((g >> 3) << 5) | (b >> 3);
      counts[key] = (counts[key] ?? 0) + 1;
      final s = sums[key] ??= [0, 0, 0];
      s[0] += r;
      s[1] += g;
      s[2] += b;
    }
    final keys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return keys.take(k).map((key) {
      final n = counts[key]!;
      final s = sums[key]!;
      return _argb(s[0] ~/ n, s[1] ~/ n, s[2] ~/ n);
    }).toList();
  }

  Future<Uint8List?> _imageBytes(ImageProvider provider) async {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) => completer.complete(info.image),
      onError: (e, _) => completer.completeError(e),
    );
    stream.addListener(listener);
    try {
      final ui.Image image = await completer.future;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } finally {
      stream.removeListener(listener);
    }
  }
}
