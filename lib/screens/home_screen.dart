import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trace_log.dart';
import '../services/storage_service.dart';
import '../services/image_labeling_service.dart';
import '../theme/app_theme.dart';
import 'capture_screen.dart';
import 'trace_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/trace_card.dart';

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
  String _searchQuery = '';
  String? _weatherFilter;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTraces();
  }

  void _loadTraces() {
    setState(() {
      _traces = widget.storageService.getAllTraces();
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredTraces = _traces.where((trace) {
      // Search filter
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

      // Weather filter
      if (_weatherFilter != null) {
        if (trace.weatherCondition != _weatherFilter) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openCapture() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaptureScreen(
          storageService: widget.storageService,
          imageLabelingService: widget.imageLabelingService,
        ),
      ),
    );
    _loadTraces();
  }

  void _openDetail(TraceLog trace) {
    Navigator.push(
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
      // Track the newest createdAt per group for sorting
      if (!groupOrder.containsKey(dateKey) || trace.createdAt.isAfter(groupOrder[dateKey]!)) {
        groupOrder[dateKey] = trace.createdAt;
      }
    }

    // Sort groups by newest trace date descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => groupOrder[b]!.compareTo(groupOrder[a]!));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
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

    return Scaffold(
      backgroundColor: AppColors.canvasPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
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
                              style: AppTypography.headline(),
                            ),
                          )
                        else
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              style: AppTypography.body(),
                              decoration: InputDecoration(
                                hintText: 'Search atmosphere, places...',
                                hintStyle: AppTypography.body(
                                    opacity: AppOpacity.textMuted),
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
                                color: Colors.white
                                    .withValues(alpha: AppOpacity.textTertiary),
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
                                  color: Colors.white.withValues(
                                      alpha: AppOpacity.textTertiary),
                                  size: 22,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen(
                                        imageLabelingService:
                                            widget.imageLabelingService,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    if (!_isSearching)
                      Row(
                        children: [
                          Text(
                            _filteredTraces.isEmpty
                                ? 'No traces yet'
                                : '${_filteredTraces.length} ${_filteredTraces.length == 1 ? 'trace' : 'traces'}',
                            style: AppTypography.mono(
                                opacity: AppOpacity.textMuted),
                          ),
                          if (_weatherFilter != null) ...[
                            SizedBox(width: AppSpacing.sm),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _weatherFilter = null;
                                  _applyFilters();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs + 2,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                      alpha: AppOpacity.surfaceContainer),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.container),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _weatherFilter!,
                                      style: AppTypography.mono(
                                          opacity: AppOpacity.textSecondary),
                                    ),
                                    SizedBox(width: AppSpacing.xxs),
                                    Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.white.withValues(
                                          alpha: AppOpacity.textCaption),
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

            // Weather filter chips
            if (weatherConditions.isNotEmpty && !_isSearching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: weatherConditions.length,
                      itemBuilder: (context, index) {
                        final condition = weatherConditions[index];
                        final isSelected = _weatherFilter == condition;
                        return Padding(
                          padding: EdgeInsets.only(right: AppSpacing.xs),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _weatherFilter =
                                    isSelected ? null : condition;
                                _applyFilters();
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm + 2,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentNeon
                                        .withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentNeon
                                          .withValues(alpha: 0.3)
                                      : Colors.white.withValues(
                                          alpha: AppOpacity.borderDefault),
                                ),
                              ),
                              child: Text(
                                condition.toUpperCase(),
                                style: AppTypography.mono(
                                  opacity: AppOpacity.textSecondary,
                                ).copyWith(
                                  color: isSelected
                                      ? AppColors.accentNeon
                                      : null,
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

            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Content
            if (_filteredTraces.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dateKey = groupedTraces.keys.elementAt(index);
                    final tracesForDate = groupedTraces[dateKey]!;

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: EdgeInsets.fromLTRB(AppSpacing.xs,
                                AppSpacing.md, AppSpacing.xs, AppSpacing.xs),
                            child: Text(
                              dateKey.toUpperCase(),
                              style: AppTypography.section(),
                            ),
                          ),
                          // Traces for this date
                          ...tracesForDate.map((trace) => GestureDetector(
                                onTap: () => _openDetail(trace),
                                child: TraceCard(trace: trace),
                              )),
                        ],
                      ),
                    );
                  },
                  childCount: groupedTraces.length,
                ),
              ),

            // Bottom spacing for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // Capture button
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        child: GestureDetector(
          onTap: _openCapture,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: AppOpacity.borderMedium),
                width: 1.5,
              ),
              color: Colors.white
                  .withValues(alpha: AppOpacity.surfaceContainer),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: AppOpacity.borderStrong),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white
                      .withValues(alpha: AppOpacity.textBody),
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

  Widget _buildEmptyState() {
    final isFiltered = _searchQuery.isNotEmpty || _weatherFilter != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.air,
              size: 48,
              color: Colors.white.withValues(alpha: AppOpacity.borderDefault),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              isFiltered ? 'No traces found' : 'No traces yet',
              style: AppTypography.subtitle(opacity: AppOpacity.textCaption),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              isFiltered
                  ? 'Try a different search'
                  : 'Capture the atmosphere of your moment',
              style: AppTypography.body(opacity: AppOpacity.textGhost),
            ),
          ],
        ),
      ),
    );
  }
}
