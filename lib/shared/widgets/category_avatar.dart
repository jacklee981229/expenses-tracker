import 'package:flutter/material.dart';

import '../../core/constants/category_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/icon_registry.dart';
import '../../data/database/app_database.dart';

/// A category's icon: its 3D picture on a rounded square tinted with the
/// category colour.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.iconKey,
    required this.colorHex,
    this.size = AppSizes.avatar,
    this.onto,
  });

  CategoryAvatar.of(
    ExpenseCategory category, {
    super.key,
    this.size = AppSizes.avatar,
    this.onto,
  }) : iconKey = category.iconKey,
       colorHex = category.colorHex;

  final String iconKey;
  final String colorHex;
  final double size;

  /// The colour the tile sits on, so its tint matches; the card by default.
  final Color? onto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.tinted(colorFromHex(colorHex), onto: onto),
        borderRadius: BorderRadius.circular(size * AppSizes.avatarRadiusFactor),
      ),
      child: CategoryIcon(iconKey, size: size * AppSizes.avatarIconFactor),
    );
  }
}

/// The bare 3D picture for an icon key.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.iconKey, {super.key, required this.size});

  final String iconKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconAssetForKey(iconKey),
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// An interface picture from the same set, e.g. [UiIcons.gear].
class UiIcon extends StatelessWidget {
  const UiIcon(this.asset, {super.key, required this.size, this.label});

  final String asset;
  final double size;

  /// Read by screen readers; the picture is decorative without it.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: label,
      excludeFromSemantics: label == null,
    );
  }
}
