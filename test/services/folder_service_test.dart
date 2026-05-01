import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ambientrace/services/folder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FolderService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('createFolder persists and assigns id', () async {
      final svc = FolderService();
      await svc.init();
      final f = await svc.createFolder('Trip');
      expect(f.id, isNotEmpty);
      expect(f.name, 'Trip');

      final svc2 = FolderService();
      await svc2.init();
      final all = await svc2.listFolders();
      expect(all.length, 1);
      expect(all.first.name, 'Trip');
    });

    test('addTraceToFolder updates reverse index', () async {
      final svc = FolderService();
      await svc.init();
      final f = await svc.createFolder('A');
      await svc.addTraceToFolder('t1', f.id);
      expect(svc.foldersOf('t1'), {f.id});
    });

    test('deleteFolder removes from reverse index', () async {
      final svc = FolderService();
      await svc.init();
      final f = await svc.createFolder('A');
      await svc.addTraceToFolder('t1', f.id);
      await svc.deleteFolder(f.id);
      expect(svc.foldersOf('t1'), <String>{});
      expect(await svc.listFolders(), isEmpty);
    });

    test('removeTraceFromAllFolders detaches from every folder', () async {
      final svc = FolderService();
      await svc.init();
      final a = await svc.createFolder('A');
      final b = await svc.createFolder('B');
      await svc.addTraceToFolder('t1', a.id);
      await svc.addTraceToFolder('t1', b.id);
      await svc.removeTraceFromAllFolders('t1');
      expect(svc.foldersOf('t1'), <String>{});
    });
  });
}
