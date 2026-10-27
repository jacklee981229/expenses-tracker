import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_bars.dart';
import '../../../shared/widgets/rolling_amount.dart';
import '../analysis_providers.dart';

/// `Last 6 months`: a pill bar per month, neutral like the total card's,
/// ending with the month the period ends in (lit), whose
/// month and total sit top right. Follows the category filter.
class TrendCard extends ConsumerWidget {
  const TrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(trendProvider).valueOrNull;
    if (months == null || months.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final last = months.last;
    final label = AppTextStyles.caption1.copyWith(color: colors.labelSecondary);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(AppStrings.trendTitle, style: label)),
              Text(formatMonthAbbrev(last.month), style: label),
              const SizedBox(width: AppSpacing.xs),
              RollingAmount(
                last.totalMinor,
                style: AppTextStyles.headline.copyWith(color: colors.label),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PillBars(
            bars: [
              for (final month in months)
                PillBar(
                  formatMonthAbbrev(month.month),
                  month.totalMinor,
                  lit: identical(month, last),
                ),
            ],
            color: colors.label,
            labelColor: colors.labelSecondary,
          ),
        ],
      ),
    );
  }
}
