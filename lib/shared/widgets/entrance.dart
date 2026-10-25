import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Plays [child] in once when first built: it fades up from [offset] below
/// (or beside) where it ends, leaning [fromTilt] degrees, after [delay].
/// Give lists a stagger by growing the delay per item.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 22),
    this.fromTilt = -2,
    this.fromScale = 1,
    this.duration = AppMotion.page,
    this.curve = AppMotion.enter,
    this.builderOverride,
    this.animate = true,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final double fromTilt;
  final double fromScale;
  final Duration duration;
  final Curve curve;

  /// Replaces the fade, slide, tilt and scale with a transform of its own,
  /// given the curved progress (0 to 1, past 1 when the curve overshoots).
  final Widget Function(double t, Widget child)? builderOverride;

  /// False shows the child in place at once, e.g. a receipt that already
  /// came in and is only scrolling back into view.
  final bool animate;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.animate ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = widget.curve.transform(_controller.value);
        final override = widget.builderOverride;
        if (override != null) return override(t, child!);
        final rest = 1 - t;
        return Opacity(
          opacity: _controller.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: widget.offset * rest,
            child: Transform.rotate(
              angle: widget.fromTilt * rest * math.pi / 180,
              child: Transform.scale(
                scale: widget.fromScale + (1 - widget.fromScale) * t,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The delay for the [index]th item of a staggered list, capped so long
/// lists do not keep the last rows waiting.
Duration staggerDelay(int index, {int cap = 8}) =>
    AppMotion.stagger * math.min(index, cap);
