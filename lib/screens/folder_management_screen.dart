import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../services/folder_service.dart';

class FolderManagementScreen extends StatefulWidget {
  final FolderService folderService;
  const FolderManagementScreen({super.key, required this.folderService});

  @override
  State<FolderManagementScreen> createState() => _FolderManagementScreenState();
}

class _FolderManagementScreenState extends State<FolderManagementScreen> {
  List<Folder> _folders = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final f = await widget.folderService.listFolders();
    if (!mounted) return;
    setState(() => _folders = f);
  }

  Future<void> _create() async {
    final name = await _promptName(initial: '');
    if (name == null || name.trim().isEmpty) return;
    await widget.folderService.createFolder(name.trim());
    await _load();
  }

  Future<void> _rename(Folder f) async {
    final name = await _promptName(initial: f.name);
    if (name == null || name.trim().isEmpty) return;
    await widget.folderService.renameFolder(f.id, name.trim());
    await _load();
  }

  Future<void> _delete(Folder f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete "${f.name}"?'),
        content: const Text('Traces inside this folder will not be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (!mounted) return;
    if (ok != true) return;
    await widget.folderService.deleteFolder(f.id);
    await _load();
  }

  Future<String?> _promptName({required String initial}) async {
    final controller = TextEditingController(text: initial);
    try {
      return await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(initial.isEmpty ? 'New folder' : 'Rename folder'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: ListView.separated(
        itemCount: _folders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final f = _folders[i];
          return ListTile(
            title: Text(f.name),
            subtitle: Text('${f.traceIds.length} traces'),
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'rename') _rename(f);
                if (v == 'delete') _delete(f);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
    );
  }
}
