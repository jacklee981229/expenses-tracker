import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../data/database/daos/analysis_dao.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/pressable.dart';
import '../analysis_providers.dart';
import '../category_detail_screen.dart';

/// A card per category, largest first, coming in one after another: icon,
/// name and amount over a bar in the category colour that grows to its
/// share, and the share in a small violet tag. The category of a tapped
/// donut slice lifts and the others dim. Tap for the category's expenses in
/// the period.
class CategoryBreakdownList extends ConsumerWidget {
  const CategoryBreakdownList({super.key, required this.totals});

  final List<CategoryTotal> totals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlighted = ref.watch(highlightedCategoryIdsProvider);
    final selection = ref.watch(periodSelectionProvider);
    final bounds = ref.watch(periodBoundsProvider);
    final grandTotal = sumTotals(totals);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, total) in totals.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm - 2),
              child: Entrance(
                delay: AppMotion.normal ~/ 2 + staggerDelay(index),
                child: _BreakdownCard(
                  total: total,
                  grandTotal: grandTotal,
                  barDelay: AppMotion.slow + staggerDelay(index),
                  highlighted: highlighted.contains(total.category.id),
                  dimmed:
                      highlighted.isNotEmpty &&
                      !highlighted.contains(total.category.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CategoryDetailScreen(
                        category: total.category,
                        bounds: bounds,
                        periodLabel: periodLabel(selection, bounds),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.total,
    required this.grandTotal,
    required this.barDelay,
    required this.highlighted,
    required this.dimmed,
    required this.onTap,
  });

  final CategoryTotal total;
  final int grandTotal;
  final Duration barDelay;
  final bool highlighted;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final category = total.category;
    final tint = colorFromHex(category.colorHex);
    return AnimatedOpacity(
      opacity: dimmed ? 0.45 : 1,
      duration: AppMotion.normal,
      child: AnimatedScale(
        scale: highlighted ? 1.03 : 1,
        duration: AppMotion.slow,
        curve: AppMotion.pop,
        child: Pressable(
          onTap: onTap,
          pressedScale: 0.97,
          child: AnimatedContainer(
            duration: AppMotion.slow,
            curve: AppMotion.enter,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm - 1,
              AppSpacing.sm - 1,
              AppSpacing.md - 2,
              AppSpacing.sm - 1,
            ),
            decoration: cardDecoration(colors, radius: AppRadius.card - 4)
                .copyWith(
                  border: Border.all(
                    color: highlighted
                        ? tint
                        : colors.surface.withValues(alpha: 0),
                    width: 1.5,
                  ),
                ),
            child: Row(
              children: [
                CategoryAvatar.of(category),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.rowTitle.copyWith(
                                color: colors.label,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                formatWithSymbol(total.totalMinor),
                                style: AppTextStyles.amount.copyWith(
                                  color: colors.label,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: _ShareBar(
                              // A layout fraction for the bar, not money.
                              fraction: grandTotal <= 0
                                  ? 0
                                  : total.totalMinor / grandTotal,
                              color: tint,
                              delay: barDelay,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            AppStrings.expenseCount(total.count),
                            style: AppTextStyles.footnote.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Transform.rotate(
                  angle: 0.08,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs - 1,
                      vertical: AppSpacing.xxs - 1,
                    ),
                    decoration: BoxDecoration(
                      color: colors.fill,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      formatShare(
                        total.totalMinor,
                        grandTotal,
                        trimZeros: true,
                      ),
                      style: AppTextStyles.caption2.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded bar that grows out to its share after [delay].
class _ShareBar extends StatelessWidget {
  const _ShareBar({
    required this.fraction,
    required this.color,
    required this.delay,
  });

  final double fraction;
  final Color color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.shareBarHeight / 2),
      child: SizedBox(
        height: AppSizes.shareBarHeight,
        width: double.infinity,
        child: ColoredBox(
          color: context.colors.fill,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Entrance(
              delay: delay,
              duration: AppMotion.page,
              builderOverride: (t, child) => FractionallySizedBox(
                widthFactor: (fraction * t).clamp(0.0, 1.0),
                heightFactor: 1,
                child: child,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    AppSizes.shareBarHeight / 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
