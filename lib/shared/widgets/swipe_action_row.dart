import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'pressable.dart';

class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon,
  });

  /// Shown when there is no [icon]; otherwise read out by screen readers.
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
}

/// Swipe left to reveal small rounded action buttons behind a row. The row
/// follows the finger, then springs open or shut with the fling's speed.
/// Tapping the row while it is open closes it instead of passing the tap
/// through.
class SwipeActionRow extends StatefulWidget {
  const SwipeActionRow({super.key, required this.child, required this.actions});

  final Widget child;

  /// Left to right; the last one sits at the trailing edge.
  final List<SwipeAction> actions;

  @override
  State<SwipeActionRow> createState() => _SwipeActionRowState();
}

class _SwipeActionRowState extends State<SwipeActionRow>
    with SingleTickerProviderStateMixin {
  static const double _flingVelocity = 300;
  static const double _openThreshold = 0.5;

  /// How far past fully open the row can be dragged, with resistance.
  static const double _overdrag = 0.15;

  /// 0 closed, 1 open.
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  );

  double get _extent => widget.actions.length * AppSizes.swipeActionWidth;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    var value = _controller.value - delta / _extent;
    if (value > 1) value = 1 + (value - 1) * 0.3;
    _controller.value = value.clamp(0.0, 1 + _overdrag);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final open =
        velocity < -_flingVelocity ||
        (velocity <= _flingVelocity && _controller.value > _openThreshold);
    _animate(open: open, velocity: -velocity / _extent);
  }

  void _animate({required bool open, double velocity = 0}) {
    _controller.animateWith(
      SpringSimulation(
        AppSprings.card,
        _controller.value,
        open ? 1 : 0,
        velocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final revealed = _controller.value.clamp(0.0, 2.0) * _extent;
          return Stack(
            children: [
              if (revealed > 0)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: revealed,
                  child: Row(
                    children: [
                      for (final action in widget.actions)
                        Expanded(child: _ActionButton(action, onDone: _close)),
                    ],
                  ),
                ),
              Transform.translate(
                offset: Offset(-revealed, 0),
                child: Stack(
                  children: [
                    child!,
                    if (_controller.value > 0.01)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _close,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _close() => _animate(open: false);
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.action, {required this.onDone});

  final SwipeAction action;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs / 2,
        vertical: AppSpacing.xxs,
      ),
      child: Pressable(
        onTap: () {
          onDone();
          action.onPressed();
        },
        child: Container(
          decoration: BoxDecoration(
            color: action.color,
            borderRadius: BorderRadius.circular(AppRadius.tile),
          ),
          alignment: Alignment.center,
          child: _ActionFace(action),
        ),
      ),
    );
  }
}

/// The inside of an action button: its icon, or its label when it has none.
class _ActionFace extends StatelessWidget {
  const _ActionFace(this.action);

  final SwipeAction action;

  @override
  Widget build(BuildContext context) {
    final onAccent = context.colors.onAccent;
    final icon = action.icon;
    if (icon != null) {
      return Icon(
        icon,
        size: AppSizes.swipeIcon,
        color: onAccent,
        semanticLabel: action.label,
      );
    }
    return Text(
      action.label,
      maxLines: 1,
      overflow: TextOverflow.clip,
      softWrap: false,
      style: AppTextStyles.subheadline.copyWith(color: onAccent),
    );
  }
}
