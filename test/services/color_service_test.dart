import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ambientrace/services/color_service.dart';

ImageProvider _solidImage(int r, int g, int b) {
  final image = img.Image(width: 64, height: 64);
  for (final p in image) {
    p.setRgb(r, g, b);
  }
  final bytes = Uint8List.fromList(img.encodePng(image));
  return MemoryImage(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('extracts vibrant red as dominant from saturated image', () async {
    final svc = ColorService();
    final colors = await svc.extractColors(_solidImage(220, 30, 30));
    expect(colors, isNotEmpty);
    final first = colors.first;
    final r = (first >> 16) & 0xFF;
    final g = (first >> 8) & 0xFF;
    final b = first & 0xFF;
    expect(r, greaterThan(g + 50));
    expect(r, greaterThan(b + 50));
  });
}
