import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// The violet surface of the total card and the amount box: a violet base
/// lit by a lilac glow from the top right and a pink one from the bottom
/// left, a thin light edge along the top, and a coloured shadow.
class HeroSurface extends StatelessWidget {
  const HeroSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.heroBase,
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: colors.accentDeep,
            offset: const Offset(0, AppSizes.keyTravel),
          ),
          BoxShadow(
            color: colors.heroBase.withValues(alpha: 0.6),
            offset: const Offset(0, 22),
            blurRadius: 40,
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
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.2,
                    colors: [
                      colors.heroGlowA,
                      colors.heroGlowA.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.55],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomLeft,
                    radius: 0.9,
                    colors: [
                      colors.heroGlowB,
                      colors.heroGlowB.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.6],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: shape,
                  border: Border(
                    top: BorderSide(
                      color: colors.onAccent.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
