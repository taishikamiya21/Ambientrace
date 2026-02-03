import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/trace_log.dart';
import '../services/storage_service.dart';
import '../services/image_labeling_service.dart';
import '../widgets/shareable_trace_card.dart';

class TraceDetailScreen extends StatefulWidget {
  final TraceLog trace;
  final StorageService storageService;
  final ImageLabelingService imageLabelingService;
  final VoidCallback onDelete;

  const TraceDetailScreen({
    super.key,
    required this.trace,
    required this.storageService,
    required this.imageLabelingService,
    required this.onDelete,
  });

  @override
  State<TraceDetailScreen> createState() => _TraceDetailScreenState();
}

class _TraceDetailScreenState extends State<TraceDetailScreen> {
  String? _generatedStory;
  bool _isGeneratingStory = false;
  String? _storyError;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.trace.formattedDate,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
                  )
                : const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: _isSharing ? null : _shareTrace,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time
            Text(
              widget.trace.formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w200,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 32),

            // Color palette
            if (widget.trace.colorPalette.isNotEmpty) ...[
              _buildSectionTitle('Colors'),
              const SizedBox(height: 12),
              Row(
                children: widget.trace.colorPalette.map((colorValue) {
                  return Expanded(
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],

            // Location
            if (widget.trace.placeName != null) ...[
              _buildSectionTitle('Location'),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                value: widget.trace.placeName!,
              ),
              const SizedBox(height: 32),
            ],

            // Weather & Atmosphere
            if (widget.trace.temperature != null || widget.trace.weatherCondition != null || widget.trace.noiseLevel != null) ...[
              _buildSectionTitle('Atmosphere'),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.trace.temperature != null)
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.thermostat_outlined,
                        value: '${widget.trace.temperature!.round()}°C',
                      ),
                    ),
                  if (widget.trace.temperature != null && widget.trace.weatherCondition != null)
                    const SizedBox(width: 12),
                  if (widget.trace.weatherCondition != null)
                    Expanded(
                      child: _buildInfoCard(
                        icon: _getWeatherIcon(widget.trace.weatherCondition!),
                        value: widget.trace.weatherCondition!,
                      ),
                    ),
                ],
              ),
              if (widget.trace.noiseLevel != null) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.volume_up_outlined,
                  value: '${widget.trace.noiseLevel!.round()} dB',
                ),
              ],
              const SizedBox(height: 32),
            ],

            // Ambient Traces (Labels)
            _buildSectionTitle('Ambient Traces'),
            const SizedBox(height: 12),
            if (widget.trace.imageLabels.isNotEmpty)
              _buildAmbientTracesList(widget.trace.imageLabels, widget.trace.colorPalette)
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No ambient traces were captured for this moment.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // AI Story Generation
            _buildStorySection(),
            const SizedBox(height: 32),

            // Coordinates
            if (widget.trace.latitude != null && widget.trace.longitude != null) ...[
              _buildSectionTitle('Coordinates'),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.explore_outlined,
                value: '${widget.trace.latitude!.toStringAsFixed(4)}, ${widget.trace.longitude!.toStringAsFixed(4)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection() {
    final isGeminiConfigured = widget.imageLabelingService.geminiService.isConfigured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Memory'),
        const SizedBox(height: 12),

        if (_generatedStory != null) ...[
          // Display generated story
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.amber.withValues(alpha: 0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Generated',
                      style: TextStyle(
                        color: Colors.amber.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _generatedStory!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Regenerate button
          Center(
            child: TextButton.icon(
              onPressed: _isGeneratingStory ? null : _generateStory,
              icon: Icon(
                Icons.refresh,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              label: Text(
                'Regenerate',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ] else if (_isGeneratingStory) ...[
          // Loading state
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.amber.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Generating memory...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ] else if (_storyError != null) ...[
          // Error state
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _storyError!,
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _generateStory,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
            ),
          ),
        ] else ...[
          // Generate button
          GestureDetector(
            onTap: isGeminiConfigured ? _generateStory : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: isGeminiConfigured
                        ? Colors.amber.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.3),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isGeminiConfigured
                        ? 'Generate Memory'
                        : 'API Key Required',
                    style: TextStyle(
                      color: isGeminiConfigured
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _generateStory() async {
    setState(() {
      _isGeneratingStory = true;
      _storyError = null;
    });

    try {
      final languageCode = ui.PlatformDispatcher.instance.locale.languageCode;

      // Convert color palette to descriptions
      final colorDescriptions = widget.trace.colorPalette.map((colorValue) {
        final color = Color(colorValue);
        return _describeColor(color);
      }).toList();

      final story = await widget.imageLabelingService.geminiService.generateStory(
        time: widget.trace.formattedTime,
        ambientTraces: widget.trace.imageLabels,
        colorDescriptions: colorDescriptions,
        weather: widget.trace.weatherCondition,
        temperature: widget.trace.temperature != null
            ? '${widget.trace.temperature!.round()}°C'
            : null,
        placeName: widget.trace.placeName,
        languageCode: languageCode,
      );

      if (mounted) {
        setState(() {
          _generatedStory = story;
          _isGeneratingStory = false;
          if (story == null) {
            _storyError = 'Failed to generate memory. Please try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingStory = false;
          _storyError = 'An error occurred. Please try again.';
        });
      }
    }
  }

  Future<void> _shareTrace() async {
    setState(() => _isSharing = true);

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Create the shareable card widget and render it
      final card = ShareableTraceCard(
        trace: widget.trace,
        story: _generatedStory,
      );

      // Use a temporary overlay to render the widget
      final imageBytes = await _captureWidgetAsImage(card);

      if (imageBytes != null) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();

        // Ensure the directory exists
        if (!await tempDir.exists()) {
          await tempDir.create(recursive: true);
        }

        final file = File('${tempDir.path}/ambientrace_${widget.trace.id}.png');
        await file.writeAsBytes(imageBytes);

        // Share the image (sharePositionOrigin required for iPad)
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null;

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Captured with Ambientrace',
          sharePositionOrigin: sharePositionOrigin,
        );

        // Haptic feedback on success
        HapticFeedback.mediumImpact();
      }
    } catch (e, stackTrace) {
      print('Share error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to share: ${e.toString().length > 50 ? e.toString().substring(0, 50) : e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<List<int>?> _captureWidgetAsImage(Widget widget) async {
    // Create a repaint boundary key
    final repaintKey = GlobalKey();

    // Create an overlay entry to render the widget off-screen
    final overlayState = Overlay.of(context);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -2000, // Off-screen (further away for safety)
        top: -2000,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: repaintKey,
            child: SizedBox(
              width: 400, // Fixed width for consistent rendering
              child: widget,
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Wait for the widget to be rendered (longer delay for real devices)
    await Future.delayed(const Duration(milliseconds: 300));

    // Wait for the frame to be rendered
    await WidgetsBinding.instance.endOfFrame;

    try {
      // Capture the image
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('Share error: RenderRepaintBoundary is null');
        return null;
      }

      if (!boundary.hasSize) {
        print('Share error: RenderRepaintBoundary has no size');
        return null;
      }

      print('Share: Capturing image with size ${boundary.size}');
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('Share error: byteData is null');
        return null;
      }

      print('Share: Image captured successfully, size: ${byteData.lengthInBytes} bytes');
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Share error in _captureWidgetAsImage: $e');
      rethrow;
    } finally {
      overlayEntry.remove();
    }
  }

  String _describeColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final lightness = hsl.lightness;
    final saturation = hsl.saturation;
    final hue = hsl.hue;

    String brightness;
    if (lightness < 0.3) {
      brightness = 'dark';
    } else if (lightness > 0.7) {
      brightness = 'light';
    } else {
      brightness = '';
    }

    String colorName;
    if (saturation < 0.1) {
      if (lightness < 0.2) {
        colorName = 'black';
      } else if (lightness > 0.8) {
        colorName = 'white';
      } else {
        colorName = 'gray';
      }
    } else if (hue < 30) {
      colorName = 'red';
    } else if (hue < 60) {
      colorName = 'orange';
    } else if (hue < 90) {
      colorName = 'yellow';
    } else if (hue < 150) {
      colorName = 'green';
    } else if (hue < 210) {
      colorName = 'cyan';
    } else if (hue < 270) {
      colorName = 'blue';
    } else if (hue < 330) {
      colorName = 'purple';
    } else {
      colorName = 'red';
    }

    return brightness.isEmpty ? colorName : '$brightness $colorName';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildAmbientTracesList(List<String> labels, List<int> colorPalette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: labels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final baseColor = colorPalette.isNotEmpty
            ? Color(colorPalette[index % colorPalette.length])
            : Colors.white;
        final accentColor = baseColor.withValues(alpha: 0.3);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.2),
                Colors.transparent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: baseColor.withValues(alpha: 0.6),
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w300,
              height: 1.4,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_outlined;
      case 'cloudy':
        return Icons.cloud_outlined;
      case 'rain':
      case 'showers':
      case 'drizzle':
        return Icons.water_drop_outlined;
      case 'snow':
      case 'snow showers':
        return Icons.ac_unit_outlined;
      case 'thunderstorm':
      case 'thunderstorm with hail':
        return Icons.flash_on_outlined;
      case 'foggy':
        return Icons.foggy;
      default:
        return Icons.cloud_outlined;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Delete Trace?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This trace will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await widget.storageService.deleteTrace(widget.trace.id);
              widget.onDelete();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
