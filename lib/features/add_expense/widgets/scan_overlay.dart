import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Over the amount box while a screenshot is read: a little receipt prints
/// out of a slot at the top right and keeps feeding, and a soft light
/// sweeps slowly up and down the box. When [reading] ends the light fades
/// and the receipt is torn off to the right, as a deleted expense is. Draws
/// nothing the rest of the time.
class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key, required this.reading});

  final bool reading;

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with TickerProviderStateMixin {
  /// 0 nothing out, 1 the receipt at full length.
  late final AnimationController _print = AnimationController(
    vsync: this,
    duration: AppMotion.page,
  );

  /// The printed rows moving down with the paper, one row pattern a turn.
  late final AnimationController _feed = AnimationController(
    vsync: this,
    duration: AppMotion.sweep,
  );

  /// 0 hanging from the slot, 1 torn off and gone.
  late final AnimationController _tear = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
    value: 1,
  );

  /// One pass of the light, top to bottom; it repeats back and forth.
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: AppMotion.sweep,
  );

  /// How strong the light and the slot are: they fade instead of popping.
  late final AnimationController _light = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  );

  @override
  void initState() {
    super.initState();
    if (widget.reading) _start();
  }

  @override
  void didUpdateWidget(ScanOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reading && !oldWidget.reading) _start();
    if (!widget.reading && oldWidget.reading) _finish();
  }

  void _start() {
    _tear.value = 0;
    _print.forward(from: 0);
    _feed.repeat();
    _sweep.repeat(reverse: true);
    _light.forward();
  }

  Future<void> _finish() async {
    _tear.forward(from: 0);
    await _light.reverse();
    if (mounted && !widget.reading) {
      _sweep.stop();
      _feed.stop();
    }
  }

  @override
  void dispose() {
    _print.dispose();
    _feed.dispose();
    _tear.dispose();
    _sweep.dispose();
    _light.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_print, _feed, _tear, _sweep, _light]),
        builder: (context, _) {
          final light = _light.value;
          final paper = _tear.value < 1;
          if (light == 0 && !paper) return const SizedBox.shrink();
          return LayoutBuilder(
            builder: (context, size) => Stack(
              clipBehavior: Clip.none,
              children: [
                if (light > 0) _band(size.maxHeight, light),
                if (light > 0) _slot(light),
                if (paper) _paper(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// The light: a soft band moving between above the box and below it.
  Widget _band(double height, double strength) {
    const band = AppSizes.scanSweepHeight;
    final t = Curves.easeInOut.transform(_sweep.value);
    final glow = context.colors.onAccent;
    return Positioned(
      left: 0,
      right: 0,
      top: -band + (height + band) * t,
      height: band,
      child: Opacity(
        opacity: strength,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                glow.withValues(alpha: 0),
                glow.withValues(alpha: AppSizes.scanLightEdge),
                glow.withValues(alpha: AppSizes.scanLightPeak),
                glow.withValues(alpha: AppSizes.scanLightEdge),
                glow.withValues(alpha: 0),
              ],
              stops: AppSizes.scanLightStops,
            ),
          ),
        ),
      ),
    );
  }

  static const double _top = AppSpacing.md;
  static const double _right = AppSpacing.md + 2;

  /// The slot the receipt comes out of, sunk into the box.
  Widget _slot(double strength) {
    return Positioned(
      top: _top,
      right: _right,
      child: Opacity(
        opacity: strength,
        child: Container(
          width: AppSizes.scanSlotWidth,
          height: AppSizes.scanSlotHeight,
          decoration: BoxDecoration(
            color: context.colors.accentDeep,
            borderRadius: BorderRadius.circular(AppSizes.scanSlotHeight),
          ),
        ),
      ),
    );
  }

  /// The receipt: grows out of the slot, then hangs and feeds; torn off it
  /// tips right and slides away.
  Widget _paper() {
    final length =
        AppSizes.scanPaperLength * AppMotion.enter.transform(_print.value);
    final tear = AppMotion.exit.transform(_tear.value);
    const inset = (AppSizes.scanSlotWidth - AppSizes.scanPaperWidth) / 2;
    final colors = context.colors;
    return Positioned(
      top: _top + AppSizes.scanSlotHeight / 2,
      right: _right + inset,
      child: Opacity(
        opacity: (1 - tear).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(
            AppSizes.scanTearTravel * tear,
            -AppSizes.scanTearLift * tear,
          ),
          child: Transform.rotate(
            angle: AppSizes.scanTearTilt * tear * math.pi / 180,
            alignment: Alignment.topRight,
            child: CustomPaint(
              size: Size(AppSizes.scanPaperWidth, length),
              painter: _ReceiptPainter(
                paper: colors.onAccent,
                ink: colors.labelTertiary.withValues(alpha: 0.5),
                bold: colors.accentDeep,
                shadow: colors.accentDeep,
                feed: _feed.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A strip of receipt paper with a zigzag bottom edge, printed with rows
/// (a bold total, plain lines, dashed rules) that move down by one pattern
/// as [feed] goes from 0 to 1.
class _ReceiptPainter extends CustomPainter {
  _ReceiptPainter({
    required this.paper,
    required this.ink,
    required this.bold,
    required this.shadow,
    required this.feed,
  });

  final Color paper;
  final Color ink;
  final Color bold;
  final Color shadow;
  final double feed;

  /// One pattern: bold, line, dashed, line, line.
  static const int _rows = 5;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0) return;
    const tooth = AppSizes.scanPaperTooth;
    final outline = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0);
    final bottom = math.max(0.0, size.height - tooth);
    outline.lineTo(size.width, bottom);
    const teeth = AppSizes.scanPaperTeeth;
    final step = size.width / teeth;
    for (var i = teeth; i > 0; i--) {
      outline
        ..lineTo(step * (i - 0.5), bottom + tooth)
        ..lineTo(step * (i - 1), bottom);
    }
    outline.close();
    canvas.drawShadow(outline, shadow, AppSizes.scanPaperElevation, false);
    canvas.drawPath(outline, Paint()..color = paper);

    canvas.save();
    canvas.clipPath(outline);
    const row = AppSizes.scanPaperRow;
    const pattern = row * _rows;
    const margin = AppSizes.scanPaperMargin;
    const dash = AppSizes.scanPaperDash;
    final shift = pattern * feed;
    final line = Paint()
      ..color = ink
      ..strokeWidth = AppSizes.scanPaperLine
      ..strokeCap = StrokeCap.round;
    final thick = Paint()
      ..color = bold
      ..strokeWidth = AppSizes.scanPaperBoldLine
      ..strokeCap = StrokeCap.round;
    var index = 0;
    for (var y = row - pattern + shift; y < size.height; y += row, index++) {
      final kind = index % _rows;
      final right = size.width - margin;
      if (kind == 0) {
        canvas.drawLine(
          Offset(margin, y),
          Offset(size.width * AppSizes.scanPaperBoldWidth, y),
          thick,
        );
      } else if (kind == 2) {
        for (var x = margin; x < right; x += dash * 2) {
          canvas.drawLine(
            Offset(x, y),
            Offset(math.min(x + dash, right), y),
            line,
          );
        }
      } else {
        canvas.drawLine(Offset(margin, y), Offset(right, y), line);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReceiptPainter old) =>
      old.feed != feed ||
      old.paper != paper ||
      old.ink != ink ||
      old.bold != bold;
}
