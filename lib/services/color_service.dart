import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;

/// Extracts a 5-color palette from an image using LAB k-means++ clustering with
/// adaptive scoring. Always returns exactly `_maxColors` entries even for near-
/// monochrome inputs; the highest-scoring "feeling" cluster is index 0 so the
/// trace detail Hero gradient anchors on the most representative color.
class ColorService {
  /// Flip to `true` (in code or via `ColorService.debugLogging = true` from
  /// a debug entry point) to dump per-call pipeline diagnostics — decoded
  /// format / numChannels, raw first-pixel sample, image stats, top cluster
  /// scores, final palette. Kept off by default to keep the Flutter log
  /// quiet, but the infra is left in place because the v1.2 white-out
  /// regression hinged on a non-uint8 pixel format that was only obvious
  /// once the raw sample was logged.
  static bool debugLogging = false;

  static const int _maxColors = 5;
  static const int _kClusters = 10;
  static const int _iterationCap = 20;
  static const double _convergenceThreshold = 0.25;
  static const int _maxLongEdge = 160;
  static const double _dedupDeltaE = 12.0;
  static const double _areaCap = 0.25;
  static const double _chromaMinDivisor = 12.0;
  /// Cluster pairs straddling this chroma cutoff are never merged. Without
  /// this guard, CIE76 ΔE 12 collapses faded pastel chromatic clusters
  /// (chroma 5–8) into bright near-gray clusters, producing the white-out
  /// regression seen on overexposed outdoor flower photos.
  static const double _grayChromaCutoff = 5.0;
  static const double _nearBlackLuminance = 5.0;
  static const double _paddingLuminanceWindow = 8.0;
  static const double _nearBlackLuminanceCap = 12.0;
  static const List<double> _paddingShifts = [
    0,
    -6,
    6,
    -3,
    3,
    -8,
    8,
    -10,
    10,
  ];

  Future<List<int>> extractColors(ImageProvider provider) async {
    final bytes = await _imageBytes(provider);
    if (bytes == null) {
      _log('imageBytes returned null → neutral fallback');
      return _neutralFallback();
    }
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      _log('img.decodeImage returned null → neutral fallback');
      return _neutralFallback();
    }
    _log('decoded ${decoded.width}x${decoded.height} format=${decoded.format} '
        'bitsPerChannel=${decoded.bitsPerChannel} '
        'numChannels=${decoded.numChannels} hasAlpha=${decoded.hasAlpha}');

    final small = _downscale(decoded, maxLongEdge: _maxLongEdge);
    if (small.width > 0 && small.height > 0) {
      final fp = small.getPixel(0, 0);
      _log('firstPixel raw r=${fp.r} g=${fp.g} b=${fp.b} a=${fp.a} '
          'rType=${fp.r.runtimeType} maxCh=${fp.maxChannelValue} '
          'rNorm=${fp.rNormalized.toStringAsFixed(3)} '
          'gNorm=${fp.gNormalized.toStringAsFixed(3)} '
          'bNorm=${fp.bNormalized.toStringAsFixed(3)}');
    }
    final pixels = <_LabPoint>[];
    final samples = <String>[];
    var sumR = 0, sumG = 0, sumB = 0;
    var idx = 0;
    final total = small.width * small.height;
    final sampleStride = math.max(1, total ~/ 6);
    // Use *Normalized accessors so any pixel format (uint8/uint16/float) maps
    // into [0,255] correctly. The legacy `.r.toInt()` path overflowed for
    // non-uint8 formats and produced LAB values that `_labToArgb` clamped to
    // pure white — the v1.2 white-out symptom on real iPhone photos.
    for (final pixel in small) {
      final r = (pixel.rNormalized * 255).round().clamp(0, 255);
      final g = (pixel.gNormalized * 255).round().clamp(0, 255);
      final b = (pixel.bNormalized * 255).round().clamp(0, 255);
      if (idx % sampleStride == 0 && samples.length < 6) {
        samples.add('rgb($r,$g,$b)');
      }
      sumR += r;
      sumG += g;
      sumB += b;
      pixels.add(_rgbToLab(r, g, b));
      idx++;
    }
    if (pixels.isEmpty) {
      _log('empty pixels → neutral fallback');
      return _neutralFallback();
    }
    final n = pixels.length;
    _log('downscaled ${small.width}x${small.height} pixels=$n '
        'meanRGB=(${sumR ~/ n},${sumG ~/ n},${sumB ~/ n}) '
        'samples=${samples.join(' ')}');

    // Image-level statistics for adaptive scoring. mean L drives luminance
    // contrast; p95 chroma drives relative chroma so we don't compare against
    // an absolute that doesn't exist in low-chroma scenes.
    var sumL = 0.0;
    final chromas = <double>[];
    for (final p in pixels) {
      sumL += p.l;
      chromas.add(math.sqrt(p.a * p.a + p.b * p.b));
    }
    final meanL = sumL / pixels.length;
    chromas.sort();
    final p95Index =
        (chromas.length * 0.95).floor().clamp(0, chromas.length - 1);
    final p95Chroma = chromas[p95Index];

