import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ambientrace/services/color_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Synthetic LAB fixtures for `ColorService.extractColors`.
///
/// Specs were authored with Codex to encode the failure modes the v1.2 algorithm
/// rewrite must defeat (low-light scenes whose chroma sits below the legacy
/// 0.20–0.45 saturation gates). Each fixture is a two-tone image with exact
/// pixel proportions so palette behavior is deterministic.

class _Lch {
  const _Lch(this.lightness, this.chroma, this.hue);
  final double lightness;
  final double chroma;
  final double hue;
}

_Lch _argbToLch(int argb) {
  final r = ((argb >> 16) & 0xFF) / 255.0;
  final g = ((argb >> 8) & 0xFF) / 255.0;
  final b = (argb & 0xFF) / 255.0;

  double linearize(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  final rl = linearize(r);
  final gl = linearize(g);
  final bl = linearize(b);

  final x = (rl * 0.4124564 + gl * 0.3575761 + bl * 0.1804375) / 0.95047;
  final y = rl * 0.2126729 + gl * 0.7151522 + bl * 0.0721750;
  final z = (rl * 0.0193339 + gl * 0.1191920 + bl * 0.9503041) / 1.08883;

  double pivot(double v) => v > 0.008856
      ? math.pow(v, 1 / 3).toDouble()
      : (7.787 * v) + (16 / 116);

  final fx = pivot(x);
  final fy = pivot(y);
  final fz = pivot(z);

  final l = 116 * fy - 16;
  final a = 500 * (fx - fy);
  final b2 = 200 * (fy - fz);
  final chroma = math.sqrt(a * a + b2 * b2);
  var hue = math.atan2(b2, a) * 180 / math.pi;
  if (hue < 0) hue += 360;
  return _Lch(l, chroma, hue);
}

List<int> _labToRgb(double l, double a, double b) {
  final fy = (l + 16) / 116;
  final fx = a / 500 + fy;
  final fz = fy - b / 200;

  double unpivot(double v) {
    final cubed = v * v * v;
    return cubed > 0.008856 ? cubed : (v - 16 / 116) / 7.787;
  }

  final x = 0.95047 * unpivot(fx);
  final y = unpivot(fy);
  final z = 1.08883 * unpivot(fz);

  final rl = x * 3.2404542 + y * -1.5371385 + z * -0.4985314;
  final gl = x * -0.9692660 + y * 1.8760108 + z * 0.0415560;
  final bl = x * 0.0556434 + y * -0.2040259 + z * 1.0572252;

  int encode(double channel) {
    final c = channel.clamp(0.0, 1.0);
    final srgb = c <= 0.0031308
        ? 12.92 * c
        : 1.055 * math.pow(c, 1 / 2.4).toDouble() - 0.055;
    return (srgb * 255).round().clamp(0, 255);
  }

  return [encode(rl), encode(gl), encode(bl)];
}

bool _isInHueRange(int argb, double minH, double maxH) {
  final hue = _argbToLch(argb).hue;
  return minH <= maxH
      ? hue >= minH && hue <= maxH
      : hue >= minH || hue <= maxH;
}

double _maxChroma(List<int> palette) {
  if (palette.isEmpty) return 0;
  return palette.map((c) => _argbToLch(c).chroma).reduce(math.max);
}

class _LabSpec {
  const _LabSpec(this.l, this.a, this.b);
  final double l;
  final double a;
  final double b;
}

ImageProvider _twoToneImage({
  required _LabSpec background,
  required double backgroundFraction,
  _LabSpec? accent,
  int size = 64,
}) {
  final image = img.Image(width: size, height: size);
  final total = size * size;
  final bgCount = accent == null ? total : (total * backgroundFraction).round();
  final bgRgb = _labToRgb(background.l, background.a, background.b);
  final accentRgb =
      accent == null ? null : _labToRgb(accent.l, accent.a, accent.b);

  var index = 0;
  for (final pixel in image) {
    final use =
        index < bgCount || accentRgb == null ? bgRgb : accentRgb;
    pixel.setRgb(use[0], use[1], use[2]);
    index++;
  }
  return MemoryImage(Uint8List.fromList(img.encodePng(image)));
}

ImageProvider _multiToneImage(
  List<({_LabSpec lab, double fraction})> tones, {
  int size = 64,
}) {
  final image = img.Image(width: size, height: size);
  final total = size * size;
  final cuts = <int>[];
  var running = 0.0;
  for (var i = 0; i < tones.length - 1; i++) {
    running += tones[i].fraction;
    cuts.add((total * running).round());
  }
  cuts.add(total);
  final rgbs = tones
      .map((t) => _labToRgb(t.lab.l, t.lab.a, t.lab.b))
      .toList();

  var index = 0;
  for (final pixel in image) {
    var bin = 0;
    while (index >= cuts[bin]) {
      bin++;
    }
    final rgb = rgbs[bin];
    pixel.setRgb(rgb[0], rgb[1], rgb[2]);
    index++;
  }
  return MemoryImage(Uint8List.fromList(img.encodePng(image)));
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dark_misty_violet preserves the violet hue', () async {
    final image = _twoToneImage(
      background: const _LabSpec(26, 5, -7),
      backgroundFraction: 0.88,
      accent: const _LabSpec(22, 5, -7),
    );
    final palette = await ColorService().extractColors(image);

    expect(palette, isNotEmpty, reason: 'palette must never be empty');
    expect(palette.length, 5, reason: 'must always return 5 colors');
    expect(_maxChroma(palette), greaterThan(8),
        reason: 'should preserve some violet chroma, not collapse to gray');
    expect(palette.any((c) => _isInHueRange(c, 260, 320)), isTrue,
        reason: 'at least one color should fall in the violet hue band');
  });

  test('near_monochrome_faint_violet rescues the tiny accent', () async {
    final image = _twoToneImage(
      background: const _LabSpec(40, 0, -2),
      backgroundFraction: 0.96,
      accent: const _LabSpec(50, 5, -7),
    );
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(8),
        reason: 'must surface the 4% violet reflection');
    expect(palette.any((c) => _isInHueRange(c, 260, 320)), isTrue,
        reason: 'violet accent must appear in the palette');
  });

  test('very_dark_neutral_fallback returns a usable palette from near-black',
      () async {
    final image = _twoToneImage(
      background: const _LabSpec(5, 0, 0),
      backgroundFraction: 1.0,
    );
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5,
        reason: 'fallback must always yield a complete palette');
    expect(palette.every((c) => _argbToLch(c).lightness <= 12), isTrue,
        reason: 'palette should reflect the near-black luminance');
    expect(_maxChroma(palette), lessThan(4),
        reason: 'no synthetic chroma should be invented from a true gray');
  });

  test('muted_autumn_overcast keeps the warm earth accent', () async {
    final image = _twoToneImage(
      background: const _LabSpec(42, 3, -8),
      backgroundFraction: 0.70,
      accent: const _LabSpec(50, 10, 10),
    );
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(8),
        reason: 'muted earth accent should not be filtered out');
    expect(palette.any((c) => _isInHueRange(c, 30, 90)), isTrue,
        reason: 'warm earth tone must survive into the palette');
  });

  test('bright_pavement_flowers extracts saturated minorities', () async {
    final image = _multiToneImage([
      (lab: const _LabSpec(85, 1, 3), fraction: 0.85),
      (lab: const _LabSpec(70, 45, -5), fraction: 0.08),
      (lab: const _LabSpec(50, 30, -50), fraction: 0.07),
    ]);
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(20),
        reason: 'pink/purple flowers must beat the white pavement');
  });

  /// Locks in the v1.2 white-out fix: faded pastel chromatic accents on
  /// bright pavement no longer collapse into the dominant near-gray cluster.
  /// Pre-fix, CIE76 ΔE 12 deduped chroma-6 pink against chroma-3 pavement
  /// and the entire palette became 5 pavement variants.
  test('faded pastel flowers survive dedup against bright pavement',
      () async {
    final image = _multiToneImage([
      (lab: const _LabSpec(85, 1, 3), fraction: 0.90),
      (lab: const _LabSpec(82, 6, -2), fraction: 0.06),
      (lab: const _LabSpec(78, 5, -4), fraction: 0.04),
    ]);
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(4),
        reason: 'pastel chromatic accents must survive dedup against gray');
  });

  /// Large source with a small chromatic patch — checks that 12x nearest-
  /// neighbour downscale to 160px still surfaces minority colors.
  test('large image with small flower patch survives downscaling', () async {
    const totalEdge = 2000;
    const patchEdge = 140;
    final base = img.Image(width: totalEdge, height: totalEdge);
    final paveRgb = _labToRgb(85, 1, 3);
    final pinkRgb = _labToRgb(70, 45, -5);
    final purpleRgb = _labToRgb(50, 30, -50);
    for (final p in base) {
      p.setRgb(paveRgb[0], paveRgb[1], paveRgb[2]);
    }
    for (var y = totalEdge - patchEdge; y < totalEdge; y++) {
      for (var x = 200; x < 200 + patchEdge; x++) {
        base.getPixel(x, y).setRgb(pinkRgb[0], pinkRgb[1], pinkRgb[2]);
      }
      for (var x = 200 + patchEdge; x < 200 + 2 * patchEdge; x++) {
        base.getPixel(x, y).setRgb(purpleRgb[0], purpleRgb[1], purpleRgb[2]);
      }
    }
    final image = MemoryImage(Uint8List.fromList(img.encodePng(base)));
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(20),
        reason: 'small flower patch must survive downscaling');
  });

  /// Pixel-format defence test: uint16-format source images must not be
  /// read as overflowed channel values (the v1.2 white-out root cause on
  /// iPhone Display P3 / 16-bit PNG photos). The fix uses `rNormalized * 255`
  /// so any pixel format normalizes back into the 0–255 range.
  test('uint16 source pink survives non-uint8 pixel format', () async {
    final image16 =
        img.Image(width: 64, height: 64, format: img.Format.uint16);
    for (final pixel in image16) {
      pixel.setRgb(61680, 25700, 46260);
    }
    final bytes = Uint8List.fromList(img.encodePng(image16));
    final palette = await ColorService().extractColors(MemoryImage(bytes));

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(20),
        reason: 'uint16 pink must not collapse to white via overflow');
  });

  /// Approximates the user's actual azalea bush street photo: vivid pink in
  /// multiple tones over green leaves, asphalt, sky, and tree bark. Acts as
  /// a regression sentinel for realistic outdoor compositions.
  test('realistic azalea streetscape extracts vivid pink', () async {
    final image = _multiToneImage([
      (lab: const _LabSpec(70, 35, 0), fraction: 0.18),
      (lab: const _LabSpec(75, 25, -3), fraction: 0.15),
      (lab: const _LabSpec(60, 50, -5), fraction: 0.12),
      (lab: const _LabSpec(55, 55, -10), fraction: 0.05),
      (lab: const _LabSpec(45, -20, 25), fraction: 0.20),
      (lab: const _LabSpec(50, 0, 0), fraction: 0.15),
      (lab: const _LabSpec(85, 0, 0), fraction: 0.10),
      (lab: const _LabSpec(20, 5, 8), fraction: 0.05),
    ]);
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(25),
        reason: 'azalea flowers must dominate the palette');
    expect(palette.any((c) => _isInHueRange(c, 320, 30)), isTrue,
        reason: 'pink/magenta hue must appear in the palette');
  });

  test('vivid_market_flowers control case extracts the saturated accents',
      () async {
    final image = _twoToneImage(
      background: const _LabSpec(62, 44, 52),
      backgroundFraction: 0.75,
      accent: const _LabSpec(72, 58, -30),
    );
    final palette = await ColorService().extractColors(image);

    expect(palette.length, 5);
    expect(_maxChroma(palette), greaterThan(28),
        reason: 'vivid hues should remain vivid post-extraction');
    expect(palette.any((c) => _isInHueRange(c, 30, 90)), isTrue,
        reason: 'orange-red dominant must appear in the palette');
  });
}
