import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A page header: a large bold title, with optional actions on the right,
/// level with the title's baseline.
class LargeTitle extends StatelessWidget {
  const LargeTitle(
    this.title, {
    super.key,
    this.trailing,
    this.bottomGap = AppSpacing.md,
  });

  /// The title itself; a widget so it can animate (the ledger's month).
  final Widget title;
  final Widget? trailing;

  /// Space under the title; the ledger keeps it tighter.
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trailing = this.trailing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.md,
        bottomGap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: DefaultTextStyle.merge(
              style: AppTextStyles.largeTitle.copyWith(color: colors.label),
              // A long title (or large system text) shrinks to one line.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: title,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
