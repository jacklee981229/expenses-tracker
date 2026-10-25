import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

/// A paper receipt: rounded top corners, a torn zigzag bottom edge, the
/// card shadows, and a slight lean of [tilt] degrees.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({super.key, required this.child, this.tilt = 0});

  final Widget child;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const shape = ZigzagBorder();
    return Transform.rotate(
      angle: tilt * math.pi / 180,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.surface,
          shape: shape,
          shadows: cardShadows(colors),
        ),
        child: ClipPath(
          clipper: const ShapeBorderClipper(shape: shape),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.receiptTooth / 2),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Rounded top corners and a zigzag bottom, one tooth every
/// [AppSizes.receiptTooth].
class ZigzagBorder extends ShapeBorder {
  const ZigzagBorder();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const radius = AppRadius.receipt;
    const tooth = AppSizes.receiptTooth;
    const depth = tooth / 2;
    final teeth = math.max(1, (rect.width / tooth).round());
    final step = rect.width / teeth;
    final bottom = rect.bottom;
    final path = Path()
      ..moveTo(rect.left, rect.top + radius)
      ..arcToPoint(
        Offset(rect.left + radius, rect.top),
        radius: const Radius.circular(radius),
      )
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(rect.right, bottom - depth);
    for (var i = teeth; i > 0; i--) {
      final x = rect.left + step * i;
      path
        ..lineTo(x - step / 2, bottom)
        ..lineTo(x - step, bottom - depth);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

/// A dashed hairline, like the perforations on a receipt.
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    this.color,
    this.thickness = AppSizes.dashThickness,
  });

  final Color? color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, thickness),
      painter: _DashPainter(color ?? context.colors.separator, thickness),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.thickness);

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    for (
      var x = 0.0;
      x < size.width;
      x += AppSizes.dashLength + AppSizes.dashGap
    ) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + AppSizes.dashLength, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.thickness != thickness;
}
