import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool showSplashFirst;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.showSplashFirst = true,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Splash animation
  late AnimationController _splashController;
  late Animation<double> _titleFadeIn;
  late Animation<double> _titleDissolve;
  late Animation<double> _blurAnimation;
  bool _showOnboarding = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.camera_alt_outlined,
      title: 'Capture',
      subtitle: '撮る',
      description: 'Take a photo of your moment.\nBut the photo won\'t be saved.',
      descriptionJa: '写真を撮る。\nでも、写真は保存されない。',
    ),
    OnboardingPage(
      icon: Icons.blur_on,
      title: 'Dissolve',
      subtitle: '溶ける',
      description: 'The photo dissolves into data.\nColors, atmosphere, context.',
      descriptionJa: '写真はデータに溶けていく。\n色、雰囲気、コンテキスト。',
    ),
    OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'Remain',
      subtitle: '残る',
      description: 'Only the ambient trace remains.\nImagine the scene from data.',
      descriptionJa: '空気の痕跡だけが残る。\nデータから情景を想像する。',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Title fades in (0.0 - 0.3)
    _titleFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Title dissolves (0.5 - 1.0)
    _titleDissolve = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
      ),
    );

    // Blur increases during dissolve
    _blurAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
      ),
    );

    _splashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showOnboarding = true;
        });
      }
    });

    if (widget.showSplashFirst) {
      _splashController.forward();
    } else {
      _showOnboarding = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Onboarding content (fades in after splash)
          if (_showOnboarding)
            AnimatedOpacity(
              opacity: _showOnboarding ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: _buildOnboardingContent(),
            ),

          // Splash overlay (fades out)
          if (!_showOnboarding)
            AnimatedBuilder(
              animation: _splashController,
              builder: (context, child) {
                return Container(
                  color: const Color(0xFF0A0A0F),
                  child: Center(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value,
                      ),
                      child: Opacity(
                        opacity: _titleFadeIn.value * _titleDissolve.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ambientrace',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'trace the atmosphere',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent() {
    return Column(
      children: [
        // Top spacer with skip button
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),

        // Page content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
        ),

        // Page indicator (subtle dots)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => _buildDot(index),
            ),
          ),
        ),

        // Bottom button
        Padding(
          padding: EdgeInsets.fromLTRB(
            48,
            0,
            48,
            MediaQuery.of(context).padding.bottom + 48,
          ),
          child: GestureDetector(
            onTap: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                _completeOnboarding();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Text(
                  _currentPage < _pages.length - 1 ? 'Next' : 'Begin',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minimal icon
          Icon(
            page.icon,
            size: 48,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w200,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle (Japanese)
          Text(
            page.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 40),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 15,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 12),

          // Japanese description
          Text(
            page.descriptionJa,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isActive
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.15),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String descriptionJa;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.descriptionJa,
  });
}
