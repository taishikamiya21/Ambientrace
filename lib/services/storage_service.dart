import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trace_log.dart';
import 'folder_service.dart';

class StorageService {
  static const String _tracesKey = 'trace_logs';
  SharedPreferences? _prefs;
  final FolderService folderService;

  StorageService({FolderService? folderService})
    : folderService = folderService ?? FolderService();

  /// Initialize storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await folderService.init();
  }

  /// Save a new trace log
  Future<void> saveTrace(TraceLog trace) async {
    final traces = getAllTraces();
    traces.add(trace);
    await _saveTraces(traces);
  }

  /// Get all trace logs, sorted by date (newest first)
  List<TraceLog> getAllTraces() {
    final jsonString = _prefs?.getString(_tracesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final traces = jsonList.map((j) => TraceLog.fromJson(j)).toList();
      traces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return traces;
    } catch (e) {
      print('Error loading traces: $e');
      return [];
    }
  }

  /// Get traces for a specific date
  List<TraceLog> getTracesForDate(DateTime date) {
    return getAllTraces().where((trace) {
      return trace.capturedAt.year == date.year &&
          trace.capturedAt.month == date.month &&
          trace.capturedAt.day == date.day;
    }).toList();
  }

  /// Delete a trace
  Future<void> deleteTrace(String id) async {
    final traces = getAllTraces();
    traces.removeWhere((t) => t.id == id);
    await _saveTraces(traces);
    await folderService.removeTraceFromAllFolders(id);
  }

  /// Get trace count
  int get traceCount => getAllTraces().length;

  /// Save traces to storage
  Future<void> _saveTraces(List<TraceLog> traces) async {
    final jsonList = traces.map((t) => t.toJson()).toList();
    await _prefs?.setString(_tracesKey, json.encode(jsonList));
  }
}