    final k = math.min(_kClusters, pixels.length);
    final centroids = _kmeansPlusPlusInit(pixels, k);
    final assignments = List<int>.filled(pixels.length, 0);

    for (var iter = 0; iter < _iterationCap; iter++) {
      for (var i = 0; i < pixels.length; i++) {
        assignments[i] = _nearestLabCentroid(pixels[i], centroids);
      }

      final counts = List<int>.filled(k, 0);
      final sumLs = List<double>.filled(k, 0);
      final sumAs = List<double>.filled(k, 0);
      final sumBs = List<double>.filled(k, 0);
      for (var i = 0; i < pixels.length; i++) {
        final c = assignments[i];
        counts[c]++;
        sumLs[c] += pixels[i].l;
        sumAs[c] += pixels[i].a;
        sumBs[c] += pixels[i].b;
      }

      var maxShift = 0.0;
      for (var i = 0; i < k; i++) {
        if (counts[i] == 0) continue;
        final newCentroid = _LabPoint(
          sumLs[i] / counts[i],
          sumAs[i] / counts[i],
          sumBs[i] / counts[i],
        );
        final shift = _deltaE(newCentroid, centroids[i]);
        if (shift > maxShift) maxShift = shift;
        centroids[i] = newCentroid;
      }
      if (maxShift < _convergenceThreshold) break;
    }

    final finalCounts = List<int>.filled(k, 0);
    for (var i = 0; i < pixels.length; i++) {
      finalCounts[assignments[i]]++;
    }

    final clusters = <_Cluster>[];
    for (var i = 0; i < k; i++) {
      if (finalCounts[i] == 0) continue;
      final centroid = centroids[i];
      final chroma = math.sqrt(centroid.a * centroid.a + centroid.b * centroid.b);
      final area = finalCounts[i] / pixels.length;
      final areaScore = math.min(area, _areaCap);
      final relChroma = (chroma / math.max(p95Chroma, _chromaMinDivisor))
          .clamp(0.0, 1.0);
      final lumContrast = ((centroid.l - meanL).abs() / 100).clamp(0.0, 1.0);
      final score =
          0.45 * areaScore + 0.35 * relChroma + 0.20 * lumContrast;
      clusters.add(_Cluster(centroid, score));
    }
    if (clusters.isEmpty) {
      _log('no surviving clusters → neutral fallback');
      return _neutralFallback();
    }

    clusters.sort((a, b) => b.score.compareTo(a.score));
    _log('image meanL=${meanL.toStringAsFixed(1)} '
        'p95Chroma=${p95Chroma.toStringAsFixed(1)}');
    for (var i = 0; i < math.min(5, clusters.length); i++) {
      final c = clusters[i].centroid;
      final ch = math.sqrt(c.a * c.a + c.b * c.b);
      _log('cluster[$i] L=${c.l.toStringAsFixed(1)} '
          'a=${c.a.toStringAsFixed(1)} b=${c.b.toStringAsFixed(1)} '
          'C=${ch.toStringAsFixed(1)} score=${clusters[i].score.toStringAsFixed(3)}');
    }

    // CIE76 ΔE dedup, keep higher-scoring cluster. Chroma-aware: clusters
    // on opposite sides of `_grayChromaCutoff` are never merged so a faded
    // pastel accent can't be absorbed by a near-gray pavement cluster.
    final accepted = <_Cluster>[];
    for (final cluster in clusters) {
      var duplicate = false;
      for (final kept in accepted) {
        if (_isDuplicate(cluster.centroid, kept.centroid)) {
          duplicate = true;
          break;
        }
      }
      if (!duplicate) accepted.add(cluster);
    }

    final palette = <int>[];
    for (final cluster in accepted) {
      palette.add(_labToArgb(cluster.centroid));
      if (palette.length >= _maxColors) break;
    }

