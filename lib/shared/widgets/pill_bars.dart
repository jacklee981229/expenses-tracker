import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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

/// A row of pill bars scaled to the biggest, growing up one after another.
/// The lit bar is [color] with a glow; the rest are see-through [color].
/// Used on the total card and the Analysis trend card.
class PillBars extends StatelessWidget {
  const PillBars({
    super.key,
    required this.bars,
    required this.color,
    required this.labelColor,
  });

  final List<PillBar> bars;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final biggest = bars.fold(0, (most, bar) => math.max(most, bar.totalMinor));
    return SizedBox(
      height: AppSizes.heroBarsHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, bar) in bars.indexed)
            Expanded(
              child: _Bar(
                // A layout fraction for the bar's height, not money.
                fraction: biggest == 0 ? 0 : bar.totalMinor / biggest,
                lit: bar.lit,
                label: bar.label,
                semantics: formatWithSymbol(bar.totalMinor),
                delay: staggerDelay(index),
                color: color,
                labelColor: labelColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.lit,
    required this.label,
    required this.semantics,
    required this.delay,
    required this.color,
    required this.labelColor,
  });

  final double fraction;
  final bool lit;
  final String label;
  final String semantics;
  final Duration delay;
  final Color color;
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
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: _GrowUp(
                    delay: delay,
                    child: Container(
                      width: constraints.maxWidth * AppSizes.heroBarWidthFactor,
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
