import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ambientrace/models/trace_log.dart';
import 'package:ambientrace/services/export_service.dart';
import 'package:ambientrace/services/import_service.dart';
import 'package:ambientrace/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export -> import round trip preserves traces and folders', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    final trace = TraceLog(
      id: 'a',
      capturedAt: DateTime(2026, 5, 1),
      originalFileName: 'IMG.jpg',
      aiProviderUsed: 'gemini',
      imageLabels: const ['quiet'],
      colorPalette: const [0xFFAABBCC],
    );
    await storage.saveTrace(trace);
    final folder = await storage.folderService.createFolder('Spring');
    await storage.folderService.addTraceToFolder(trace.id, folder.id);

    final raw = ExportService.buildJson(
      traces: storage.getAllTraces(),
      folders: await storage.folderService.listFolders(),
      appVersion: '1.2.0',
    );

    SharedPreferences.setMockInitialValues({});
    final storage2 = StorageService();
    await storage2.init();
    await ImportApply.apply(
      raw: raw,
      storage: storage2,
      mode: ConflictMode.overwrite,
    );

    final restored = storage2.findById('a');
    expect(restored, isNotNull);
    expect(restored!.originalFileName, 'IMG.jpg');
    expect(restored.aiProviderUsed, 'gemini');
    final folders2 = await storage2.folderService.listFolders();
    expect(folders2.any((f) => f.name == 'Spring'), true);
    expect(storage2.folderService.foldersOf('a').isNotEmpty, true);
  });
}
