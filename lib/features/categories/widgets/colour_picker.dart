import 'package:flutter/material.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/pressable.dart';

/// The 16 category colour swatches.
class ColourPicker extends StatelessWidget {
  const ColourPicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
  });

  final String selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.count(
      crossAxisCount: AppSizes.colourPickerColumns,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      children: [
        for (final hex in kCategoryColorHexes)
          Semantics(
            label: hex,
            selected: hex == selectedHex,
            button: true,
            child: Pressable(
              onTap: () => onSelected(hex),
              pressedScale: 0.85,
              child: AnimatedContainer(
                duration: AppMotion.normal,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorFromHex(hex),
                  boxShadow: hex == selectedHex
                      ? [
                          BoxShadow(
                            color: colorFromHex(hex).withValues(alpha: 0.7),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: AnimatedScale(
                  scale: hex == selectedHex ? 1 : 0,
                  duration: AppMotion.slow,
                  curve: AppMotion.pop,
                  child: Icon(
                    Icons.check_rounded,
                    size: AppSizes.swatchCheck,
                    color: colors.onAccent,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
