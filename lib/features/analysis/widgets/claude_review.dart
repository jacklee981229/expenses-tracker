import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/report_brief.dart';
import '../../../shared/widgets/pressable.dart';
import '../analysis_providers.dart';
import 'take_reading.dart';

/// The report's lead while a Claude key is set: Claude's mark, then its take
/// on the period's expenses, asked for as the sheet opens. While Claude
/// reads its [count] expenses the place shows soft bars ([TakeReading]);
/// the take fades in where they were; when Claude didn't answer, a tap asks
/// again. [colours] are the period's category colours by name, for the
/// points' dots.
class ClaudeReview extends ConsumerWidget {
  const ClaudeReview({super.key, required this.count, required this.colours});

  final int count;
  final Map<String, Color> colours;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final request = ref.watch(takeRequestProvider);
    final asked = request == null
        ? null
        : ref.watch(reportTakeProvider(request));
    final take = asked?.valueOrNull;
    final Widget body;
    if (request == null || asked == null || asked.isLoading) {
      body = TakeReading(key: const ValueKey('reading'), count: count);
    } else if (take != null) {
      body = _Take(key: ValueKey(take), take: take, colours: colours);
    } else {
      body = Semantics(
        key: const ValueKey('failed'),
        button: true,
        child: Pressable(
          onTap: () => ref.invalidate(reportTakeProvider(request)),
          child: Text(
            AppStrings.reportClaudeFailed,
            style: AppTextStyles.callout.copyWith(color: colors.accent),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: AppSizes.takeMarkIcon,
              color: colors.accent,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              AppStrings.reportClaude,
              style: AppTextStyles.caption1.copyWith(color: colors.accent),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedSize(
          duration: AppMotion.slow,
          curve: AppMotion.enter,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: AppMotion.slow,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [...previous, if (current != null) current],
            ),
            child: body,
          ),
        ),
      ],
    );
  }
}

/// Claude's headline in big type, then its points, each behind its
/// category's colour (grey for none) with the amounts in bold.
class _Take extends StatelessWidget {
  const _Take({super.key, required this.take, required this.colours});

  final ClaudeTake take;
  final Map<String, Color> colours;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strong = AppTextStyles.takeAmount.copyWith(color: colors.label);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          take.headline,
          style: AppTextStyles.takeHeadline.copyWith(color: colors.label),
        ),
        for (final point in take.points)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: AppSizes.reportDotTop,
                    right: AppSpacing.xs,
                  ),
                  width: AppSizes.reportDot,
                  height: AppSizes.reportDot,
                  decoration: BoxDecoration(
                    color: colours[point.category] ?? colors.chartOther,
                    borderRadius: BorderRadius.circular(AppSizes.reportDot / 3),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        for (final piece in splitAmounts(point.text))
                          TextSpan(
                            text: piece.text,
                            style: piece.amount ? strong : null,
                          ),
                      ],
                    ),
                    style: AppTextStyles.takePoint.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
