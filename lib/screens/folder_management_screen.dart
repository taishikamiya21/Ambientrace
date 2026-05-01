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
    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isJa ? '「${f.name}」を削除しますか？' : 'Delete "${f.name}"?'),
        content: Text(
          isJa
              ? 'フォルダ内のトレースは削除されません。'
              : 'Traces inside this folder will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isJa ? 'キャンセル' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isJa ? '削除' : 'Delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok != true) return;
    await widget.folderService.deleteFolder(f.id);
    await _load();
  }

  Future<String?> _promptName({required String initial}) {
    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    return showDialog<String>(
      context: context,
      builder: (_) => _FolderNameDialog(initial: initial, isJa: isJa),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    return Scaffold(
      appBar: AppBar(title: Text(isJa ? 'フォルダ' : 'Folders')),
      body: ListView.separated(
        itemCount: _folders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final f = _folders[i];
          return ListTile(
            title: Text(f.name),
            subtitle: Text(
              isJa
                  ? '${f.traceIds.length}件のトレース'
                  : '${f.traceIds.length} traces',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'rename') _rename(f);
                if (v == 'delete') _delete(f);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Text(isJa ? '名前を変更' : 'Rename'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(isJa ? '削除' : 'Delete'),
                ),
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

class _FolderNameDialog extends StatefulWidget {
  final String initial;
  final bool isJa;

  const _FolderNameDialog({required this.initial, required this.isJa});

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isJa = widget.isJa;
    return AlertDialog(
      title: Text(
        widget.initial.isEmpty
            ? (isJa ? '新規フォルダ' : 'New folder')
            : (isJa ? 'フォルダ名を変更' : 'Rename folder'),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.pop(context, value),
        decoration: InputDecoration(
          hintText: isJa ? 'フォルダ名' : 'Folder name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isJa ? 'キャンセル' : 'Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
