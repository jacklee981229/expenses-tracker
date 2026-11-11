import 'package:flutter/material.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// A person's initial on a round tint, coloured by their place in the
/// group's order, so each friend keeps one colour across the page, the
/// sheets and the shared picture.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    required this.index,
    this.size = AppSizes.personAvatar,
  });

  final String name;

  /// Place in the group's order.
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = name.trim().isEmpty
        ? ''
        : name.trim().characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // The amount box's mix: bright enough to tell people apart, and
        // its text colour keeps 4.5:1 on every swatch (theme_contrast_test).
        color: colors.box(
          colorFromHex(kPersonColorHexes[index % kPersonColorHexes.length]),
        ),
      ),
      child: Text(
        initial,
        style: AppTextStyles.footnote.copyWith(
          color: colors.onHero,
          fontWeight: FontWeight.w700,
          fontSize: size * AppSizes.personInitialFactor,
          height: 1,
        ),
      ),
    );
  }
}
