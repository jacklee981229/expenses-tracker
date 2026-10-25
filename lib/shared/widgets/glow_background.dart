import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The page colour with three soft colour glows drifting slowly behind
/// everything. Each glow is a radial gradient fading to clear, which looks
/// blurred without the cost of a blur.
class GlowBackground extends StatefulWidget {
  const GlowBackground({super.key, required this.child});

  final Widget child;

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  // Slow on purpose: the page should feel alive, not busy.
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 11),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _drift,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(_drift.value);
                  return Stack(
                    children: [
                      _Glow(
                        color: colors.glowA,
                        size: 380,
                        left: -150 + 30 * t,
                        top: -140 + 24 * t,
                      ),
                      _Glow(
                        color: colors.glowB,
                        size: 340,
                        right: -150 + 26 * (1 - t),
                        top: 40 + 22 * (1 - t),
                      ),
                      _Glow(
                        color: colors.glowC,
                        size: 320,
                        left: 40 + 30 * t,
                        top: 330 + 20 * t,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.color,
    required this.size,
    required this.top,
    this.left,
    this.right,
  });

  final Color color;
  final double size;
  final double top;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
