import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../shared/widgets/entrance.dart';
import '../analysis_providers.dart';

/// Outer edge of a tapped slice, the furthest the ring reaches.
const double _ringEdge = AppSizes.pieCenterRadius + AppSizes.pieTouchedRadius;

/// Where every leader line bends. Fixed, so tapping a slice never moves the
/// labels.
const double _elbowRadius = _ringEdge + AppSizes.pieLabelReach;

/// Spending per category as a donut, largest first: the bigger slices have
/// their share and name outside the ring on a leader line in the slice's
/// colour, and the hole is a raised disc reading "Expense" over the period
/// total. Slices are shaded light to dark and the ring casts a soft shadow,
/// so it reads as solid rather than flat. It swings in when shown; tapping a
/// slice pushes it out and highlights its category below.
class SpendPieChart extends ConsumerWidget {
  const SpendPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final slices = ref.watch(pieSlicesProvider);
    final touched = ref.watch(touchedSliceProvider);
    final total = ref.watch(filteredTotalProvider);
    final layout = _layoutLabels(slices, total, colors.chartOther);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final center = Offset(width / 2, layout.centerY);
        return SizedBox(
          height: layout.height,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: center.dy - _ringEdge,
                height: _ringEdge * 2,
                child: Entrance(
                  offset: Offset.zero,
                  fromTilt: -30,
                  fromScale: 0.6,
                  duration: AppMotion.page,
                  curve: AppMotion.pop,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        child: CustomPaint(
                          size: const Size.square(_ringEdge * 2),
                          painter: _RingShadowPainter(colors.shadow),
                        ),
                      ),
                      PieChart(
                        duration: AppMotion.slow,
                        curve: AppMotion.pop,
                        PieChartData(
                          startDegreeOffset: AppSizes.pieStartAngle,
                          centerSpaceRadius: AppSizes.pieCenterRadius,
                          sectionsSpace: AppSizes.pieSectionSpace,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (event is! FlTapUpEvent) return;
                              final slices = ref.read(
                                touchedSliceProvider.notifier,
                              );
                              // The index is -1 when the tap misses every slice.
                              final index =
                                  response
                                      ?.touchedSection
                                      ?.touchedSectionIndex ??
                                  -1;
                              if (index < 0) {
                                slices.clear();
                              } else {
                                slices.toggle(index);
                              }
                            },
                          ),
                          sections: [
                            for (final (index, slice) in slices.indexed)
                              PieChartSectionData(
                                // The only place money becomes a double: geometry.
                                value: slice.totalMinor.toDouble(),
                                color: _sliceColor(slice, colors.chartOther),
                                gradient: _sliceShading(
                                  _sliceColor(slice, colors.chartOther),
                                ),
                                radius: index == touched
                                    ? AppSizes.pieTouchedRadius
                                    : AppSizes.pieRadius,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      IgnorePointer(child: _CentreTotal(total: total)),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Entrance(
                    delay: AppMotion.page,
                    offset: Offset.zero,
                    fromTilt: 0,
                    child: CustomPaint(
                      painter: _ChartOverlayPainter(
                        labels: layout.labels,
                        slices: slices,
                        touched: touched,
                        total: total,
                        center: center,
                        shade: colors.chartShade,
                      ),
                    ),
                  ),
                ),
              ),
              for (final (index, label) in layout.labels.indexed)
                _LabelText(
                  label: label,
                  center: center,
                  delay: AppMotion.page + staggerDelay(index),
                ),
            ],
          ),
        );
      },
    );
  }
}

Color _sliceColor(PieSlice slice, Color other) =>
    slice.isOther ? other : colorFromHex(slice.category!.colorHex);

/// Lit from the top left: a touch lighter there, a touch deeper opposite.
Gradient _sliceShading(Color color) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.lerp(color, Colors.white, 0.22)!,
    Color.lerp(color, Colors.black, 0.12)!,
  ],
);

