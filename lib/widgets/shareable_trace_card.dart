import 'package:flutter/material.dart';
import '../models/trace_log.dart';
import '../theme/app_theme.dart';

/// 詳細画面のトレースカード (共有・保存対応) — ポラロイドアーティファクト
///
/// Zone A: カラーグラデーションヒーロー → クリームへフェード
///         主タグ・副タグをグラデーション上に下揃えでオーバーレイ
///
/// Zone B: ウォームクリームペーパーストリップ (#F5F3EE)
///         大気的時間(22px) → カラードット → 日時 → 情報チップ
///         → ストーリー(フェードイン) → AMBIENTRACE ブランディング
///
/// ホーム画面の TraceCard と同じポラロイド言語を拡張した大判フォーマット
class TraceCard extends StatefulWidget {
  final TraceLog trace;
  final String? story;
  final String languageCode;

  /// v1.2 Phase B (C-7): show the original photo filename in small mono
  /// type at the bottom-right of Zone B. Helps cross-reference printed
  /// cards with their source photos in a gallery / exhibition context.
  final bool showOriginalFileName;

  const TraceCard({
    super.key,
    required this.trace,
    required this.languageCode,
    this.story,
    this.showOriginalFileName = false,
  });

  @override
  State<TraceCard> createState() => _TraceCardState();
}

