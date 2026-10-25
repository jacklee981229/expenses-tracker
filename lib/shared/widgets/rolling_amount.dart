import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/money.dart';

/// Money with the currency in front that counts up from zero when it first
/// appears, then from its old value to the new one whenever it changes. The
/// count runs over whole sen ([IntTween]), so no money passes through a
/// double.
class RollingAmount extends StatefulWidget {
  const RollingAmount(
    this.minor, {
    super.key,
    required this.style,
    this.textAlign,
    this.flashScope,
  });

  final int minor;
  final TextStyle style;
  final TextAlign? textAlign;

  /// When set, a change within the same scope also flashes the figure:
  /// red and bigger while it rolls up, green while it rolls down, then back
  /// to its colour. A change that comes with a new scope (another month,
  /// data still loading) only rolls.
  final Object? flashScope;

  @override
  State<RollingAmount> createState() => _RollingAmountState();
}

class _RollingAmountState extends State<RollingAmount>
    with SingleTickerProviderStateMixin {
  static const double _flashGrowth = 0.12;

  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: AppMotion.page,
    reverseDuration: AppMotion.slow,
  )..addStatusListener(_settle);
  late final Animation<double> _flashCurve = CurvedAnimation(
    parent: _flash,
    curve: AppMotion.pop,
    reverseCurve: AppMotion.exit,
  );
  bool _up = true;

  @override
  void didUpdateWidget(RollingAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    final scope = widget.flashScope;
    if (scope != null &&
        scope == oldWidget.flashScope &&
        widget.minor != oldWidget.minor) {
      _up = widget.minor > oldWidget.minor;
      _flash.forward(from: _flash.value);
    }
  }

  /// Holds the flash for the length of the roll, then lets it fade back.
  void _settle(AnimationStatus status) {
    if (status == AnimationStatus.completed) _flash.reverse();
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _flashCurve,
      builder: (context, _) {
        final t = _flashCurve.value;
        final style = t == 0
            ? widget.style
            : widget.style.copyWith(
                color: Color.lerp(
                  widget.style.color,
                  _up ? colors.heroUp : colors.heroDown,
                  t.clamp(0.0, 1.0),
                ),
              );
        return Transform.scale(
          scale: 1 + _flashGrowth * t,
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: widget.minor),
            duration: AppMotion.page,
            curve: AppMotion.enter,
            builder: (context, value, _) => Text(
              formatWithSymbol(value),
              maxLines: 1,
              textAlign: widget.textAlign,
              style: style,
            ),
          ),
        );
      },
    );
  }
}
