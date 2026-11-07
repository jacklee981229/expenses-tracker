import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Where Claude's words will be while it reads [count] expenses: soft bars
/// the shape of a headline and its points, the violet light sweeping over
/// them as it does over a scanned screenshot (standing still under reduce
/// motion), and `Claude is reading N expenses…`.
class TakeReading extends StatefulWidget {
  const TakeReading({super.key, required this.count});

  final int count;

  @override
  State<TakeReading> createState() => _TakeReadingState();
}

class _TakeReadingState extends State<TakeReading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: AppMotion.sweep,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _sweep.stop();
    } else if (!_sweep.isAnimating) {
      _sweep.repeat();
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final light = colors.accent.withValues(alpha: AppSizes.takeSweepPeak);
    // Each bar carries its own light on top: the bars are see-through, so
    // a mask over them would dim the light with them.
    Widget bar(double width, double height) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: width,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: colors.fill,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              colors: [
                light.withValues(alpha: 0),
                light,
                light.withValues(alpha: 0),
              ],
              // Under reduce motion the light stands still in the middle.
              transform: _Slide(
                still ? 0 : Curves.easeInOut.transform(_sweep.value) * 2 - 1,
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _sweep,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final width in AppSizes.takeHeadlineBars)
                bar(width, AppSizes.takeHeadlineBar),
              for (final width in AppSizes.takePointBars)
                bar(width, AppSizes.takePointBar),
            ],
          ),
        ),
        Text(
          AppStrings.reportClaudeReading(widget.count),
          style: AppTextStyles.subheadline.copyWith(
            color: colors.labelSecondary,
          ),
        ),
      ],
    );
  }
}

/// Moves a gradient across by [shift] of its width (-1 off the left edge,
/// 1 off the right).
class _Slide extends GradientTransform {
  const _Slide(this.shift);

  final double shift;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * shift, 0, 0);
}
