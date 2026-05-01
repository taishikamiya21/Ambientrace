import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/folder.dart';

class FolderService {
  static const _key = 'folders';
  final _uuid = const Uuid();

  List<Folder> _folders = [];
  final Map<String, Set<String>> _reverse = {}; // traceId -> Set<folderId>

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      final list = json.decode(raw) as List;
      _folders = list
          .map((j) => Folder.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    _rebuildReverseIndex();
  }

  Future<List<Folder>> listFolders() async => List.unmodifiable(_folders);

  Future<Folder> createFolder(String name) async {
    final f = Folder(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
      traceIds: const [],
    );
    _folders.add(f);
    await _persist();
    return f;
  }

  Future<void> renameFolder(String id, String newName) async {
    _folders = _folders
        .map((f) => f.id == id ? f.renamed(newName) : f)
        .toList();
    await _persist();
  }

  Future<void> deleteFolder(String id) async {
    _folders.removeWhere((f) => f.id == id);
    await _persist();
    _rebuildReverseIndex();
  }

  Future<void> addTraceToFolder(String traceId, String folderId) async {
    _folders = _folders
        .map((f) => f.id == folderId ? f.withAdded(traceId) : f)
        .toList();
    _reverse.putIfAbsent(traceId, () => <String>{}).add(folderId);
    await _persist();
  }

  Future<void> removeTraceFromFolder(String traceId, String folderId) async {
    _folders = _folders
        .map((f) => f.id == folderId ? f.withRemoved(traceId) : f)
        .toList();
    _reverse[traceId]?.remove(folderId);
    if (_reverse[traceId]?.isEmpty ?? false) _reverse.remove(traceId);
    await _persist();
  }

  Future<void> removeTraceFromAllFolders(String traceId) async {
    _folders = _folders.map((f) => f.withRemoved(traceId)).toList();
    _reverse.remove(traceId);
    await _persist();
  }

  Set<String> foldersOf(String traceId) =>
      Set.unmodifiable(_reverse[traceId] ?? const <String>{});

  void _rebuildReverseIndex() {
    _reverse.clear();
    for (final f in _folders) {
      for (final t in f.traceIds) {
        _reverse.putIfAbsent(t, () => <String>{}).add(f.id);
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      json.encode(_folders.map((f) => f.toJson()).toList()),
    );
  }
}
