import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/month_palette.dart';
import '../../data/database/app_database.dart';
import '../field_pulse_provider.dart';

/// One blob of the colour field: a category's colour, or none for a gap the
/// theme fills, and its size against its place's base size.
@immutable
class FieldSpot {
  const FieldSpot(this.categoryId, this.color, this.scale);

  final String? categoryId;
  final Color? color;
  final double scale;
}

/// The month's spending as field spots: its top categories in their own
/// colours, each sized a little by its share.
List<FieldSpot> fieldSpots(List<(ExpenseCategory, int)> totals) {
  final byId = {for (final (category, _) in totals) category.id: category};
  return [
    for (final blob in fieldBlobs([
      for (final (category, minor) in totals) (category.id, minor),
    ]))
      FieldSpot(blob.categoryId, switch (byId[blob.categoryId]) {
        final category? => colorFromHex(category.colorHex),
        null => null,
      }, blob.scale),
  ];
}

/// The page ground with four soft colour blobs spread evenly over it,
/// drifting slowly behind everything. [spots] colour and size them; a new
/// month's spots flow in, and the blob of a just-added expense's category
/// swells once ([fieldPulseProvider]).
///
/// Each blob is a radial gradient fading to clear, which looks blurred
/// without the cost of a blur.
class ColourField extends ConsumerStatefulWidget {
  const ColourField({super.key, required this.spots, required this.child});

  final List<FieldSpot> spots;
  final Widget child;

  @override
  ConsumerState<ColourField> createState() => _ColourFieldState();
}

class _ColourFieldState extends ConsumerState<ColourField>
    with TickerProviderStateMixin {
  // Where each blob sits, as a share of the page's width and height. All
  // four share one base size, so only the month's shares tell them apart.
  static const List<(double, double)> _places = [
    (0.22, 0.12),
    (0.86, 0.34),
    (0.16, 0.62),
    (0.80, 0.88),
  ];

  // A blob's base diameter as a share of the page's width.
  static const double _base = 1.1;

  // How far a blob drifts, as a share of its size, and how much it breathes.
  static const double _driftTravel = 0.05;
  static const double _driftGrow = 0.05;

  // A swell after a save: this much bigger at its peak.
  static const double _swell = 0.22;

  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: AppMotion.drift,
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.flow,
  );
  String? _pulsing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    ref.listen(fieldPulseProvider, (_, next) {
      if (next == null) return;
      _pulsing = next.categoryId;
      _pulse.forward(from: 0);
    });

    return ColoredBox(
      color: colors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  children: [
                    for (var i = 0; i < _places.length; i++)
                      _blob(i, box.biggest, colors),
                    // The colour eases off a little under the list.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.55, 1],
                            colors: [
                              colors.background.withValues(alpha: 0),
                              colors.background.withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  Widget _blob(int i, Size page, AppColors colors) {
    final (x, y) = _places[i];
    final spot = i < widget.spots.length ? widget.spots[i] : null;
    final categoryId = spot?.categoryId;
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: spot?.scale ?? 1 - kBlobNudge),
        duration: AppMotion.flow,
        curve: AppMotion.enter,
        builder: (context, scale, _) => TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: spot?.color ?? colors.fieldGaps[i]),
          duration: AppMotion.flow,
          curve: AppMotion.enter,
          builder: (context, color, _) => AnimatedBuilder(
            animation: Listenable.merge([_drift, _pulse]),
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_drift.value);
              // Neighbouring blobs drift opposite ways.
              final phase = i.isEven ? t : 1 - t;
              final swell = categoryId != null && categoryId == _pulsing
                  ? _swell * math.sin(math.pi * _pulse.value)
                  : 0.0;
              final radius =
                  page.width *
                  _base *
                  scale *
                  (1 + _driftGrow * phase + swell) /
                  2;
              final travel = radius * 2 * _driftTravel * phase;
              return CustomPaint(
                painter: _BlobPainter(
                  centre: Offset(
                    page.width * x + travel,
                    page.height * y + travel * 0.6,
                  ),
                  radius: radius,
                  color: color!,
                  alpha: colors.blobAlpha(color),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A soft disc: full [alpha] at the centre, still most of it halfway out,
/// clear at the edge.
class _BlobPainter extends CustomPainter {
  _BlobPainter({
    required this.centre,
    required this.radius,
    required this.color,
    required this.alpha,
  });

  final Offset centre;
  final double radius;
  final Color color;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: centre, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        stops: const [0, 0.45, 1],
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: alpha * 0.8),
          color.withValues(alpha: 0),
        ],
      ).createShader(rect);
    canvas.drawCircle(centre, radius, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) =>
      old.centre != centre ||
      old.radius != radius ||
      old.color != color ||
      old.alpha != alpha;
}
