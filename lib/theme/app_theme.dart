import 'package:flutter/material.dart';

// ============================================================
// f∞ studio Design System v2.0 — Boundary Lab
// ============================================================

/// Canvas and accent colors from the f∞ studio design system.
class AppColors {
  AppColors._();

  // Canvas
  static const canvasPrimary = Color(0xFF0A0A0F);
  static const canvasSecondary = Color(0xFF1A1A2E);

  // Accent
  static const accentNeon = Color(0xFFDFFF4F);
  static const accentNeonMuted = Color(0x26DFFF4F); // 15% opacity

  // Functional
  static const error = Color(0xFFFF4F4F);
  static const success = Color(0xFF4FFF8C);
  static const warning = Color(0xFFFFD24F);
}

/// Opacity scales for text, surfaces, and borders on dark canvas.
class AppOpacity {
  AppOpacity._();

  // Text (white-based on dark canvas)
  static const textHero = 1.0;
  static const textHigh = 0.85;
  static const textBody = 0.7;
  static const textSecondary = 0.6;
  static const textTertiary = 0.5;
  static const textCaption = 0.4;
  static const textMuted = 0.3;
  static const textGhost = 0.2;
  static const textWhisper = 0.1;

  // Surface (white-based)
  static const surfaceElevated = 0.12;
  static const surfaceContainer = 0.08;
  static const surfaceSubtle = 0.05;
  static const surfaceFaint = 0.03;

  // Border (white-based)
  static const borderStrong = 0.3;
  static const borderMedium = 0.2;
  static const borderDefault = 0.12;
  static const borderSubtle = 0.08;
  static const borderFaint = 0.05;
}

/// Typography styles following the f∞ studio type scale.
class AppTypography {
  AppTypography._();

  static const _fontFamily = 'Inter';
  static const _monoFontFamily = 'JetBrains Mono';

  // display: 48px, w200, -0.02em, lineHeight 1.1
  static TextStyle display({double opacity = AppOpacity.textHero}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w200,
        letterSpacing: -0.02 * 48, // -0.02em
        height: 1.1,
        color: Colors.white.withValues(alpha: opacity),
      );

  // headline: 32px, w300, -0.01em, lineHeight 1.2
  static TextStyle headline({double opacity = AppOpacity.textHigh}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.01 * 32, // -0.01em
        height: 1.2,
        color: Colors.white.withValues(alpha: opacity),
      );

  // title: 24px, w500, 0, lineHeight 1.3
  static TextStyle title({double opacity = AppOpacity.textHigh}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.3,
        color: Colors.white.withValues(alpha: opacity),
      );

  // subtitle: 18px, w300, 0, lineHeight 1.4
  static TextStyle subtitle({double opacity = AppOpacity.textBody}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.4,
        color: Colors.white.withValues(alpha: opacity),
      );

  // body: 16px, w300, 0, lineHeight 1.6
  static TextStyle body({double opacity = AppOpacity.textBody}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.6,
        color: Colors.white.withValues(alpha: opacity),
      );

  // label: 14px, w500, 0.05em, lineHeight 1.0 (UPPERCASE usage)
  static TextStyle label({double opacity = AppOpacity.textHigh}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05 * 14, // 0.05em
        height: 1.0,
        color: Colors.white.withValues(alpha: opacity),
      );

  // section: 12px, w600, 0.15em, lineHeight 1.0 (UPPERCASE)
  static TextStyle section({double opacity = AppOpacity.textSecondary}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15 * 12, // 0.15em
        height: 1.0,
        color: Colors.white.withValues(alpha: opacity),
      );

  // mono: 12px, w400, 0.05em, lineHeight 1.4 (monospace)
  static TextStyle mono({double opacity = AppOpacity.textMuted}) => TextStyle(
        fontFamily: _monoFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.05 * 12, // 0.05em
        height: 1.4,
        color: Colors.white.withValues(alpha: opacity),
      );
}

/// Border radius tokens — 5 levels from sharp to pill.
class AppRadius {
  AppRadius._();

  static const sharp = 0.0;
  static const technical = 4.0;
  static const container = 12.0;
  static const surface = 16.0;
  static const pill = 999.0;
}

/// Spacing scale based on 4px increments.
class AppSpacing {
  AppSpacing._();

  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
  static const xxxxl = 64.0;
  static const xxxxxl = 96.0;
}

/// Builds the app-wide ThemeData from the design system tokens.
class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.canvasPrimary,
      colorScheme: ColorScheme.dark(
        surface: AppColors.canvasPrimary,
        primary: AppColors.accentNeon,
        secondary: AppColors.canvasSecondary,
        error: AppColors.error,
        onSurface: Colors.white,
        onPrimary: AppColors.canvasPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvasPrimary,
        foregroundColor: Colors.white.withValues(alpha: AppOpacity.textHigh),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: AppOpacity.surfaceContainer),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.container),
          side: BorderSide(
            color: Colors.white.withValues(alpha: AppOpacity.borderDefault),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: AppOpacity.borderDefault),
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: Colors.white.withValues(alpha: AppOpacity.textTertiary),
      ),
    );
  }
}
