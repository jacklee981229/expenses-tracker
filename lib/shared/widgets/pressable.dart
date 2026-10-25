import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Shrinks [child] under the finger on one spring and lets it bounce back on
/// another, so every press answers at once and a quick double tap turns
/// around smoothly instead of jumping. With a [color] it also paints that
/// behind the child, a touch darker while pressed. There is no ink ripple
/// anywhere in the app.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.color,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.pressedScale = AppSizes.pressScale,
  });

  final Widget child;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;

  /// How small the child gets while held; 1 keeps it still.
  final double pressedScale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  /// 0 at rest, 1 fully pressed; springs may overshoot either end.
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
  );
  bool _pressed = false;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
    _press.animateWith(
      SpringSimulation(
        pressed ? AppSprings.press : AppSprings.release,
        _press.value,
        pressed ? 1 : 0,
        _press.velocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final base = widget.color;
    final color = base == null
        ? null
        : _pressed
        ? Color.alphaBlend(context.colors.fill.withValues(alpha: 0.6), base)
        : base;
    Widget child = widget.child;
    if (color != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: widget.borderRadius,
        ),
        child: child,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      child: AnimatedBuilder(
        animation: _press,
        child: child,
        builder: (context, child) => Transform.scale(
          scale: 1 - (1 - widget.pressedScale) * _press.value,
          child: child,
        ),
      ),
    );
  }
}
