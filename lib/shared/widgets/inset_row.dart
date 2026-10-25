import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'pressable.dart';

/// One row inside an `InsetGroup`: leading widget, title with an optional
/// accessory and subtitle, trailing widget, optional chevron.
class InsetRow extends StatelessWidget {
  const InsetRow({
    super.key,
    required this.title,
    this.leading,
    this.titleAccessory,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.titleColor,
    this.backgroundColor,
  });

  final String title;
  final Widget? leading;

  /// Small widget right after the title, e.g. the repeat glyph.
  final Widget? titleAccessory;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? titleColor;

  /// Defaults to the card colour.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leading = this.leading;
    final titleAccessory = this.titleAccessory;
    final subtitle = this.subtitle;
    final trailing = this.trailing;

    return Pressable(
      color: backgroundColor ?? colors.surface,
      onTap: onTap,
      pressedScale: onTap == null ? 1 : 0.98,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.rowMinHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.rowTitle.copyWith(
                              color: titleColor ?? colors.label,
                            ),
                          ),
                        ),
                        if (titleAccessory != null) ...[
                          const SizedBox(width: AppSpacing.xxs),
                          titleAccessory,
                        ],
                      ],
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.footnote.copyWith(
                            color: colors.labelSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing,
              ],
              if (showChevron) ...[
                const SizedBox(width: AppSpacing.xxs),
                Icon(Icons.chevron_right_rounded, color: colors.labelTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
