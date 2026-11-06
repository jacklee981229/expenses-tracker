import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/insights.dart';

/// A category's change against the period before as a small sticker leaning
/// [AppSizes.changeTilt]: ▲ in the theme's up colour, ▼ in its down colour,
/// New in violet, each glowing faintly in its own colour; the same is
/// neutral, without a glow. A new figure pops in over the old one.
class ChangeSticker extends StatelessWidget {
  const ChangeSticker({super.key, required this.change, required this.percent});

  final SpendChange change;

  /// Percent rather than ringgit.
  final bool percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final same = change.kind == ChangeKind.same;
    final color = switch (change.kind) {
      ChangeKind.up => colors.changeUp,
      ChangeKind.down => colors.changeDown,
      ChangeKind.fresh => colors.changeNew,
      // As the share tag above it: nothing to flag.
      ChangeKind.same => colors.label,
    };
    final label = changeLabel(change, percent: percent);
    return Transform.rotate(
      angle: AppSizes.changeTilt * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs - 1,
          vertical: AppSpacing.xxs - 1,
        ),
        decoration: BoxDecoration(
          color: same
              ? colors.fill
              : Color.alphaBlend(
                  color.withValues(alpha: AppSizes.changeTint),
                  colors.stickerBase,
                ),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          boxShadow: same
              ? null
              : [
                  // Outside the sticker only, so the glow never darkens the
                  // ground under its words.
                  BoxShadow(
                    color: color.withValues(alpha: AppSizes.changeGlow),
                    blurRadius: AppSizes.changeGlowBlur,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.normal,
          switchInCurve: AppMotion.pop,
          switchOutCurve: AppMotion.exit,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Text(
            label,
            key: ValueKey(label),
            style: AppTextStyles.caption2.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
