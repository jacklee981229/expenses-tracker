import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The two shadows every card wears: a thin hard edge just below it, then a
/// wide soft shadow, so cards sit up off the page instead of lying flat.
List<BoxShadow> cardShadows(AppColors colors) => [
  BoxShadow(color: colors.cardEdge, offset: const Offset(0, 2)),
  BoxShadow(
    color: colors.shadow,
    offset: const Offset(0, 14),
    blurRadius: 24,
    spreadRadius: -10,
  ),
];

BoxDecoration cardDecoration(
  AppColors colors, {
  double radius = AppRadius.card,
  Color? color,
}) => BoxDecoration(
  color: color ?? colors.surface,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: cardShadows(colors),
);

/// A raised card with an optional bold heading above its content.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.title, this.padding});

  final Widget child;
  final String? title;

  /// Around [child]. Defaults to 16 on every side the heading does not
  /// already space; pass zero sides for content that runs edge to edge.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = this.title;
    return Container(
      decoration: cardDecoration(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(color: colors.label),
              ),
            ),
          Padding(
            padding:
                padding ??
                (title == null
                    ? const EdgeInsets.all(AppSpacing.md)
                    : const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      )),
            child: child,
          ),
        ],
      ),
    );
  }
}
