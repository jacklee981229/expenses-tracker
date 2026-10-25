import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../core/utils/money.dart';
import '../../../shared/today_provider.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/hero_surface.dart';
import '../../../shared/widgets/rolling_amount.dart';
import '../ledger_providers.dart';

/// The month's total on the violet card, leaning a little, with a receipt
/// sticker and white pill bars ([heroBarsProvider]). This month also shows
/// today's spend. The total flashes red when it grows and green when it
/// shrinks. It swings in when the ledger opens.
class TotalCard extends ConsumerWidget {
  const TotalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final month = ref.watch(selectedMonthProvider);
    final today = ref.watch(todayProvider);
    final total = ref.watch(monthTotalProvider);
    // While a month loads, the total jumps without anything being added.
    final loading = ref.watch(monthExpensesProvider).isLoading;
    final todayTotal = ref.watch(todayTotalProvider).valueOrNull ?? 0;
    final bars = ref.watch(heroBarsProvider);
    final isCurrentMonth =
        month.year == today.year && month.month == today.month;
    final onHero = colors.onAccent;

    return Entrance(
      offset: const Offset(0, 36),
      fromTilt: -8,
      fromScale: 0.9,
      curve: AppMotion.pop,
      child: Transform.rotate(
        angle: AppSizes.heroTilt * math.pi / 180,
        child: Stack(
          children: [
            HeroSurface(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl - 2,
                AppSpacing.lg,
                AppSpacing.xl - 2,
                AppSpacing.sm + 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The label and figure keep clear of the sticker, so a
                  // long total shrinks instead of running under it.
                  Padding(
                    padding: const EdgeInsets.only(
                      right: AppSizes.sticker + AppSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCurrentMonth
                              ? AppStrings.spentThisMonth
                              : AppStrings.spentIn(formatMonthShort(month)),
                          style: AppTextStyles.callout.copyWith(
                            color: onHero.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: RollingAmount(
                            total,
                            style: AppTextStyles.hero.copyWith(color: onHero),
                            flashScope: (month, loading),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentMonth) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _TodayChip(minor: todayTotal),
                  ],
                  if (bars != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _Bars(bars: bars),
                  ],
                ],
              ),
            ),
            const Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: _Sticker(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  const _TodayChip({required this.minor});

  final int minor;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onAccent;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xxs + 1,
        AppSpacing.sm,
        AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.chipHeight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UiIcon(UiIcons.sun, size: AppSizes.labelIcon),
          const SizedBox(width: AppSpacing.xxs + 2),
          Text(
            AppStrings.today,
            style: AppTextStyles.footnote.copyWith(color: onHero),
          ),
          const SizedBox(width: AppSpacing.xxs + 2),
          RollingAmount(
            minor,
            style: AppTextStyles.chipFigure.copyWith(color: onHero),
          ),
        ],
      ),
    );
  }
}

/// A receipt picture on a white disc, stuck on at an angle.
class _Sticker extends StatelessWidget {
  const _Sticker();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Entrance(
      delay: AppMotion.slow,
      offset: Offset.zero,
      fromTilt: -50,
      fromScale: 0,
      duration: AppMotion.page,
      curve: AppMotion.pop,
      child: Transform.rotate(
        angle: AppSizes.stickerTilt * math.pi / 180,
        child: Container(
          width: AppSizes.sticker,
          height: AppSizes.sticker,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.onAccent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.accentDeep.withValues(alpha: 0.5),
                offset: const Offset(0, 10),
                blurRadius: 18,
                spreadRadius: -8,
              ),
            ],
          ),
          child: const UiIcon(UiIcons.receipt, size: AppSizes.stickerIcon),
        ),
      ),
    );
  }
}

/// One pill per day or week, scaled to the biggest, growing up one after
/// another.
class _Bars extends StatelessWidget {
  const _Bars({required this.bars});

  final List<HeroBar> bars;

  @override
  Widget build(BuildContext context) {
    final busiest = bars.fold(0, (most, bar) => math.max(most, bar.totalMinor));
    return SizedBox(
      height: AppSizes.heroBarsHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, bar) in bars.indexed)
            Expanded(
              child: _Bar(
                // A layout fraction for the bar's height, not money.
                fraction: busiest == 0 ? 0 : bar.totalMinor / busiest,
                isToday: bar.lit,
                label: bar.label,
                semantics: formatWithSymbol(bar.totalMinor),
                delay: staggerDelay(index),
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
    required this.isToday,
    required this.label,
    required this.semantics,
    required this.delay,
  });

  final double fraction;
  final bool isToday;
  final String label;
  final String semantics;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onAccent;
    final empty = fraction == 0;
    final color = isToday
        ? onHero
        : onHero.withValues(alpha: empty ? 0.18 : 0.42);
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
                        color: color,
                        borderRadius: BorderRadius.circular(height),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: onHero.withValues(alpha: 0.7),
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
              color: onHero.withValues(alpha: isToday ? 1 : 0.75),
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
