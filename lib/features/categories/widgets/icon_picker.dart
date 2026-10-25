import 'package:flutter/material.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pressable.dart';

/// Grid of the 40 registry icons on tiles. The selected tile takes the
/// category colour and grows a little, like a picked tile on the add sheet.
class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.selectedKey,
    required this.colorHex,
    required this.onSelected,
  });

  final String selectedKey;
  final String colorHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = colorFromHex(colorHex);
    return GridView.count(
      crossAxisCount: AppSizes.iconPickerColumns,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xs,
      crossAxisSpacing: AppSpacing.xs,
      children: [
        for (final key in kIconRegistry.keys)
          Semantics(
            label: key,
            selected: key == selectedKey,
            button: true,
            child: AnimatedScale(
              scale: key == selectedKey ? AppSizes.tileScale : 1,
              duration: AppMotion.slow,
              curve: AppMotion.pop,
              child: Pressable(
                onTap: () => onSelected(key),
                pressedScale: 0.88,
                child: AnimatedContainer(
                  duration: AppMotion.normal,
                  decoration: BoxDecoration(
                    color: key == selectedKey
                        ? colors.tinted(tint, onto: colors.surface)
                        : colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.tile - 4),
                    border: Border.all(
                      color: key == selectedKey ? tint : colors.surfaceElevated,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: CategoryIcon(key, size: AppSizes.iconPickerIcon),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
