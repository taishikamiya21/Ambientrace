import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trace_log.dart';
import '../theme/app_theme.dart';

/// ホーム画面のトレースカード — ポラロイド構造
///
/// Zone A: カラーグラデーションヒーロー（抽出した代表色 + 主タグ）
/// Zone B: ホワイトペーパーストリップ（大気的時間 + メタデータ）
/// Glow:   カラーパレット由来のアンビエントグロー (Spotify方式)
class TraceCard extends StatefulWidget {
  final TraceLog trace;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TraceCard({
    super.key,
    required this.trace,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<TraceCard> createState() => _TraceCardState();
}

class _TraceCardState extends State<TraceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();
  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final trace = widget.trace;
    final isDark = context.isDark;
    final paletteColors = trace.colorPalette.map((c) => Color(c)).toList();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onLongPress == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            // ストリップ色をベースに（clipで角丸が効く）
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.container),
            boxShadow: _buildShadows(isDark, paletteColors),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Zone A: グラデーションヒーロー ─────────────
              SizedBox(
                height: 130,
                child: Stack(
                  children: [
                    // カラーグラデーション背景
                    Positioned.fill(
                        child: _buildGradientBg(paletteColors)),
                    // テキスト可読性のための下部フェード
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.60),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // 主タグ + 副タグ（左下揃え）
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.md,
                      child: _buildHeroContent(trace),
                    ),
                  ],
                ),
              ),

              // ── Zone B: ホワイトペーパーストリップ ──────────
              _buildPaperStrip(trace),
            ],
          ),
        ),
      ),
    );
  }

  // ── シャドウ (アンビエントグロー) ─────────────────────────

  List<BoxShadow> _buildShadows(bool isDark, List<Color> paletteColors) {
    final shadows = <BoxShadow>[];

    // パレット由来のアンビエントグロー
    if (paletteColors.isNotEmpty) {
      shadows.add(BoxShadow(
        color: paletteColors.first.withValues(alpha: isDark ? 0.50 : 0.25),
        blurRadius: isDark ? 28 : 18,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ));
    }

    // 構造的シャドウ（カードの輪郭を下から支える）
    shadows.add(BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.10),
      blurRadius: isDark ? 16 : 8,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ));

    return shadows;
  }

  // ── Zone A: グラデーション背景 ────────────────────────────

  Widget _buildGradientBg(List<Color> paletteColors) {
    if (paletteColors.isEmpty) {
      // カラーなし: 落ち着いたダークグラデーション
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.canvasSecondary, AppColors.canvasPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }

    final List<Color> gradientColors = paletteColors.length == 1
        ? [paletteColors.first, paletteColors.first.withValues(alpha: 0.55)]
        : paletteColors;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ── Zone A: ヒーローテキスト ──────────────────────────────

  Widget _buildHeroContent(TraceLog trace) {
    // グラデーション上では常に白テキスト
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          trace.imageLabels.isNotEmpty
              ? trace.imageLabels.first
              : (trace.atmosphericTime ?? ''),
          style: AppTypography.subtitle(
            color: Colors.white,
            opacity: AppOpacity.textHero,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (trace.imageLabels.length > 1) ...[
          const SizedBox(height: AppSpacing.xxs),
          Wrap(
            spacing: AppSpacing.xxs,
            runSpacing: AppSpacing.xxs,
            children: trace.imageLabels.skip(1).take(3).map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  label,
                  style: AppTypography.mono(
                    color: Colors.white,
                    opacity: 0.90,
                  ).copyWith(fontSize: 10),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── Zone B: ペーパーストリップ ────────────────────────────

  Widget _buildPaperStrip(TraceLog trace) {
    // ストリップは常にホワイト背景 + ダークテキスト
    const tc = AppColors.onLight;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 大気的時間 — ストリップのヒーローテキスト
          Text(
            trace.imageLabels.isEmpty
                ? _metadataLine(trace)
                : (trace.atmosphericTime ?? ''),
            style: AppTypography.body(
              color: tc,
              opacity: AppOpacity.textHigh,
            ).copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          // メタデータ行 (時刻 · 場所 · 気温 · 天気)
          Text(
            _metadataLine(trace),
            style: AppTypography.mono(
              color: tc,
              opacity: AppOpacity.textTertiary,
            ).copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _metadataLine(TraceLog trace) {
    final lang = ui.PlatformDispatcher.instance.locale.languageCode;
    final parts = <String>[];
    final time = trace.formattedTime;
    if (time != null) parts.add(time);
    if (trace.placeName != null) parts.add(trace.placeName!);
    if (trace.temperature != null) parts.add('${trace.temperature!.round()}°');
    if (trace.weatherCondition != null) {
      parts.add(lang == 'ja'
          ? trace.weatherCondition!
          : trace.weatherCondition!.toUpperCase());
    }
    return parts.join(' · ');
  }
}