/// The ring's soft shadow, dropped below it.
class _RingShadowPainter extends CustomPainter {
  _RingShadowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(const Offset(0, AppSizes.pieShadowOffset));
    const radius = AppSizes.pieCenterRadius + AppSizes.pieRadius / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.pieRadius
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          AppSizes.pieShadowBlur,
        ),
    );
  }

  @override
  bool shouldRepaint(_RingShadowPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// "Expense" over the period total, sized to the hole.
class _CentreTotal extends StatelessWidget {
  const _CentreTotal({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: (AppSizes.pieCenterRadius - AppSpacing.xxs) * 2,
      height: (AppSizes.pieCenterRadius - AppSpacing.xxs) * 2,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            offset: const Offset(0, 8),
            blurRadius: 18,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.expenseStat,
            style: AppTextStyles.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatWithSymbol(total),
              maxLines: 1,
              style: AppTextStyles.chartCentre.copyWith(color: colors.label),
            ),
          ),
        ],
      ),
    );
  }
}

/// One slice's label, placed relative to the ring's centre: a leader line
/// out from the slice to an elbow, then across to the text.
class _SliceLabel {
  _SliceLabel({
    required this.index,
    required this.direction,
    required this.color,
    required this.share,
    required this.name,
  }) : wanted = direction.dy * _elbowRadius;

  /// The slice's position in the chart, to find its current outer edge.
  final int index;

  /// Unit vector from the centre through the middle of the slice.
  final Offset direction;

  /// The slice's colour, which its leader line takes.
  final Color color;
  final String share;
  final String name;

  /// Level with the elbow: where the text sits when nothing is in the way.
  final double wanted;

  /// The text's vertical centre after spreading apart from its neighbours.
  double y = 0;

  /// Horizontal distance from the centre to where the leader line ends.
  double lineEnd = 0;

  bool get onRight => direction.dx >= 0;
}

typedef _ChartLayout = ({
  double height,
  double centerY,
  List<_SliceLabel> labels,
});

_ChartLayout _layoutLabels(List<PieSlice> slices, int total, Color other) {
  final labels = <_SliceLabel>[];
  if (total > 0) {
    const start = AppSizes.pieStartAngle * math.pi / 180;
    var before = 0;
    for (final (index, slice) in slices.indexed) {
      // Angle of the slice's middle, from integer sen until this division.
      final middle = (before * 2 + slice.totalMinor) / (total * 2);
      before += slice.totalMinor;
      if (slice.totalMinor * 100 < total * kPieLabelMinPercent) continue;
      final angle = start + middle * 2 * math.pi;
      labels.add(
        _SliceLabel(
          index: index,
          direction: Offset(math.cos(angle), math.sin(angle)),
          color: _sliceColor(slice, other),
          share: formatShare(slice.totalMinor, total, trimZeros: true),
          name: slice.isOther ? AppStrings.otherSlice : slice.category!.name,
        ),
      );
    }
  }
  _spread([
    for (final label in labels)
      if (label.onRight) label,
  ]);
  _spread([
    for (final label in labels)
      if (!label.onRight) label,
  ]);

  // Tall enough for the ring and every label, with the ring wherever the
  // labels leave room for it.
  const half = AppSizes.pieLabelGap / 2;
  var above = _ringEdge + AppSpacing.xs;
  var below = _ringEdge + AppSpacing.xs;
  for (final label in labels) {
    label.lineEnd = _lineEnd(label);
    above = math.max(above, half - label.y);
    below = math.max(below, label.y + half);
  }
  return (height: above + below, centerY: above, labels: labels);
}

/// Spreads one side's labels so their text never overlaps. Labels that
/// would collide form a block, [AppSizes.pieLabelGap] apart, centred on
/// where they want to be, so a crowd of slices fans out both up and down
/// instead of piling onto the slices below it.
void _spread(List<_SliceLabel> labels) {
  labels.sort((a, b) => a.wanted.compareTo(b.wanted));
  final blocks = <List<_SliceLabel>>[];
  for (final label in labels) {
    blocks.add([label]);
    _centreBlock(blocks.last);
    while (blocks.length > 1) {
      final above = blocks[blocks.length - 2];
      final below = blocks.last;
      if (below.first.y - above.last.y >= AppSizes.pieLabelGap) break;
      above.addAll(below);
      blocks.removeLast();
      _centreBlock(above);
    }
  }
}