class _TraceCardState extends State<TraceCard> {
  // Hero is sized off the actual card height via LayoutBuilder so Zone B
  // always has enough room for 4 story lines on every device. Slightly
  // generous fraction + min so the title and tags have breathing room.
  static const double _heroFraction = 0.45;
  static const double _heroMin = 180.0;
  static const double _heroMax = 260.0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.surface),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.surface),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heroH =
                (constraints.maxHeight * _heroFraction).clamp(_heroMin, _heroMax);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Zone A: グラデーションヒーロー ────────────
                SizedBox(
                  height: heroH,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _buildHeroGradient()),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.92),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        bottom: AppSpacing.lg,
                        child: _buildHeroTags(),
                      ),
                    ],
                  ),
                ),

                // ── Zone B: ホワイトペーパーストリップ ────────
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAtmosphericHero(),
                        const SizedBox(height: AppSpacing.xxs),
                        _buildDateTimeRow(),
                        const SizedBox(height: AppSpacing.xs),
                        if (widget.trace.colorPalette.isNotEmpty) ...[
                          _buildColorDots(),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        if (widget.trace.placeName != null ||
                            widget.trace.temperature != null ||
                            widget.trace.weatherCondition != null) ...[
                          _buildInfoChips(),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        // Story occupies remaining space. Text(maxLines:4)
                        // truncates with ellipsis if a sentence is too long.
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 700),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.10),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut)),
                                  child: child,
                                ),
                              );
                            },
                            child:
                                (widget.story != null && widget.story!.isNotEmpty)
                                    ? Align(
                                        key: ValueKey(widget.story),
                                        alignment: Alignment.topLeft,
                                        child: _buildStoryBlock(),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('no-story')),
                          ),
                        ),
                        _buildBranding(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Zone A: ヒーロー部品 ────────────────────────────

  Widget _buildHeroGradient() {
    final colors = widget.trace.colorPalette.map((c) => Color(c)).toList();
    final List<Color> gradientColors;
    if (colors.isEmpty) {
      gradientColors = [
        const Color(0xFF2A2A3E),
        AppColors.canvasSecondary,
      ];
    } else if (colors.length == 1) {
      gradientColors = [
        colors.first,
        colors.first.withValues(alpha: 0.60),
      ];
    } else {
      gradientColors = colors;
    }

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

  Widget _buildHeroTags() {
    // グラデーション上 → 常に白テキスト
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.trace.imageLabels.isNotEmpty
              ? widget.trace.imageLabels.first
              : widget.trace.atmosphericTimeForLanguage(widget.languageCode),
          style: AppTypography.headline(color: Colors.white).copyWith(
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: const Offset(0, 1),
                blurRadius: 10,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.trace.imageLabels.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildSecondaryTags(),
        ],
      ],
    );
  }

  Widget _buildSecondaryTags() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      // Match home/list view: 1 main label + up to 3 secondary chips.
      children: widget.trace.imageLabels
          .skip(1)
          .take(3)
          .toList()
          .asMap()
          .entries
          .map((entry) {
        final index = entry.key;
        final label = entry.value;
        final paletteColor = widget.trace.colorPalette.isNotEmpty
            ? Color(widget.trace.colorPalette[
                (index + 1) % widget.trace.colorPalette.length])
            : null;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: paletteColor != null
                ? paletteColor.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.label(
              color: Colors.white,
              opacity: AppOpacity.textHigh,
            ).copyWith(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  // ── Zone B: ペーパーストリップ部品 ─────────────────────
  // すべて AppColors.onLight (#1A1819) ベースのダークテキスト

  static const _tc = AppColors.onLight;

  /// 大気的時間 — ペーパーストリップの中心
  Widget _buildAtmosphericHero() {
    return Text(
      widget.trace.atmosphericTimeForLanguage(widget.languageCode),
      style: AppTypography.headline(
        color: _tc,
        opacity: AppOpacity.textHigh,
      ).copyWith(fontSize: 22),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTimeRow() {
    return Text(
      '${widget.trace.formattedTime}  ·  ${widget.trace.formattedDate}',
      style: AppTypography.mono(
        color: _tc,
        opacity: AppOpacity.textTertiary,
      ),
    );
  }

  /// カラードット — クリーム上でグロー効果が宝石的に映える
  Widget _buildColorDots() {
    return Row(
      children: widget.trace.colorPalette.asMap().entries.map((e) {
        final color = Color(e.value);
        final isLast = e.key == widget.trace.colorPalette.length - 1;
        return Container(
          width: 18,
          height: 18,
          margin: EdgeInsets.only(right: isLast ? 0 : 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: _tc.withValues(alpha: AppOpacity.borderSubtle),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (widget.trace.placeName != null)
          _buildInfoChip(Icons.location_on_outlined, widget.trace.placeName!),
        if (widget.trace.temperature != null)
          _buildInfoChip(Icons.thermostat_outlined,
              '${widget.trace.temperature!.round()}°C'),
        if (widget.trace.weatherCondition != null)
          _buildInfoChip(Icons.cloud_outlined, widget.trace.weatherCondition!),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _tc.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: _tc.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: _tc.withValues(alpha: AppOpacity.textSecondary), size: 12),
          const SizedBox(width: 5),
          Text(
            value,
            style: AppTypography.mono(
              color: _tc,
              opacity: AppOpacity.textHigh,
            ).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// ストーリーブロック — エディトリアル左アクセントライン
  ///
  /// 4 行 × 13px × line-height 1.4 = 72.8px が理想。利用可能な高さに応じて
  /// maxLines を 1〜4 に動的調整。`strutStyle` で leading を固定し、
  /// 末尾のディセンダーが切れないように 6px の安全余白を加える。
  Widget _buildStoryBlock() {
    final accentColor = widget.trace.colorPalette.isNotEmpty
        ? Color(widget.trace.colorPalette.first)
        : _tc.withValues(alpha: 0.30);

    const fontSize = 13.0;
    const lineHeight = 1.4;
    const lineSize = fontSize * lineHeight; // 18.2px

    return LayoutBuilder(
      builder: (context, constraints) {
        // 末尾の安全余白 6px を引いた上で、収まる行数を計算 (1〜4)。
        final usable = constraints.maxHeight - 6;
        final maxLines = (usable / lineSize).floor().clamp(1, 4);
        final accentHeight = lineSize * maxLines;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 2.5,
                height: accentHeight,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.story!,
                  style: AppTypography.body(
                    color: _tc,
                    opacity: AppOpacity.textBody,
                  ).copyWith(
                    fontSize: fontSize,
                    fontStyle: FontStyle.italic,
                    height: lineHeight,
                  ),
                  strutStyle: const StrutStyle(
                    fontSize: fontSize,
                    height: lineHeight,
                    forceStrutHeight: true,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ブランディングフッター + 任意の元画像ファイル名注記
  Widget _buildBranding() {
    final fileName = widget.trace.originalFileName;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showOriginalFileName &&
            fileName != null &&
            fileName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                fileName,
                style: AppTypography.mono(
                  color: _tc,
                  opacity: AppOpacity.textCaption,
                ).copyWith(fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grain,
              color: _tc.withValues(alpha: AppOpacity.textCaption),
              size: 11,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'AMBIENTRACE',
              style: AppTypography.section(
                color: _tc,
                opacity: AppOpacity.textCaption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
