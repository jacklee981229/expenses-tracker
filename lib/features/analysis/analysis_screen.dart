import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/icon_registry.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/entrance.dart';
import '../../shared/widgets/large_title.dart';
import '../../shared/widgets/rolling_amount.dart';
import 'analysis_providers.dart';
import 'widgets/category_breakdown_list.dart';
import 'widgets/period_switcher.dart';
import 'widgets/spend_pie_chart.dart';

/// The period switcher and filter, a card with the period's spend, daily
/// spend and the categories donut, then a card per category. Changing the
/// period or the filter replays the entrance.
class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(filteredCategoryTotalsProvider);
    final selection = ref.watch(periodSelectionProvider);
    final bounds = ref.watch(periodBoundsProvider);
    final filter = ref.watch(categoryFilterProvider);
    final scope =
        '${selection.period.name}|${bounds?.start}|${filter.join(',')}';

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSizes.fabClearance),
        children: [
          const LargeTitle(
            Text(AppStrings.tabAnalysis),
            kicker: AppStrings.analysisKicker,
          ),
          const PeriodSwitcher(),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Entrance(
              key: ValueKey('card|$scope'),
              child: _ChartCard(
                hasData: totals.valueOrNull?.isNotEmpty ?? false,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...totals.when(
            data: (totals) => [
              if (totals.isNotEmpty)
                CategoryBreakdownList(
                  key: ValueKey('list|$scope'),
                  totals: totals,
                ),
            ],
            loading: () => const [],
            error: (error, _) => [
              EmptyState(icon: UiIcons.chart, message: error.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

/// The period's spend and daily spend over the donut, or a message when the
/// period has nothing.
class _ChartCard extends ConsumerWidget {
  const _ChartCard({required this.hasData});

  final bool hasData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final label = AppTextStyles.caption1.copyWith(color: colors.labelSecondary);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.spentStat, style: label),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RollingAmount(
                        ref.watch(filteredTotalProvider),
                        style: AppTextStyles.tileValue.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppStrings.perDayStat, style: label),
                  const SizedBox(height: AppSpacing.xxs),
                  RollingAmount(
                    ref.watch(dailyExpenseProvider),
                    style: AppTextStyles.headline.copyWith(color: colors.label),
                  ),
                ],
              ),
            ],
          ),
          if (hasData) ...[
            const SizedBox(height: AppSpacing.sm),
            const SpendPieChart(),
          ] else
            const EmptyState(
              icon: UiIcons.chart,
              message: AppStrings.noExpensesInPeriod,
            ),
        ],
      ),
    );
  }
}
