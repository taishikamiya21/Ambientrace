import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/export_service.dart';
import '../services/import_service.dart';
import '../services/storage_service.dart';

class DataManagementScreen extends StatefulWidget {
  final StorageService storageService;

  const DataManagementScreen({super.key, required this.storageService});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _includeLocation = true;
  bool _busy = false;

  Future<void> _exportJson() async {
    setState(() => _busy = true);
    try {
      final info = await PackageInfo.fromPlatform();
      final folders = await widget.storageService.folderService.listFolders();
      final traces = widget.storageService.getAllTraces();
      final body = ExportService.buildJson(
        traces: traces,
        folders: folders,
        appVersion: info.version,
        includeLocation: _includeLocation,
      );
      final file = await _writeTemp(
        'ambientrace_${DateTime.now().millisecondsSinceEpoch}.json',
        body,
      );
      await Share.shareXFiles([XFile(file.path)]);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final folders = await widget.storageService.folderService.listFolders();
      final traces = widget.storageService.getAllTraces();
      final lang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final body = ExportService.buildCsv(
        traces: traces,
        folders: folders,
        languageCode: lang,
      );
      final file = await _writeTemp(
        'ambientrace_${DateTime.now().millisecondsSinceEpoch}.csv',
        '\uFEFF$body',
      );
      await Share.shareXFiles([XFile(file.path)]);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<File> _writeTemp(String name, String body) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(body, encoding: utf8);
    return file;
  }

  Future<void> _import() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    final raw = await File(path).readAsString();
    final result = ImportService.dryRun(raw);

    if (!mounted) return;
    final mode = await showDialog<ConflictMode>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(
          'Import: ${result.traceCount} traces, ${result.folderCount} folders'
          '${result.problems.isEmpty ? '' : '\nProblems: ${result.problems.length}'}',
        ),
        children: [
          for (final problem in result.problems.take(5))
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('- $problem'),
            ),
          for (final mode in ConflictMode.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, mode),
              child: Text(mode.name),
            ),
        ],
      ),
    );
    if (mode == null) return;

    setState(() => _busy = true);
    try {
      final report = await ImportApply.apply(
        raw: raw,
        storage: widget.storageService,
        mode: mode,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported: ${report.inserted} new, '
            '${report.overwritten} overwritten, ${report.skipped} skipped, '
            '${report.duplicated} duplicated, ${report.merged} merged, '
            '${report.failed} failed',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Management')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Include location in export'),
            value: _includeLocation,
            onChanged: _busy
                ? null
                : (value) => setState(() => _includeLocation = value),
          ),
          ListTile(
            title: const Text('Export JSON'),
            trailing: const Icon(Icons.download),
            onTap: _busy ? null : _exportJson,
          ),
          ListTile(
            title: const Text('Export CSV'),
            trailing: const Icon(Icons.download),
            onTap: _busy ? null : _exportCsv,
          ),
          const Divider(),
          ListTile(
            title: const Text('Import JSON'),
            trailing: const Icon(Icons.upload),
            onTap: _busy ? null : _import,
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Note: API keys are never included in exports. Print output is '
              'sRGB; ICC profiles are not embedded.',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
