import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// One slice of the ring as drawn: angles in radians, clockwise from the
/// x axis, already short of the gaps between slices.
typedef RingArc = ({
  String key,
  Color color,
  double start,
  double sweep,
  double outer,
});

/// Half the gap between slices, as an angle. Measured along the inner edge,
/// so the gap is at least that wide all the way out; and the same whatever
/// is tapped, so tapping a slice never moves its neighbours.
double ringGap(int count) =>
    count < 2 ? 0 : AppSizes.pieSectionSpace / 2 / AppSizes.pieCenterRadius;

/// Each slice's angle in radians, in proportion to [totals] except that none
/// is narrower than [AppSizes.pieMinSliceSweep]: a sliver would read as a
/// crack in the ring, and the labels and list give the exact shares. The
/// slices at the floor take their angle from the others in proportion.
List<double> ringSweeps(List<int> raw) {
  const full = 2 * math.pi;
  if (raw.isEmpty) return const [];
  // A net-negative slice (refunds) has no size of its own: it gets the floor.
  final totals = [for (final minor in raw) math.max(0, minor)];
  final floor = math.min(
    AppSizes.pieMinSliceSweep * math.pi / 180,
    full / totals.length,
  );
  final raised = <int>{};
  var rest = full;
  var restTotal = 0;
  // Raising a slice leaves less for the rest, which can push another one
  // under the floor; repeat until none is.
  while (true) {
    rest = full - raised.length * floor;
    restTotal = 0;
    for (final (index, minor) in totals.indexed) {
      if (!raised.contains(index)) restTotal += minor;
    }
    final before = raised.length;
    for (final (index, minor) in totals.indexed) {
      // The only place money becomes a double: geometry.
      if (!raised.contains(index) &&
          (restTotal <= 0 || minor / restTotal * rest < floor)) {
        raised.add(index);
      }
    }
    if (raised.length == before) break;
  }
  return [
    for (final (index, minor) in totals.indexed)
      raised.contains(index) ? floor : minor / restTotal * rest,
  ];
}

/// [from] eased towards [to] by [t]: matching slices move, new ones open
/// from nothing and gone ones close up where they were.
List<RingArc> _lerpArcs(List<RingArc> from, List<RingArc> to, double t) {
  if (t == 1 || identical(from, to)) return to;
  final before = {for (final arc in from) arc.key: arc};
  final after = {for (final arc in to) arc.key};
  RingArc closed(RingArc arc) => (
    key: arc.key,
    color: arc.color,
    start: arc.start,
    sweep: 0,
    outer: arc.outer,
  );
  RingArc mix(RingArc a, RingArc b) => (
    key: b.key,
    color: Color.lerp(a.color, b.color, t)!,
    start: lerpDouble(a.start, b.start, t)!,
    sweep: math.max(0.0, lerpDouble(a.sweep, b.sweep, t)!),
    outer: lerpDouble(a.outer, b.outer, t)!,
  );
  return [
    for (final arc in to) mix(before[arc.key] ?? closed(arc), arc),
    for (final arc in from)
      if (!after.contains(arc.key)) mix(arc, closed(arc)),
  ];
}

/// The ring, painted by hand so slice ends can round off. Taps report the
/// slice under them, or -1 when they miss the ring.
class GlowRing extends StatefulWidget {
  const GlowRing({
    super.key,
    required this.arcs,
    required this.glow,
    required this.onTap,
  });

  final List<RingArc> arcs;
  final double glow;
  final ValueChanged<int> onTap;

