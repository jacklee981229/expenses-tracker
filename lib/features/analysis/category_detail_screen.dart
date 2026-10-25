import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_colors.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/icon_registry.dart';
import '../../data/database/app_database.dart';
import '../../shared/widgets/category_avatar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/glow_scaffold.dart';
import '../../shared/widgets/summary_card.dart';
import '../ledger/widgets/day_grouped_expense_list.dart';
import 'analysis_providers.dart';

/// The ledger's day-grouped list, scoped to one category and one period,
/// under a summary card with that category's total for the period.
class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.bounds,
    required this.periodLabel,
  });

  final ExpenseCategory category;

  /// Null for All.
  final DateBounds? bounds;
  final String periodLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(
      categoryDetailProvider((
        categoryId: category.id,
        start: bounds?.start,
        end: bounds?.end,
      )),
    );
    final list = groups.valueOrNull ?? const [];
    final total = list.fold(0, (sum, group) => sum + group.totalMinor);
    final count = list.fold(0, (sum, group) => sum + group.items.length);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: SummaryCard(
        label: category.name,
        labelColor: colorFromHex(category.colorHex),
        leading: CategoryAvatar.of(category, size: AppSizes.smallAvatar),
        valueMinor: total,
        details: [(periodLabel, AppStrings.expenseCount(count))],
      ),
    );

    return GlowScaffold(
      appBar: AppBar(title: Text(category.name)),
      body: groups.when(
        data: (groups) => DayGroupedExpenseList(
          groups: groups,
          header: header,
          empty: const EmptyState(
            icon: UiIcons.chart,
            message: AppStrings.noExpensesInPeriod,
          ),
        ),
        loading: () => header,
        error: (error, _) =>
            EmptyState(icon: UiIcons.chart, message: error.toString()),
      ),
    );
  }
}
