import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'services/image_labeling_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.canvasPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final imageLabelingService = ImageLabelingService();
  await imageLabelingService.init();

  runApp(AmbientraleApp(
    storageService: storageService,
    imageLabelingService: imageLabelingService,
    showOnboarding: !onboardingComplete,
  ));
}

class AmbientraleApp extends StatefulWidget {
  final StorageService storageService;
  final ImageLabelingService imageLabelingService;
  final bool showOnboarding;

  const AmbientraleApp({
    super.key,
    required this.storageService,
    required this.imageLabelingService,
    required this.showOnboarding,
  });

  @override
  State<AmbientraleApp> createState() => _AmbientraleAppState();
}

class _AmbientraleAppState extends State<AmbientraleApp> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    _showOnboarding = widget.showOnboarding;
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambientrace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: _showOnboarding
          ? OnboardingScreen(onComplete: _onOnboardingComplete)
          : HomeScreen(
              storageService: widget.storageService,
              imageLabelingService: widget.imageLabelingService,
            ),
    );
  }
}
