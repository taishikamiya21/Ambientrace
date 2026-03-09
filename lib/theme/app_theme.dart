import 'package:flutter/material.dart';

// ============================================================
// f∞ studio Design System v2.0 — Boundary Lab
// ============================================================

/// Canvas and accent colors from the f∞ studio design system.
class AppColors {
  AppColors._();

  // Dark canvas
  static const canvasPrimary = Color(0xFF0A0A0F);
  static const canvasSecondary = Color(0xFF1A1A2E);

  // Light canvas
  static const canvasLight = Color(0xFFF5F3EE);
  static const canvasLightSecondary = Color(0xFFECEAE4);
  static const onLight = Color(0xFF1A1819);

  // Accent
  static const accentNeon = Color(0xFFDFFF4F);
  static const accentNeonMuted = Color(0x26DFFF4F);

  // Functional
  static const error = Color(0xFFFF4F4F);
  static const success = Color(0xFF4FFF8C);
  static const warning = Color(0xFFFFD24F);
}

/// Opacity scales for text, surfaces, and borders on dark canvas.
class AppOpacity {
  AppOpacity._();

  static const textHero = 1.0;
  static const textHigh = 0.85;
  static const textBody = 0.7;
  static const textSecondary = 0.6;
  static const textTertiary = 0.5;
  static const textCaption = 0.4;
  static const textMuted = 0.3;
  static const textGhost = 0.2;
  static const textWhisper = 0.1;

  static const surfaceElevated = 0.12;
  static const surfaceContainer = 0.08;
  static const surfaceSubtle = 0.05;
  static const surfaceFaint = 0.03;

  static const borderStrong = 0.3;
  static const borderMedium = 0.2;
  static const borderDefault = 0.12;
  static const borderSubtle = 0.08;
  static const borderFaint = 0.05;
}

/// Typography styles following the f∞ studio type scale.
/// [color] を省略した場合は Colors.white を使用 (ダークモード互換)。
class AppTypography {
  AppTypography._();

  static const _fontFamily = 'Inter';
  static const _monoFontFamily = 'JetBrains Mono';

  static TextStyle display({Color? color, double opacity = AppOpacity.textHero}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w200,
        letterSpacing: -0.02 * 48,
        height: 1.1,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );

  static TextStyle headline({Color? color, double opacity = AppOpacity.textHigh}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.01 * 32,
        height: 1.2,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );

  static TextStyle title({Color? color, double opacity = AppOpacity.textHigh}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.3,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );

  static TextStyle subtitle({Color? color, double opacity = AppOpacity.textBody}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.4,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );

  static TextStyle body({Color? color, double opacity = AppOpacity.textBody}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.6,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );

  static TextStyle label({Color? color, double opacity = AppOpacity.textHigh}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05 * 14,
        height: 1.0,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );

  static TextStyle section({Color? color, double opacity = AppOpacity.textSecondary}) =>
      TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15 * 12,
        height: 1.0,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );

  static TextStyle mono({Color? color, double opacity = AppOpacity.textMuted}) => TextStyle(
        fontFamily: _monoFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.05 * 12,
        height: 1.4,
        color: (color ?? Colors.white).withValues(alpha: opacity),
      );
}

/// Border radius tokens
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

  static ThemeData light() {
    const base = AppColors.onLight;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.canvasLight,
      colorScheme: ColorScheme.light(
        surface: AppColors.canvasLight,
        primary: const Color(0xFF5A5418),
        secondary: AppColors.canvasLightSecondary,
        error: AppColors.error,
        onSurface: AppColors.onLight,
        onPrimary: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvasLight,
        foregroundColor: base.withValues(alpha: AppOpacity.textHigh),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: base.withValues(alpha: AppOpacity.surfaceContainer),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.container),
          side: BorderSide(
            color: base.withValues(alpha: AppOpacity.borderDefault),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: base.withValues(alpha: AppOpacity.borderDefault),
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: base.withValues(alpha: AppOpacity.textTertiary),
      ),
    );
  }
}

/// BuildContext extension — テーマに応じたセマンティックカラーを提供
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// 背景色
  Color get canvasColor =>
      isDark ? AppColors.canvasPrimary : AppColors.canvasLight;

  /// セカンダリ背景色
  Color get canvasSecondaryColor =>
      isDark ? AppColors.canvasSecondary : AppColors.canvasLightSecondary;

  /// テキストのベース色 (ダーク: white, ライト: near-black)
  Color get onCanvasColor => isDark ? Colors.white : AppColors.onLight;

  /// サーフェス/ボーダー用の半透明色
  Color onCanvasWithOpacity(double opacity) =>
      onCanvasColor.withValues(alpha: opacity);
}
