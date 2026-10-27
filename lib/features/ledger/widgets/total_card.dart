import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/today_provider.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/hero_surface.dart';
import '../../../shared/widgets/max_lines_wrap.dart';
import '../../../shared/widgets/pill_bars.dart';
import '../../../shared/widgets/rolling_amount.dart';
import '../ledger_providers.dart';

/// The month's total on the hero glass, leaning a little, with a receipt
/// sticker, the month's top three categories ([monthLegendProvider]) and
/// pill bars ([heroBarsProvider]). This month also shows today's spend. The
/// total flashes when it grows or shrinks. It swings in when the ledger
/// opens.
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
    final legend = ref.watch(monthLegendProvider);
    final onHero = colors.onHero;

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
                            color: colors.onHeroSecondary,
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
                  if (isCurrentMonth || legend.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    // Two rows at most, so the card keeps its height: the
                    // smaller categories drop out first.
                    MaxLinesWrap(
                      maxLines: AppSizes.heroChipLines,
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (isCurrentMonth) _TodayChip(minor: todayTotal),
                        for (final (category, percent) in legend)
                          _LegendChip(category: category, percent: percent),
                      ],
                    ),
                  ],
                  if (bars != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    PillBars(
                      bars: bars,
                      color: onHero,
                      labelColor: colors.onHeroSecondary,
                    ),
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
    final colors = context.colors;
    final onHero = colors.onHero;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xxs + 1,
        AppSpacing.sm,
        AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: colors.heroChip,
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

/// One of the month's top categories: its colour, name and share.
class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.category, required this.percent});

  final ExpenseCategory category;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dot = colorFromHex(category.colorHex);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.sm - 2,
        AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.heroChip,
        borderRadius: BorderRadius.circular(AppSizes.chipHeight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.legendDot,
            height: AppSizes.legendDot,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xxs + 2),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.legendNameMaxWidth,
            ),
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption1.copyWith(
                color: colors.onHeroSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            AppStrings.shareOfMonth(percent),
            style: AppTextStyles.chipFigure.copyWith(color: colors.onHero),
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
                color: colors.shadow,
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
