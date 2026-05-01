import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ambientrace/services/color_service.dart';

void main() {
  test('palette extraction snapshots (skipped if no sample images)', () async {
    final dir = Directory('assets/test_images/palette');
    if (!dir.existsSync()) {
      markTestSkipped('No sample images placed yet');
      return;
    }
    final svc = ColorService();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
        .toList();
    if (files.isEmpty) {
      markTestSkipped('Place sample images in assets/test_images/palette/');
      return;
    }
    for (final f in files) {
      final colors = await svc.extractColors(FileImage(f));
      expect(colors, isNotEmpty, reason: 'no colors for ${f.path}');
      // ignore: avoid_print
      print(
        '${f.uri.pathSegments.last}: ${colors.map((c) => c.toRadixString(16)).join(',')}',
      );
    }
  });
}
