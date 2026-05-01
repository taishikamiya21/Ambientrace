import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'services/image_labeling_service.dart';
import 'services/migration_service.dart';
import 'services/secure_key_storage.dart';
import 'services/llm_service.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme service
  await ThemeService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.canvasPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  await MigrationService(prefs: prefs, secure: SecureKeyStorage()).run();
  await LlmService.presetService.init();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  final storageService = StorageService();
  await storageService.init();

  final imageLabelingService = ImageLabelingService();
  await imageLabelingService.init();

  runApp(
    AmbientraleApp(
      storageService: storageService,
      imageLabelingService: imageLabelingService,
      showOnboarding: !onboardingComplete,
    ),
  );
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
    ThemeService.instance.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeService.instance.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  void _onOnboardingComplete() => setState(() => _showOnboarding = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambientrace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeService.instance.themeNotifier.value,
      home: _showOnboarding
          ? OnboardingScreen(onComplete: _onOnboardingComplete)
          : HomeScreen(
              storageService: widget.storageService,
              imageLabelingService: widget.imageLabelingService,
            ),
    );
  }
}
