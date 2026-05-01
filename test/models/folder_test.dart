import 'package:flutter_test/flutter_test.dart';
import 'package:ambientrace/models/folder.dart';

void main() {
  group('Folder', () {
    test('toJson/fromJson round trip', () {
      final f = Folder(
        id: 'f1',
        name: 'Spring',
        createdAt: DateTime(2026, 5, 1),
        traceIds: const ['a', 'b'],
      );
      final round = Folder.fromJson(f.toJson());
      expect(round.id, 'f1');
      expect(round.name, 'Spring');
      expect(round.traceIds, ['a', 'b']);
    });

    test('addTrace dedupes', () {
      final f = Folder(
        id: 'f1',
        name: 'x',
        createdAt: DateTime.now(),
        traceIds: const ['a'],
      );
      final f2 = f.withAdded('a');
      expect(f2.traceIds, ['a']);
    });

    test('removeTrace removes id', () {
      final f = Folder(
        id: 'f1',
        name: 'x',
        createdAt: DateTime.now(),
        traceIds: const ['a', 'b'],
      );
      final f2 = f.withRemoved('a');
      expect(f2.traceIds, ['b']);
    });
  });
}
