import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pill_chip.dart';
import '../analysis_providers.dart';

/// Opens the category filter (the funnel button). Chips are multi-select
/// and apply immediately; Clear removes the filter.
Future<void> showCategoryFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) => const _CategoryFilterSheet(),
  );
}

class _CategoryFilterSheet extends ConsumerWidget {
  const _CategoryFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final choices = ref.watch(filterChoicesProvider);
    final selected = ref.watch(categoryFilterProvider);
    final filter = ref.read(categoryFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: selected.isEmpty ? null : filter.clear,
                child: const Text(AppStrings.clearFilter),
              ),
              const Expanded(
                child: Text(
                  AppStrings.filterCategories,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headline,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  AppStrings.done,
                  style: AppTextStyles.headline,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              AppStrings.filterHint,
              textAlign: TextAlign.center,
              style: AppTextStyles.footnote.copyWith(
                color: colors.labelSecondary,
              ),
            ),
          ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final category in choices)
                PillChip(
                  label: category.name,
                  selected: selected.contains(category.id),
                  leading: CategoryIcon(
                    category.iconKey,
                    size: AppSizes.labelIcon,
                  ),
                  onTap: () => filter.toggle(category.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
