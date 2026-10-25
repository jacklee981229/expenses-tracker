import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A page header: a small grey [kicker] over a large bold title, with
/// optional actions on the right, level with the title's baseline.
class LargeTitle extends StatelessWidget {
  const LargeTitle(this.title, {super.key, this.kicker, this.trailing});

  /// The title itself; a widget so it can animate (the ledger's month).
  final Widget title;
  final String? kicker;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final kicker = this.kicker;
    final trailing = this.trailing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kicker != null)
                  Text(
                    kicker,
                    style: AppTextStyles.kicker.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                DefaultTextStyle.merge(
                  style: AppTextStyles.largeTitle.copyWith(color: colors.label),
                  // A long title (or large system text) shrinks to one line.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: title,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
