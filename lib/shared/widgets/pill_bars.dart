import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/bar_scale.dart';
import '../../core/utils/money.dart';
import 'entrance.dart';

/// One bar: its label under it, its spending, and whether it is lit (today,
/// the month on screen).
@immutable
class PillBar {
  const PillBar(this.label, this.totalMinor, {this.lit = false});

  final String label;
  final int totalMinor;
  final bool lit;
}

/// A row of pill bars, growing up one after another, scaled by [barScale]:
/// a bar far above the rest is capped, filling the height in the theme's
/// coral and fading out at its top. The lit bar is [color] with a glow; the
/// rest are see-through [color].
/// Used on the total card and the Analysis trend card.
class PillBars extends StatelessWidget {
  const PillBars({
    super.key,
    required this.bars,
    required this.color,
    required this.labelColor,
    this.height = AppSizes.heroBarsHeight,
    this.barWidthFactor = AppSizes.heroBarWidthFactor,
    this.onTap,
  });

  final List<PillBar> bars;
  final Color color;
  final Color labelColor;

  /// The whole row, labels included.
  final double height;

  /// Each bar's width as a share of its slot.
  final double barWidthFactor;

  /// Called with a bar's index when its slot is tapped.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final scale = barScale([for (final bar in bars) bar.totalMinor]);
    final capColor = context.colors.barCap;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, bar) in bars.indexed)
            Expanded(
              child: _Tappable(
                onTap: onTap == null ? null : () => onTap!(index),
                child: _Bar(
                  // A layout fraction for the bar's height, not money.
                  fraction: scale == 0
                      ? 0
                      : math.min(1, bar.totalMinor / scale).toDouble(),
                  capped: scale > 0 && bar.totalMinor > scale,
                  lit: bar.lit,
                  label: bar.label,
                  semantics: formatWithSymbol(bar.totalMinor),
                  delay: staggerDelay(index),
                  widthFactor: barWidthFactor,
                  color: color,
                  capColor: capColor,
                  labelColor: labelColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A bar's whole slot as a tap target, so a short bar is as easy to hit as
/// a tall one.
class _Tappable extends StatelessWidget {
  const _Tappable({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.capped,
    required this.lit,
    required this.label,
    required this.semantics,
    required this.delay,
    required this.widthFactor,
    required this.color,
    required this.capColor,
    required this.labelColor,
  });

  final double fraction;

  /// Above the row's scale: full height, coral, fading out at the top.
  final bool capped;
  final bool lit;
  final String label;
  final String semantics;
  final Duration delay;
  final double widthFactor;
  final Color color;
  final Color capColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final empty = fraction == 0;
    final fill = lit ? color : color.withValues(alpha: empty ? 0.18 : 0.42);
    return Semantics(
      label: '$label $semantics',
      excludeSemantics: true,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height =
                    constraints.maxHeight *
                    math.max(AppSizes.heroBarMinFactor, fraction);
                final width = constraints.maxWidth * widthFactor;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: _GrowUp(
                    delay: delay,
                    child: capped
                        ? _CappedBar(
                            width: width,
                            height: height,
                            color: capColor,
                            lit: lit,
                          )
                        : Container(
                            width: width,
                            height: height,
                            decoration: BoxDecoration(
                              color: fill,
                              borderRadius: BorderRadius.circular(height),
                              boxShadow: lit
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.7),
                                        blurRadius: 18,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxs + 2),
          Text(
            label,
            style: AppTextStyles.caption2.copyWith(
              color: labelColor.withValues(alpha: lit ? 1 : 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

/// A capped bar: [color], solid up to [_solidTo] of its height, then fading
/// out, so it reads as going on beyond the top. Lit, it is [color] at full
/// strength with a glow; the glow sits under the solid part only, so it
/// doesn't outline the faded top.
class _CappedBar extends StatelessWidget {
  const _CappedBar({
    required this.width,
    required this.height,
    required this.color,
    required this.lit,
  });

  // High enough that the capped bar's solid part isn't shorter than an
  // uncapped neighbour, which can reach nearly the full height.
  static const double _solidTo = 0.7;

  // The fade eases out and is gone just before the rounded end, so the
  // bar reads as running off the top, not as a two-tone pill.
  static const List<double> _fadeStops = [0, _solidTo, 0.86, 0.97];
  static const List<double> _fadeAlphas = [1, 1, 0.35, 0];
  static const double _unlitAlpha = 0.7;

  final double width;
  final double height;
  final Color color;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final fill = lit ? color : color.withValues(alpha: _unlitAlpha);
    final radius = BorderRadius.circular(width);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          if (lit)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * _solidTo,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.7),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    for (final alpha in _fadeAlphas)
                      fill.withValues(alpha: fill.a * alpha),
                  ],
                  stops: _fadeStops,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grows its child up from the bottom with a little bounce, after [delay].
class _GrowUp extends StatelessWidget {
  const _GrowUp({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      delay: delay,
      offset: Offset.zero,
      fromTilt: 0,
      duration: AppMotion.page,
      curve: AppMotion.pop,
      builderOverride: (t, child) => Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.diagonal3Values(1, t, 1),
        child: child,
      ),
      child: child,
    );
  }
}