    final result = palette.length >= _maxColors
        ? palette.take(_maxColors).toList()
        : _padWithLightnessVariants(palette, accepted.first.centroid);
    if (debugLogging) {
      for (var i = 0; i < result.length; i++) {
        final argb = result[i];
        final r = (argb >> 16) & 0xFF;
        final g = (argb >> 8) & 0xFF;
        final b = argb & 0xFF;
        _log('palette[$i] rgb($r,$g,$b)');
      }
    }
    return result;
  }

  static void _log(String message) {
    if (!debugLogging) return;
    debugPrint('[ColorService] $message');
  }

  static List<int> _padWithLightnessVariants(
    List<int> palette,
    _LabPoint source,
  ) {
    final isNearBlack = source.l <= _nearBlackLuminance;
    final lower = math.max(0.0, source.l - _paddingLuminanceWindow);
    final upperRaw = math.min(100.0, source.l + _paddingLuminanceWindow);
    final upper = isNearBlack
        ? math.min(upperRaw, _nearBlackLuminanceCap)
        : upperRaw;

    final padded = List<int>.from(palette);
    for (final shift in _paddingShifts) {
      if (padded.length >= _maxColors) break;
      final candidateL = (source.l + shift).clamp(lower, upper);
      final candidate = _LabPoint(candidateL, source.a, source.b);
      final argb = _labToArgb(candidate);
      if (!padded.contains(argb)) padded.add(argb);
    }
    while (padded.length < _maxColors) {
      padded.add(_labToArgb(source));
    }
    return padded.take(_maxColors).toList();
  }

  /// Last-resort palette when image decoding fails. Returns 5 neutral grays
  /// rather than empty so downstream UI never has to special-case.
  static List<int> _neutralFallback() {
    return [
      _argb(40, 40, 40),
      _argb(60, 60, 60),
      _argb(80, 80, 80),
      _argb(100, 100, 100),
      _argb(120, 120, 120),
    ];
  }

  static List<_LabPoint> _kmeansPlusPlusInit(
    List<_LabPoint> pixels,
    int k,
  ) {
    final random = math.Random(0);
    final centroids = <_LabPoint>[
      pixels[random.nextInt(pixels.length)].copy(),
    ];
    final dists = List<double>.filled(pixels.length, double.infinity);

    while (centroids.length < k) {
      final last = centroids.last;
      var sum = 0.0;
      for (var j = 0; j < pixels.length; j++) {
        final d = _deltaESquared(pixels[j], last);
        if (d < dists[j]) dists[j] = d;
        sum += dists[j];
      }
      if (sum == 0) {
        centroids.add(pixels[random.nextInt(pixels.length)].copy());
        continue;
      }
      final target = random.nextDouble() * sum;
      var acc = 0.0;
      var picked = pixels.length - 1;
      for (var j = 0; j < pixels.length; j++) {
        acc += dists[j];
        if (acc >= target) {
          picked = j;
          break;
        }
      }
      centroids.add(pixels[picked].copy());
    }
    return centroids;
  }

  static int _nearestLabCentroid(
    _LabPoint point,
    List<_LabPoint> centroids,
  ) {
    var nearest = 0;
    var nearestD = double.infinity;
    for (var i = 0; i < centroids.length; i++) {
      final d = _deltaESquared(point, centroids[i]);
      if (d < nearestD) {
        nearest = i;
        nearestD = d;
      }
    }
    return nearest;
  }

  static bool _isDuplicate(_LabPoint a, _LabPoint b) {
    final aChroma = math.sqrt(a.a * a.a + a.b * a.b);
    final bChroma = math.sqrt(b.a * b.a + b.b * b.b);
    final aIsGray = aChroma <= _grayChromaCutoff;
    final bIsGray = bChroma <= _grayChromaCutoff;
    if (aIsGray != bIsGray) return false;
    return _deltaE(a, b) < _dedupDeltaE;
  }

  static double _deltaE(_LabPoint a, _LabPoint b) =>
      math.sqrt(_deltaESquared(a, b));

  static double _deltaESquared(_LabPoint a, _LabPoint b) {
    final dl = a.l - b.l;
    final da = a.a - b.a;
    final db = a.b - b.b;
    return dl * dl + da * da + db * db;
  }

  static img.Image _downscale(img.Image decoded, {required int maxLongEdge}) {
    final long =
        decoded.width > decoded.height ? decoded.width : decoded.height;
    if (long <= maxLongEdge) return decoded;
    final scale = maxLongEdge / long;
    return img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
      interpolation: img.Interpolation.nearest,
    );
  }

  static _LabPoint _rgbToLab(int r, int g, int b) {
    double linearize(int channel) {
      final c = channel / 255.0;
      return c <= 0.04045
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    }

    final rl = linearize(r);
    final gl = linearize(g);
    final bl = linearize(b);

    final x = (rl * 0.4124564 + gl * 0.3575761 + bl * 0.1804375) / 0.95047;
    final y = rl * 0.2126729 + gl * 0.7151522 + bl * 0.0721750;
    final z = (rl * 0.0193339 + gl * 0.1191920 + bl * 0.9503041) / 1.08883;

    double pivot(double value) => value > 0.008856
        ? math.pow(value, 1 / 3).toDouble()
        : (7.787 * value) + (16 / 116);

    final fx = pivot(x);
    final fy = pivot(y);
    final fz = pivot(z);
    return _LabPoint((116 * fy) - 16, 500 * (fx - fy), 200 * (fy - fz));
  }

  static int _labToArgb(_LabPoint lab) {
    final fy = (lab.l + 16) / 116;
    final fx = lab.a / 500 + fy;
    final fz = fy - lab.b / 200;

    double unpivot(double value) {
      final cubed = value * value * value;
      return cubed > 0.008856 ? cubed : (value - 16 / 116) / 7.787;
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

    return _argb(encode(rl), encode(gl), encode(bl));
  }

  static int _argb(int r, int g, int b) =>
      0xFF000000 | (r << 16) | (g << 8) | b;

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

class _LabPoint {
  _LabPoint(this.l, this.a, this.b);

  double l;
  double a;
  double b;

  _LabPoint copy() => _LabPoint(l, a, b);
}

class _Cluster {
  const _Cluster(this.centroid, this.score);

  final _LabPoint centroid;
  final double score;
}
