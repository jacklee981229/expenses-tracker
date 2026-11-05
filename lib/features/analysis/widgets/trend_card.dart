import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pill_bars.dart';
import '../../../shared/widgets/rolling_amount.dart';
import '../analysis_providers.dart';

/// A pill bar per week or month ([trendProvider]), neutral like the total
/// card's, with the period on screen lit and its label and total top right.
/// Follows the category filter. Nothing under All.
class TrendCard extends ConsumerWidget {
  const TrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(trendProvider).valueOrNull;
    if (trend == null || trend.bars.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final lit = trend.bars.where((bar) => bar.lit).firstOrNull;
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
              Expanded(child: Text(trend.title, style: label)),
              if (lit != null) ...[
                Text(lit.label, style: label),
                const SizedBox(width: AppSpacing.xs),
                RollingAmount(
                  lit.totalMinor,
                  style: AppTextStyles.headline.copyWith(color: colors.label),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          PillBars(
            bars: [
              for (final bar in trend.bars)
                PillBar(bar.label, bar.totalMinor, lit: bar.lit),
            ],
            color: colors.label,
            labelColor: colors.labelSecondary,
          ),
        ],
      ),
    );
  }
}
