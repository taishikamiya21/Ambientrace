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
        if (!matchesPlace && !matchesLabels && !matchesWeather) {
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
        dateKey = DateFormat('EEEE').format(trace.capturedAt); // Day name
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isSearching)
                        const Text(
                          'Ambientrace',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                        )
                      else
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search places, labels...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _applyFilters();
                              });
                            },
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: Colors.white70,
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
                          icon: const Icon(Icons.settings_outlined, color: Colors.white70),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_filteredTraces.length} traces',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      if (_weatherFilter != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _weatherFilter!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _weatherFilter = null;
                                    _applyFilters();
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Weather filter chips
            if (weatherConditions.isNotEmpty && !_isSearching)
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: weatherConditions.length,
                  itemBuilder: (context, index) {
                    final condition = weatherConditions[index];
                    final isSelected = _weatherFilter == condition;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(condition),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _weatherFilter = selected ? condition : null;
                            _applyFilters();
                          });
                        },
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        selectedColor: Colors.white.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Traces list
            Expanded(
              child: _filteredTraces.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: groupedTraces.length,
                      itemBuilder: (context, index) {
                        final dateKey = groupedTraces.keys.elementAt(index);
                        final tracesForDate = groupedTraces[dateKey]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: Text(
                                dateKey,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            // Traces for this date
                            ...tracesForDate.map((trace) => GestureDetector(
                              onTap: () => _openDetail(trace),
                              child: TraceCard(trace: trace),
                            )),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Capture button
      floatingActionButton: FloatingActionButton.large(
        onPressed: _openCapture,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        foregroundColor: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white24, width: 1),
        ),
        child: const Icon(Icons.camera_alt_outlined, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty || _weatherFilter != null
                ? Icons.search_off
                : Icons.air,
            size: 64,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _weatherFilter != null
                ? 'No traces found'
                : 'No traces yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _weatherFilter != null
                ? 'Try a different search'
                : 'Capture your first ambient trace',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
