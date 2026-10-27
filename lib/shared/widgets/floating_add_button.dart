import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'pressable.dart';

/// The + button: a violet gradient square with a white plus. It pops in
/// when the app opens, springs under the finger, and spins away while
/// [visible] is false (on the Analysis tab).
class FloatingAddButton extends StatelessWidget {
  const FloatingAddButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
    this.visible = true,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final button = Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Pressable(
          onTap: onPressed,
          pressedScale: 0.88,
          child: Container(
            width: AppSizes.fab,
            height: AppSizes.fab,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.fab),
              color: colors.primary,
              boxShadow: [
                BoxShadow(
                  color: colors.keyShadow,
                  offset: const Offset(0, AppSizes.keyTravel),
                ),
                BoxShadow(
                  color: colors.shadow,
                  offset: const Offset(0, 16),
                  blurRadius: 26,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              size: AppSizes.fabIcon,
              color: colors.onPrimary,
            ),
          ),
        ),
      ),
    );
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: visible ? AppMotion.normal : AppMotion.quick,
        child: AnimatedRotation(
          turns: visible ? 0 : -0.2,
          duration: visible ? AppMotion.slow : AppMotion.normal,
          curve: visible ? AppMotion.pop : AppMotion.exit,
          child: AnimatedScale(
            scale: visible ? 1 : 0.3,
            duration: visible ? AppMotion.slow : AppMotion.normal,
            curve: visible ? AppMotion.pop : AppMotion.exit,
            child: button,
          ),
        ),
      ),
    );
  }
}
