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

class _CaptureScreenState extends State<CaptureScreen> {
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

  @override
  void initState() {
    super.initState();
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
    final trace = TraceLog(
      id: _uuid.v4(),
      capturedAt: DateTime.now(),
      latitude: position?.latitude,
      longitude: position?.longitude,
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
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _noiseService.dispose();
    _stepService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            DissolveAnimation(imagePath: _capturedImagePath!),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                GestureDetector(
                  onTap: _isCapturing ? null : _pickFromGallery,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white38, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: _isCapturing
                      ? null
                      : (_isCameraAvailable ? _captureFromCamera : _pickFromGallery),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _isCapturing
                          ? Colors.grey.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                    child: _isCapturing
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            _isCameraAvailable ? Icons.lens : Icons.add_photo_alternate,
                            color: Colors.white,
                            size: 50,
                          ),
                  ),
                ),

                // Placeholder for balance
                const SizedBox(width: 56, height: 56),
              ],
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Capture Trace',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
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
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Camera not available',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to select an image',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