  @override
  State<GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<GlowRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
    value: 1,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.pop,
  );
  late List<RingArc> _from = widget.arcs;

  @override
  void didUpdateWidget(GlowRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.arcs, widget.arcs)) return;
    // Start from where the ring is now, even mid-animation.
    _from = _lerpArcs(_from, oldWidget.arcs, _progress.value);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tap(TapUpDetails details) {
    final offset = details.localPosition - context.size!.center(Offset.zero);
    final distance = offset.distance;
    const start = AppSizes.pieStartAngle * math.pi / 180;
    final angle = (offset.direction - start) % (2 * math.pi);
    final pad = ringGap(widget.arcs.length);
    // The last slice starting before the tap; a tap in a gap counts for the
    // slice after it.
    var hit = -1;
    for (final (index, arc) in widget.arcs.indexed) {
      // The first slice starts at 0, whatever rounding says.
      if (index == 0 || (arc.start - pad - start) % (2 * math.pi) <= angle) {
        hit = index;
      }
    }
    final inRing =
        hit >= 0 &&
        distance >= AppSizes.pieCenterRadius &&
        distance <= widget.arcs[hit].outer;
    widget.onTap(inRing ? hit : -1);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapUp: _tap,
    child: CustomPaint(
      size: Size.infinite,
      painter: _RingPainter(
        progress: _progress,
        from: _from,
        to: widget.arcs,
        glow: widget.glow,
      ),
    ),
  );
}

/// Every slice's glow first, then the slices on top, so no glow spills
/// over a neighbouring slice.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.from,
    required this.to,
    required this.glow,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<RingArc> from;
  final List<RingArc> to;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final bands = [
      for (final arc in _lerpArcs(from, to, progress.value))
        // A slice thinner than this would show as a hairline crack in the
        // gap, which reads as a glitch; the list below still shows it.
        if (arc.sweep * arc.outer >= AppSizes.pieMinSliceLength)
          (arc.color, _band(center, arc)),
    ];
    for (final (color, path) in bands) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: color.a * glow)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            AppSizes.pieGlowBlur,
          ),
      );
    }
    for (final (color, path) in bands) {
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.glow != glow;
}

/// One slice as a band of the ring whose four corners round off by up to
/// [AppSizes.pieCornerRadius], less where the slice is too thin for it.
Path _band(Offset center, RingArc arc) {
  const inner = AppSizes.pieCenterRadius;
  final outer = arc.outer;
  final sweep = arc.sweep;
  final path = Path();
  if (sweep <= 0) return path;
  if (sweep >= 2 * math.pi - 1e-6) {
    // A single slice is the whole ring, with no ends to round.
    return path
      ..fillType = PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: center, radius: outer))
      ..addOval(Rect.fromCircle(center: center, radius: inner));
  }
  Offset at(double radius, double angle) =>
      center + Offset(math.cos(angle), math.sin(angle)) * radius;
  // The largest corner whose turn still fits in half the slice, at both
  // the outer and the inner edge.
  final half = sweep >= math.pi ? 1.0 : math.sin(sweep / 2);
  final corner = [
    AppSizes.pieCornerRadius,
    (outer - inner) / 2,
    outer * half / (1 + half),
    if (half < 1) inner * half / (1 - half),
  ].reduce(math.min);
  final outerTurn = math.asin(corner / (outer - corner));
  final innerTurn = math.asin(corner / (inner + corner));
  final outerSide = math.sqrt(
    (outer - corner) * (outer - corner) - corner * corner,
  );
  final innerSide = math.sqrt(
    (inner + corner) * (inner + corner) - corner * corner,
  );
  final a0 = arc.start;
  final a1 = arc.start + sweep;
  final round = Radius.circular(corner);
  final first = at(innerSide, a0);
  final outerStart = at(outerSide, a0);
  final outerEnd = at(outerSide, a1);
  final innerEnd = at(innerSide, a1);
  return path
    ..moveTo(first.dx, first.dy)
    ..lineTo(outerStart.dx, outerStart.dy)
    ..arcToPoint(at(outer, a0 + outerTurn), radius: round)
    ..arcTo(
      Rect.fromCircle(center: center, radius: outer),
      a0 + outerTurn,
      sweep - outerTurn * 2,
      false,
    )
    ..arcToPoint(outerEnd, radius: round)
    ..lineTo(innerEnd.dx, innerEnd.dy)
    ..arcToPoint(at(inner, a1 - innerTurn), radius: round)
    ..arcTo(
      Rect.fromCircle(center: center, radius: inner),
      a1 - innerTurn,
      -(sweep - innerTurn * 2),
      false,
    )
    ..arcToPoint(first, radius: round)
    ..close();
}
