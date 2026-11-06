import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'pressable.dart';

/// A rounded chip: [color] (or the fill colour) unselected, accent when
/// selected, springing under the finger.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.leading,
    this.color,
    this.labelColor,
    this.selectedColor,
    this.selectedLabelColor,
    this.small = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? leading;

  /// The unselected fill, when the chip sits on a colour the default fill
  /// would not stand out from.
  final Color? color;
  final Color? labelColor;
  final Color? selectedColor;
  final Color? selectedLabelColor;

  /// A quieter chip: lower, smaller text, a soft shadow under it.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leading = this.leading;
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.92,
      // No alignment: the chip is as wide as its label, even in a Wrap.
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.enter,
        height: small ? AppSizes.noteChipHeight : AppSizes.chipHeight,
        padding: EdgeInsets.symmetric(
          horizontal: small ? AppSpacing.sm : AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor ?? colors.accent
              : color ?? colors.fill,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: small
              ? [
                  BoxShadow(
                    color: colors.shadow,
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: AppSpacing.xxs),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.chipLabelMaxWidth,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (small ? AppTextStyles.footnote : AppTextStyles.subheadline)
                        .copyWith(
                          color: selected
                              ? selectedLabelColor ?? colors.onAccent
                              : labelColor ?? colors.labelSecondary,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
