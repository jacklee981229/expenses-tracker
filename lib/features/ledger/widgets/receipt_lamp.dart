import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/receipt_card.dart';

/// A light coming up behind a receipt, at [level] 0 to 1: a halo round its
/// edges, as if lit from behind. The receipt's own shape is cut out of the
/// light, so its translucent glass does not brighten.
class ReceiptLamp extends StatelessWidget {
  const ReceiptLamp({
    super.key,
    required this.level,
    required this.tilt,
    required this.child,
  });

  final Animation<double> level;

  /// The receipt's lean in degrees, so the cut-out leans with it.
  final double tilt;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LampPainter(
        level: level,
        tilt: tilt,
        color: context.colors.receiptLight,
      ),
      child: child,
    );
  }
}

class _LampPainter extends CustomPainter {
  _LampPainter({required this.level, required this.tilt, required this.color})
    : super(repaint: level);

  final Animation<double> level;
  final double tilt;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = level.value;
    if (t == 0) return;
    final rect = Offset.zero & size;
    final glow = rect.inflate(AppSizes.receiptLightSpread);
    final reach = glow.inflate(AppSizes.receiptLightBlur * 2);
    canvas.saveLayer(reach, Paint());
    // The torn edge's own shape, so the gaps between its teeth are no
    // brighter than the sides.
    canvas.drawPath(
      const ZigzagBorder().getOuterPath(glow),
      Paint()
        ..color = color.withValues(alpha: color.a * t)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          Shadow.convertRadiusToSigma(AppSizes.receiptLightBlur),
        ),
    );
    final centre = rect.center;
    canvas
      ..translate(centre.dx, centre.dy)
      ..rotate(tilt * math.pi / 180)
      ..translate(-centre.dx, -centre.dy)
      ..drawPath(
        const ZigzagBorder().getOuterPath(rect),
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_LampPainter old) =>
      old.level != level || old.tilt != tilt || old.color != color;
}
