import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/location_service.dart';
import '../services/color_service.dart';
import '../services/storage_service.dart';
import '../services/image_labeling_service.dart';
import '../services/weather_service.dart';
import '../services/noise_service.dart';
import '../services/step_service.dart';
import '../models/trace_log.dart';
import '../widgets/dissolve_animation.dart';
import 'package:uuid/uuid.dart';
import 'package:native_exif/native_exif.dart';

class CaptureScreen extends StatefulWidget {
  final StorageService storageService;
  final ImageLabelingService imageLabelingService;

  const CaptureScreen({
    super.key,
    required this.storageService,
    required this.imageLabelingService,
  });

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCameraAvailable = false;
  bool _isCapturing = false;
  bool _showDissolve = false;
  String? _capturedImagePath;

  final _locationService = LocationService();
  final _colorService = ColorService();
  final _weatherService = WeatherService();
  final _noiseService = NoiseService();
  final _stepService = StepService();
  final _imagePicker = ImagePicker();
  final _uuid = const Uuid();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isCameraAvailable = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isCameraAvailable = false;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isCameraAvailable = false;
        });
      }
    }
  }

  Future<void> _captureFromCamera() async {
    if (_controller == null || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final image = await _controller!.takePicture();
      await _processImage(image.path);
    } catch (e) {
      print('Error capturing from camera: $e');
      _showError('Failed to capture trace');
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        await _processImage(image.path);
      } else {
        // User cancelled
        if (mounted) {
          setState(() => _isCapturing = false);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      _showError('Failed to pick image');
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _processImage(String imagePath) async {
    _capturedImagePath = imagePath;

    // Haptic feedback on capture (shutter feel)
    HapticFeedback.mediumImpact();

    // Show dissolve animation
    setState(() => _showDissolve = true);

    // Get device language for localized labels
    final languageCode = PlatformDispatcher.instance.locale.languageCode;

    // Gather all data in parallel
    final locationFuture = _locationService.getCurrentPosition();
    final colorFuture = _colorService.extractColors(
      FileImage(File(imagePath)),
    );
    final labelsFuture = widget.imageLabelingService.getLabels(
      imagePath,
      languageCode: languageCode,
    );
    final noiseFuture = _noiseService.measureNoiseLevel();
    final stepFuture = _stepService.getTodayStepCount();

    final position = await locationFuture;
    final colors = await colorFuture;
    final labels = await labelsFuture;
    final noiseLevel = await noiseFuture;
    final stepCount = await stepFuture;

    // Get place name and weather if we have location
    String? placeName;
    double? temperature;
    String? weatherCondition;
    
    if (position != null) {
      // Fetch place name and weather in parallel
      final placeNameFuture = _locationService.getPlaceName(
        position.latitude,
        position.longitude,
      );
      final weatherFuture = _weatherService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      
      placeName = await placeNameFuture;
      final weather = await weatherFuture;
      
      if (weather != null) {
        temperature = weather.temperature;
        weatherCondition = weather.condition;
      }
    }

    // Create trace log
    // Extract EXIF data (Date & Location)
    DateTime capturedDate = DateTime.now();
    double? exifLat;
    double? exifLon;

    try {
      final exif = await Exif.fromPath(imagePath);
      final originalDate = await exif.getOriginalDate();
      final latLong = await exif.getLatLong();
      await exif.close();

      if (originalDate != null) {
        capturedDate = originalDate;
        print('Captured: Using EXIF date: $originalDate');
      }

      if (latLong != null) {
        exifLat = latLong.latitude;
        exifLon = latLong.longitude;
        print('Captured: Using EXIF location: $latLong');
      }
    } catch (e) {
      print('Error reading EXIF: $e');
    }

    // Use EXIF location if available, otherwise fall back to current position
    final finalLat = exifLat ?? position?.latitude;
    final finalLon = exifLon ?? position?.longitude;

    // Refresh place name and weather if we are using EXIF location and it differs significantly
    if (exifLat != null && exifLon != null) {
      // Re-fetch place name and weather for the EXIF location
      try {
        placeName = await _locationService.getPlaceName(exifLat, exifLon);
        // Note: Weather service might only give current weather, but for now we use what we have.
        // Ideally we'd want historical weather, but that's a paid API feature usually.
        // We'll proceed with current weather at that location as a best effort approximation
        // or keep the already fetched weather if location is close.
        // For simplicity and to avoid "London weather for Tokyo photo", we fetch for the EXIF location.
        final weather = await _weatherService.getCurrentWeather(exifLat, exifLon);
        if (weather != null) {
          temperature = weather.temperature;
          weatherCondition = weather.condition;
        }
      } catch (e) {
        print('Error refreshing metadata for EXIF location: $e');
      }
    }

    // Create trace log
    final trace = TraceLog(
      id: _uuid.v4(),
      capturedAt: capturedDate,
      createdAt: DateTime.now(),
      latitude: finalLat,
      longitude: finalLon,
      placeName: placeName,
      colorPalette: colors,
      imageLabels: labels,
      noiseLevel: noiseLevel,
      stepCount: stepCount,
      temperature: temperature,
      weatherCondition: weatherCondition,
    );

    // Save trace
    await widget.storageService.saveTrace(trace);

    // Delete the photo file (we don't keep it!)
    try {
      await File(imagePath).delete();
    } catch (e) {
      // Ignore deletion errors for picked images
    }

    // Wait for animation then show success
    await Future.delayed(const Duration(milliseconds: 2500));

    // Haptic feedback on completion (soft confirmation)
    HapticFeedback.lightImpact();

    if (mounted) {
      // Build success message with captured data summary
      final capturedItems = <String>[];
      if (colors.isNotEmpty) capturedItems.add('${colors.length} colors');
      if (labels.isNotEmpty) capturedItems.add('${labels.length} traces');
      if (position != null) capturedItems.add('location');
      if (temperature != null) capturedItems.add('weather');
      if (noiseLevel != null) capturedItems.add('sound');

      final message = capturedItems.isNotEmpty
          ? 'Captured: ${capturedItems.join(', ')}'
          : 'Trace captured';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                labels.isEmpty ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: labels.isEmpty ? Colors.amber : Colors.greenAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Auto-navigate back to home screen
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
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
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    _noiseService.dispose();
    _stepService.dispose();
    super.dispose();
  }

  void _startPulse() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulse() {
    _pulseController
      ..stop()
      ..reset();
  }

  @override
  Widget build(BuildContext context) {
    // Manage pulse animation based on capturing state
    if (_isCapturing) {
      if (!_pulseController.isAnimating) _startPulse();
    } else {
      if (_pulseController.isAnimating) _stopPulse();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or placeholder
          if (_isInitialized)
            _isCameraAvailable && _controller != null
                ? Positioned.fill(
                    child: CameraPreview(_controller!),
                  )
                : _buildNoCameraUI()
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Dissolve animation overlay
          if (_showDissolve && _capturedImagePath != null)
            Positioned.fill(
              child: DissolveAnimation(imagePath: _capturedImagePath!),
            ),

          // Top gradient overlay for readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top bar - just a subtle back arrow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gallery button - smaller, subtle
                GestureDetector(
                  onTap: _isCapturing ? null : _pickFromGallery,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 40),

                // Capture button - elegant double-ring design
                GestureDetector(
                  onTap: _isCapturing
                      ? null
                      : (_isCameraAvailable
                          ? _captureFromCamera
                          : _pickFromGallery),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final scale =
                          _isCapturing ? _pulseAnimation.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                color: _isCapturing
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Offset to keep capture button visually centered
                const SizedBox(width: 84),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCameraUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.blur_on,
            size: 100,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 20),
          Text(
            'No camera found',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
