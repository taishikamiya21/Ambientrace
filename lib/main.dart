import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'services/image_labeling_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final imageLabelingService = ImageLabelingService();
  await imageLabelingService.init();

  runApp(AmbientraleApp(
    storageService: storageService,
    imageLabelingService: imageLabelingService,
  ));
}

class AmbientraleApp extends StatelessWidget {
  final StorageService storageService;
  final ImageLabelingService imageLabelingService;

  const AmbientraleApp({
    super.key,
    required this.storageService,
    required this.imageLabelingService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambientrace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5CE7),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        fontFamily: 'SF Pro Display',
      ),
      home: HomeScreen(
        storageService: storageService,
        imageLabelingService: imageLabelingService,
      ),
    );
  }
}