void _centreBlock(List<_SliceLabel> block) {
  var sum = 0.0;
  for (final label in block) {
    sum += label.wanted;
  }
  final first =
      sum / block.length - AppSizes.pieLabelGap * (block.length - 1) / 2;
  for (final (index, label) in block.indexed) {
    label.y = first + AppSizes.pieLabelGap * index;
  }
}

/// How far out the leader line ends: [AppSizes.pieLabelElbow] past the
/// elbow, or further when the ring is wider than that beside the text, so
/// the labels follow the ring's curve without covering it.
double _lineEnd(_SliceLabel label) {
  // The ring's half width level with the text's nearest edge.
  final dy = math.max(0.0, label.y.abs() - AppSizes.pieLabelGap / 2);
  final ringHalfWidth = dy < _ringEdge
      ? math.sqrt(_ringEdge * _ringEdge - dy * dy)
      : 0.0;
  return math.max(
    label.direction.dx.abs() * _elbowRadius + AppSizes.pieLabelElbow,
    ringHalfWidth + AppSizes.pieLabelReach,
  );
}

/// Shades the ring's inner edge, then draws each label's leader line in its
/// slice's colour.
class _ChartOverlayPainter extends CustomPainter {
  _ChartOverlayPainter({
    required this.labels,
    required this.slices,
    required this.touched,
    required this.total,
    required this.center,
    required this.shade,
  });

  final List<_SliceLabel> labels;
  final List<PieSlice> slices;
  final int? touched;
  final int total;
  final Offset center;
  final Color shade;

  @override
  void paint(Canvas canvas, Size size) {
    if (total > 0) {
      canvas.drawCircle(
        center,
        AppSizes.pieCenterRadius + AppSizes.pieShadeWidth / 2,
        Paint()
          ..color = shade
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppSizes.pieShadeWidth,
      );
    }
    for (final label in labels) {
      final outer =
          AppSizes.pieCenterRadius +
          (label.index == touched
              ? AppSizes.pieTouchedRadius
              : AppSizes.pieRadius);
      final anchor = center + label.direction * outer;
      final elbow = center + label.direction * _elbowRadius;
      final end = center.dx + (label.onRight ? label.lineEnd : -label.lineEnd);
      canvas.drawPath(
        Path()
          ..moveTo(anchor.dx, anchor.dy)
          ..lineTo(elbow.dx, elbow.dy)
          ..lineTo(end, center.dy + label.y),
        Paint()
          ..color = label.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppSizes.pieLineWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartOverlayPainter oldDelegate) =>
      oldDelegate.labels != labels ||
      oldDelegate.slices != slices ||
      oldDelegate.touched != touched ||
      oldDelegate.total != total ||
      oldDelegate.center != center ||
      oldDelegate.shade != shade;
}

/// The share over the name, centred on the end of the leader line.
class _LabelText extends StatelessWidget {
  const _LabelText({
    required this.label,
    required this.center,
    required this.delay,
  });

  final _SliceLabel label;
  final Offset center;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = AppTextStyles.chartLabel.copyWith(color: colors.label);
    final nameStyle = AppTextStyles.chartName.copyWith(
      color: colors.labelSecondary,
    );
    const inset = AppSpacing.xxs;
    const gap = AppSizes.pieLabelGap;
    final available = center.dx - label.lineEnd - inset;
    final width = math.max(0.0, math.min(AppSizes.pieLabelWidth, available));
    final align = label.onRight ? TextAlign.left : TextAlign.right;
    return Positioned(
      left: label.onRight
          ? center.dx + label.lineEnd + inset
          : center.dx - label.lineEnd - inset - width,
      top: center.dy + label.y - gap / 2,
      width: width,
      height: gap,
      child: IgnorePointer(
        child: Entrance(
          delay: delay,
          offset: Offset(label.onRight ? -8 : 8, 0),
          fromTilt: 0,
          // Large system text shrinks to the label's box instead of
          // spilling out of it.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: label.onRight
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: label.onRight
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(label.share, textAlign: align, maxLines: 1, style: style),
                Text(
                  label.name,
                  textAlign: align,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
