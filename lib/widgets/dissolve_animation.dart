import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

/// Animated widget that shows a photo "dissolving" into data particles
class DissolveAnimation extends StatefulWidget {
  final String imagePath;
  final Duration duration;

  const DissolveAnimation({
    super.key,
    required this.imagePath,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<DissolveAnimation> createState() => _DissolveAnimationState();
}

class _DissolveAnimationState extends State<DissolveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Blurred and fading image
            Positioned.fill(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Data particles rising up
            if (_particleAnimation.value > 0)
              Positioned.fill(
                child: CustomPaint(
                  painter: DataParticlePainter(
                    progress: _particleAnimation.value,
                  ),
                ),
              ),

            // "Converting to data..." text
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: (_particleAnimation.value * 2).clamp(0.0, 1.0),
                child: const Text(
                  'Converting to trace...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Paints rising data particles
class DataParticlePainter extends CustomPainter {
  final double progress;
  
  DataParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final particleCount = 50;
    
    for (int i = 0; i < particleCount; i++) {
      final seed = (random + i * 137) % 1000 / 1000;
      final x = seed * size.width;
      final startY = size.height * (0.3 + seed * 0.7);
      final endY = -50.0;
      final y = startY + (endY - startY) * progress;
      
      final opacity = (1.0 - progress) * (0.3 + seed * 0.7);
      final particleSize = 2.0 + seed * 4.0;
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      
      // Draw as small rectangles (data-like)
      if (i % 3 == 0) {
        // Binary-style dots
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: particleSize,
            height: particleSize * 0.5,
          ),
          paint,
        );
      } else {
        // Circular particles
        canvas.drawCircle(Offset(x, y), particleSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DataParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
