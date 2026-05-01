import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/folder.dart';
import '../models/trace_log.dart';
import '../services/storage_service.dart';
import '../services/image_labeling_service.dart';
import '../theme/app_theme.dart';
import '../widgets/folder_selector.dart';
import '../widgets/shareable_trace_card.dart' as shareable;
import '../widgets/trace_card.dart';
import 'capture_screen.dart';
import 'settings_screen.dart';
import 'trace_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final ImageLabelingService imageLabelingService;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.imageLabelingService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TraceLog> _traces = [];
  List<TraceLog> _filteredTraces = [];
  List<Folder> _folders = const [];
  String _searchQuery = '';
  String? _weatherFilter;
  String? _selectedFolderId;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTraces();
    _loadFolders();
  }

  void _loadTraces() {
    setState(() {
      _traces = widget.storageService.getAllTraces();
      _applyFilters();
    });
  }

  Future<void> _loadFolders() async {
    final folders = await widget.storageService.folderService.listFolders();
    if (!mounted) return;
    setState(() {
      _folders = folders;
      if (_selectedFolderId != null &&
          !_folders.any((folder) => folder.id == _selectedFolderId)) {
        _selectedFolderId = null;
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredTraces = _traces.where((trace) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesPlace = trace.placeName?.toLowerCase().contains(query) ?? false;
        final matchesLabels = trace.imageLabels.any((l) => l.toLowerCase().contains(query));
        final matchesWeather = trace.weatherCondition?.toLowerCase().contains(query) ?? false;
        final matchesAtmospheric = trace.atmosphericTime.toLowerCase().contains(query);
        if (!matchesPlace && !matchesLabels && !matchesWeather && !matchesAtmospheric) {
          return false;
        }
      }
      if (_weatherFilter != null) {
        if (trace.weatherCondition != _weatherFilter) return false;
      }
      if (_selectedFolderId != null) {
        final folders =
            widget.storageService.folderService.foldersOf(trace.id);
        if (!folders.contains(_selectedFolderId)) return false;
      }
      return true;
    }).toList();
  }

  void _openCapture() async {
    HapticFeedback.lightImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaptureScreen(
          storageService: widget.storageService,
          imageLabelingService: widget.imageLabelingService,
        ),
      ),
    );
    if (!mounted) return;
    _loadTraces();
    await _loadFolders();
  }

  void _openDetail(TraceLog trace) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TraceDetailScreen(
          trace: trace,
          storageService: widget.storageService,
          imageLabelingService: widget.imageLabelingService,
          onDelete: _loadTraces,
        ),
      ),
    );
    if (!mounted) return;
    _loadTraces();
    await _loadFolders();
  }

  Map<String, List<TraceLog>> _groupByDate(List<TraceLog> traces) {
    final grouped = <String, List<TraceLog>>{};
    final groupOrder = <String, DateTime>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final trace in traces) {
      final traceDate = DateTime(
        trace.createdAt.year,
        trace.createdAt.month,
        trace.createdAt.day,
      );
      String dateKey;
      if (traceDate == today) {
        dateKey = 'Today';
      } else if (traceDate == yesterday) {
        dateKey = 'Yesterday';
      } else if (now.difference(traceDate).inDays < 7) {
        dateKey = DateFormat('EEEE').format(trace.createdAt);
      } else {
        dateKey = DateFormat('MMM d, yyyy').format(trace.createdAt);
      }
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(trace);
      if (!groupOrder.containsKey(dateKey) || trace.createdAt.isAfter(groupOrder[dateKey]!)) {
        groupOrder[dateKey] = trace.createdAt;
      }
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => groupOrder[b]!.compareTo(groupOrder[a]!));
    return Map.fromEntries(sortedKeys.map((key) => MapEntry(key, grouped[key]!)));
  }

  List<String> _getUniqueWeatherConditions() {
    return _traces
        .where((t) => t.weatherCondition != null)
        .map((t) => t.weatherCondition!)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupedTraces = _groupByDate(_filteredTraces);
    final weatherConditions = _getUniqueWeatherConditions();
    final tc = context.onCanvasColor;

    return Scaffold(
      backgroundColor: context.canvasColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isSearching)
                          Expanded(
                            child: Text(
                              'Ambientrace',
                              style: AppTypography.headline(color: tc),
                            ),
                          )
                        else
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              style: AppTypography.body(color: tc),
                              decoration: InputDecoration(
                                hintText: 'Search atmosphere, places...',
                                hintStyle: AppTypography.body(
                                    color: tc, opacity: AppOpacity.textMuted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isSearching ? Icons.close : Icons.search,
                                color: tc.withValues(alpha: AppOpacity.textTertiary),
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSearching = !_isSearching;
                                  if (!_isSearching) {
                                    _searchQuery = '';
                                    _applyFilters();
                                  }
                                });
                              },
                            ),
                            if (!_isSearching)
                              IconButton(
                                icon: Icon(
                                  Icons.settings_outlined,
                                  color: tc.withValues(alpha: AppOpacity.textTertiary),
                                  size: 22,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen(
                                        storageService: widget.storageService,
                                        imageLabelingService:
                                            widget.imageLabelingService,
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  // Image import / JSON import via settings
                                  // can change traces too, not just folders.
                                  _loadTraces();
                                  await _loadFolders();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    if (!_isSearching)
                      Row(
                        children: [
                          Text(
                            _filteredTraces.isEmpty
                                ? 'No traces yet'
                                : '${_filteredTraces.length} ${_filteredTraces.length == 1 ? 'trace' : 'traces'}',
                            style: AppTypography.mono(
                                color: tc, opacity: AppOpacity.textMuted),
                          ),
                          if (_weatherFilter != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _weatherFilter = null;
                                  _applyFilters();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs + 2,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: tc.withValues(alpha: AppOpacity.surfaceContainer),
                                  borderRadius: BorderRadius.circular(AppRadius.container),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _weatherFilter!,
                                      style: AppTypography.mono(
                                          color: tc, opacity: AppOpacity.textSecondary),
                                    ),
                                    const SizedBox(width: AppSpacing.xxs),
                                    Icon(
                                      Icons.close,
                                      size: 12,
                                      color: tc.withValues(alpha: AppOpacity.textCaption),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),

            if (!_isSearching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: FolderSelector(
                    folders: _folders,
                    selectedFolderId: _selectedFolderId,
                    onChanged: (id) {
                      setState(() {
                        _selectedFolderId = id;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ),

            // Weather filter chips
            if (weatherConditions.isNotEmpty && !_isSearching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: weatherConditions.length,
                      itemBuilder: (context, index) {
                        final condition = weatherConditions[index];
                        final isSelected = _weatherFilter == condition;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _weatherFilter = isSelected ? null : condition;
                                _applyFilters();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm + 2,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentNeon.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentNeon.withValues(alpha: 0.3)
                                      : tc.withValues(alpha: AppOpacity.borderDefault),
                                ),
                              ),
                              child: Text(
                                condition.toUpperCase(),
                                style: AppTypography.mono(
                                  color: tc,
                                  opacity: AppOpacity.textSecondary,
                                ).copyWith(
                                  color: isSelected ? AppColors.accentNeon : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Content
            if (_filteredTraces.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(tc),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dateKey = groupedTraces.keys.elementAt(index);
                    final tracesForDate = groupedTraces[dateKey]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xs, AppSpacing.md, AppSpacing.xs, AppSpacing.xs),
                            child: Text(
                              dateKey.toUpperCase(),
                              style: AppTypography.section(color: tc),
                            ),
                          ),
                          ...tracesForDate.map((trace) => TraceCard(
                                trace: trace,
                                onTap: () => _openDetail(trace),
                                onLongPress: () => _showCardActions(trace),
                              )),
                        ],
                      ),
                    );
                  },
                  childCount: groupedTraces.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // Capture button
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: GestureDetector(
          onTap: _openCapture,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tc.withValues(alpha: AppOpacity.borderMedium),
                width: 1.5,
              ),
              color: tc.withValues(alpha: AppOpacity.surfaceContainer),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tc.withValues(alpha: AppOpacity.borderStrong),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: tc.withValues(alpha: AppOpacity.textBody),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── 一覧画面: カード長押しアクション ─────────────────────

  bool get _isJa => Localizations.localeOf(context).languageCode == 'ja';

  Future<void> _showCardActions(TraceLog trace) async {
    final isJa = _isJa;
    final tc = context.onCanvasColor;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.canvasSecondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.surface)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.withValues(alpha: AppOpacity.textGhost),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sheetButton(
                icon: Icons.photo_library_outlined,
                label: isJa ? 'フォトライブラリに保存' : 'Save to Library',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _saveCardToLibrary(trace);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              _sheetButton(
                icon: Icons.share_outlined,
                label: isJa ? '共有する' : 'Share',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _shareCard(trace);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              _sheetButton(
                icon: Icons.delete_outline,
                label: isJa ? '削除' : 'Delete',
                destructive: true,
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _confirmDelete(trace);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              _sheetButton(
                icon: Icons.close,
                label: isJa ? 'キャンセル' : 'Cancel',
                muted: true,
                onTap: () => Navigator.pop(sheetCtx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool muted = false,
    bool destructive = false,
  }) {
    final tc = context.onCanvasColor;
    final fg = destructive ? AppColors.error : tc;
    final iconAlpha = muted ? AppOpacity.textCaption : AppOpacity.textBody;
    final textAlpha = muted ? AppOpacity.textCaption : AppOpacity.textHigh;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: tc.withValues(
            alpha: muted ? AppOpacity.surfaceFaint : AppOpacity.surfaceSubtle,
          ),
          borderRadius: BorderRadius.circular(AppRadius.container),
          border: Border.all(
            color: tc.withValues(alpha: AppOpacity.borderSubtle),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: destructive ? fg : fg.withValues(alpha: iconAlpha),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.body(
                color: fg,
                opacity: destructive ? AppOpacity.textHigh : textAlpha,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(TraceLog trace) async {
    final isJa = _isJa;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isJa ? 'トレースを削除しますか？' : 'Delete Trace?'),
        content: Text(
          isJa
              ? 'このトレースは完全に削除されます。'
              : 'This trace will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isJa ? 'キャンセル' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isJa ? '削除' : 'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    await widget.storageService.deleteTrace(trace.id);
    _loadTraces();
    await _loadFolders();
  }

  Future<Uint8List?> _renderCard(TraceLog trace) async {
    final lang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final boundaryKey = GlobalKey();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -10000,
        top: -10000,
        // MediaQuery override keeps hero height and layout consistent across
        // devices so the saved/shared image looks identical on every phone.
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 540),
            devicePixelRatio: 1.0,
          ),
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 360,
              height: 540,
              child: RepaintBoundary(
                key: boundaryKey,
                child: shareable.TraceCard(
                  trace: trace,
                  languageCode: lang,
                  story: trace.aiDescription,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }

  Future<void> _saveCardToLibrary(TraceLog trace) async {
    final isJa = _isJa;
    try {
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isJa
                    ? '写真ライブラリへのアクセスを許可してください。'
                    : 'Please grant photo library access.',
              ),
            ),
          );
        }
        return;
      }
      final bytes = await _renderCard(trace);
      if (bytes == null) {
        throw Exception('render failed');
      }
      await Gal.putImageBytes(bytes);
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isJa ? '画像を保存しました' : 'Image saved to library'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isJa ? '保存に失敗しました' : 'Failed to save')),
        );
      }
    }
  }

  Future<void> _shareCard(TraceLog trace) async {
    final isJa = _isJa;
    try {
      final bytes = await _renderCard(trace);
      if (bytes == null) throw Exception('render failed');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ambientrace_${trace.id}.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Captured with Ambientrace',
        sharePositionOrigin: origin,
      );
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isJa ? '共有に失敗しました' : 'Failed to share')),
        );
      }
    }
  }

  Widget _buildEmptyState(Color tc) {
    final isFiltered = _searchQuery.isNotEmpty ||
        _weatherFilter != null ||
        _selectedFolderId != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.air,
              size: 48,
              color: tc.withValues(alpha: AppOpacity.borderDefault),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isFiltered ? 'No traces found' : 'No traces yet',
              style: AppTypography.subtitle(color: tc, opacity: AppOpacity.textCaption),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isFiltered
                  ? 'Try a different search'
                  : 'Capture the atmosphere of your moment',
              style: AppTypography.body(color: tc, opacity: AppOpacity.textGhost),
            ),
          ],
        ),
      ),
    );
  }
}
