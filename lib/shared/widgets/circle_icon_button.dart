import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'category_avatar.dart';
import 'pressable.dart';

/// A small rounded-square header button: month and period arrows, settings,
/// the filter, a sheet's close button. It shows a line [icon] or a picture
/// from the icon set ([asset]), springs under the finger, and keeps a tap
/// area of at least [AppSizes.tapTarget].
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.asset,
    this.size = AppSizes.navButton,
    this.iconSize = AppSizes.navIcon,
    this.background,
    this.foreground,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final String? asset;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  /// Defaults to the translucent header button colour.
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asset = this.asset;
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: Opacity(
          opacity: enabled ? 1 : AppSizes.disabledOpacity,
          child: Pressable(
            onTap: onPressed,
            pressedScale: 0.88,
            child: SizedBox(
              width: AppSizes.tapTarget > size ? AppSizes.tapTarget : size,
              height: AppSizes.tapTarget > size ? AppSizes.tapTarget : size,
              child: Center(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: background ?? colors.navButton,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    border: colors.isDark
                        ? Border.all(color: colors.cardEdge)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        offset: const Offset(0, 8),
                        blurRadius: 16,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: asset != null
                      ? UiIcon(asset, size: iconSize)
                      : Icon(
                          icon,
                          size: iconSize,
                          color: foreground ?? colors.label,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
