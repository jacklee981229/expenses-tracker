import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_card.dart';
import 'rolling_amount.dart';

/// A raised card with a label (in [labelColor]), one big figure that rolls
/// to its value, and a line of secondary figures underneath.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.valueMinor,
    this.labelColor,
    this.leading,
    this.details = const [],
  });

  final String label;
  final int valueMinor;
  final Color? labelColor;

  /// Shown left of the label row, e.g. a category icon.
  final Widget? leading;

  /// `(label, value)` pairs shown in grey under the figure.
  final List<(String, String)> details;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leading = this.leading;
    final secondary = AppTextStyles.footnote.copyWith(
      color: colors.labelSecondary,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.callout.copyWith(
                    color: labelColor ?? colors.labelSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RollingAmount(
              valueMinor,
              style: AppTextStyles.hero.copyWith(color: colors.label),
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.xxs,
              children: [
                for (final (detailLabel, detailValue) in details)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(detailLabel, style: secondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(detailValue, style: secondary),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
