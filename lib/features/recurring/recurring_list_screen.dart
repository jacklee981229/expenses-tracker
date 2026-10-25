import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/icon_registry.dart';
import '../../data/database/daos/recurring_dao.dart';
import '../../shared/widgets/amount_text.dart';
import '../../shared/widgets/category_avatar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/inset_group.dart';
import '../../shared/widgets/inset_row.dart';
import '../../shared/widgets/glow_scaffold.dart';
import 'edit_recurring_screen.dart';
import 'recurring_providers.dart';

/// Fixed monthly expense rules. Paused rules are dimmed and tagged.
class RecurringListScreen extends ConsumerWidget {
  const RecurringListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(recurringRulesProvider);
    return GlowScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.fixedMonthlyExpenses),
        actions: [
          IconButton(
            tooltip: AppStrings.addFixedExpense,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _open(context, null),
          ),
        ],
      ),
      body: rules.when(
        data: (rules) => rules.isEmpty
            ? EmptyState(
                icon: UiIcons.calendar,
                message: AppStrings.noFixedExpenses,
                actionLabel: AppStrings.addFixedExpense,
                onAction: () => _open(context, null),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                children: [
                  InsetGroup(
                    children: [
                      for (final item in rules)
                        _RuleRow(item: item, onTap: () => _open(context, item)),
                    ],
                  ),
                ],
              ),
        loading: () => const SizedBox.shrink(),
        error: (error, _) =>
            EmptyState(icon: UiIcons.calendar, message: error.toString()),
      ),
    );
  }

  void _open(BuildContext context, RecurringRuleWithCategory? item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditRecurringScreen(existing: item?.rule),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.item, required this.onTap});

  final RecurringRuleWithCategory item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rule = item.rule;
    final note = rule.note;
    final schedule = AppStrings.everyMonthOn(rule.dayOfMonth);
    return Opacity(
      opacity: rule.isActive ? 1 : AppSizes.pausedOpacity,
      child: InsetRow(
        leading: CategoryAvatar.of(item.category),
        title: note ?? item.category.name,
        subtitle: note == null
            ? schedule
            : AppStrings.categoryAndSchedule(item.category.name, schedule),
        titleAccessory: rule.isActive
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs / 2,
                ),
                decoration: BoxDecoration(
                  color: colors.fill,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  AppStrings.paused,
                  style: AppTextStyles.caption2.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ),
        trailing: AmountText(rule.amountMinor, withSymbol: true),
        showChevron: true,
        onTap: onTap,
      ),
    );
  }
}
