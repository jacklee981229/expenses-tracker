import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// The surface of the total card and the amount box. Without [color] it is
/// the thin hero glass the colour field glows through, inside a 1px edge;
/// with one (the amount box takes its category's) it is solid inside a
/// lighter edge, with a soft shadow of that colour. A light edge runs along
/// the top of both.
class HeroSurface extends StatelessWidget {
  const HeroSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.card,
    this.color,
    this.overlay,
  });

  final Widget child;

  /// Drawn over the whole surface, padding included (the scan light).
  final Widget? overlay;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = BorderRadius.circular(radius);
    final color = this.color;
    if (color == null) return _surface(colors, shape, null);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      builder: (context, solid, _) => _surface(colors, shape, solid),
    );
  }

  Widget _surface(AppColors colors, BorderRadius shape, Color? solid) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: solid ?? colors.heroGlass,
          borderRadius: shape,
          border: Border.all(
            color: solid == null
                ? colors.glassEdge
                : Color.lerp(solid, colors.onAccent, 0.3)!,
          ),
          boxShadow: [
            if (solid != null)
              BoxShadow(
                color: solid.withValues(alpha: 0.5),
                offset: const Offset(0, 18),
                blurRadius: 36,
                spreadRadius: -18,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: shape,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: shape,
                    border: Border(
                      top: BorderSide(
                        color: colors.onAccent.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
              if (overlay case final overlay?) Positioned.fill(child: overlay),
            ],
          ),
        ),
      );
}
