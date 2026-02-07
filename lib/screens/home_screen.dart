import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trace_log.dart';
import '../services/storage_service.dart';
import '../services/image_labeling_service.dart';
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final trace in traces) {
      final traceDate = DateTime(
        trace.capturedAt.year,
        trace.capturedAt.month,
        trace.capturedAt.day,
      );

      String dateKey;
      if (traceDate == today) {
        dateKey = 'Today';
      } else if (traceDate == yesterday) {
        dateKey = 'Yesterday';
      } else if (now.difference(traceDate).inDays < 7) {
        dateKey = DateFormat('EEEE').format(trace.capturedAt);
      } else {
        dateKey = DateFormat('MMM d, yyyy').format(trace.capturedAt);
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(trace);
    }

    return grouped;
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
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isSearching)
                          const Expanded(
                            child: Text(
                              'Ambientrace',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 3,
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search atmosphere, places...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
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
                                color: Colors.white.withValues(alpha: 0.5),
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
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 22,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen(
                                        geminiService: widget.imageLabelingService.geminiService,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (!_isSearching)
                      Row(
                        children: [
                          Text(
                            _filteredTraces.isEmpty
                                ? 'No traces yet'
                                : '${_filteredTraces.length} ${_filteredTraces.length == 1 ? 'trace' : 'traces'}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (_weatherFilter != null) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _weatherFilter = null;
                                  _applyFilters();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _weatherFilter!,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.white.withValues(alpha: 0.4),
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
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: weatherConditions.length,
                      itemBuilder: (context, index) {
                        final condition = weatherConditions[index];
                        final isSelected = _weatherFilter == condition;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _weatherFilter = isSelected ? null : condition;
                                _applyFilters();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Text(
                                condition,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
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

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Text(
                              dateKey.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
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
        margin: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: _openCapture,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white.withValues(alpha: 0.7),
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
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No traces found' : 'No traces yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try a different search'
                  : 'Capture the atmosphere of your moment',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
