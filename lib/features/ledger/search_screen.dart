import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/icon_registry.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/glow_scaffold.dart';
import 'ledger_providers.dart';
import 'widgets/day_grouped_expense_list.dart';

/// Search every month by note, category name or amount. Results use the
/// ledger's receipts, so they can be edited, copied or deleted from here.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider).trim();
    return GlowScaffold(
      appBar: AppBar(title: const Text(AppStrings.search)),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: _SearchField(),
          ),
          Expanded(
            child: results.when(
              data: (groups) {
                if (groups == null) {
                  return const EmptyState(
                    icon: UiIcons.label,
                    message: AppStrings.searchPrompt,
                  );
                }
                final count = groups.fold(0, (n, g) => n + g.items.length);
                final total = groups.fold(0, (n, g) => n + g.totalMinor);
                return DayGroupedExpenseList(
                  groups: groups,
                  scope: query,
                  header: groups.isEmpty
                      ? null
                      : _ResultCount(count: count, totalMinor: total),
                  empty: const EmptyState(
                    icon: UiIcons.receipt,
                    message: AppStrings.noSearchResults,
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, _) =>
                  EmptyState(icon: UiIcons.receipt, message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Container(
      decoration: cardDecoration(colors, radius: AppRadius.tile),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colors.labelSecondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: TextField(
              autofocus: true,
              onChanged: ref.read(searchQueryProvider.notifier).set,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.body.copyWith(color: colors.label),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: AppTextStyles.body.copyWith(
                  color: colors.labelTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.count, required this.totalMinor});

  final int count;
  final int totalMinor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        0,
      ),
      child: Text(
        AppStrings.searchResultCount(count, formatWithSymbol(totalMinor)),
        style: AppTextStyles.caption1.copyWith(
          color: context.colors.labelSecondary,
        ),
      ),
    );
  }
}
