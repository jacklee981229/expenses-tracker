import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/insights.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/icon_registry.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pressable.dart';
import '../analysis_providers.dart';
import 'report_sheet.dart';

/// One sentence about the period in a slim card shaped like the ledger's
/// backup banner, starting with the most telling one. Each tap rolls up to
/// the next sentence ([insightLoop]) and wraps round. Takes no space when
/// there is nothing to say. The round button beside it opens the report,
/// and hides with it.
class InsightLine extends ConsumerStatefulWidget {
  const InsightLine({super.key});

  @override
  ConsumerState<InsightLine> createState() => _InsightLineState();
}

class _InsightLineState extends ConsumerState<InsightLine> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // New numbers (another period, the filter, an edit) start from the top.
    ref.listen(insightLoopProvider, (_, _) => setState(() => _index = 0));
    final loop = ref.watch(insightLoopProvider);
    if (loop.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final text = _sentence(loop[_index % loop.length]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              pressedScale: 0.97,
              onTap: loop.length < 2
                  ? null
                  : () => setState(() => _index = (_index + 1) % loop.length),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.rowMinHeight,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: cardDecoration(colors, radius: AppRadius.tile),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: AppSizes.bannerIcon,
                      color: colors.accent,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ClipRect(
                        child: AnimatedSwitcher(
                          duration: AppMotion.slow,
                          switchInCurve: AppMotion.enter,
                          switchOutCurve: AppMotion.exit,
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              ...previous,
                              if (current != null) current,
                            ],
                          ),
                          // The new sentence rolls up from below; the old one
                          // leaves upwards.
                          transitionBuilder: (child, animation) {
                            final incoming = child.key == ValueKey(text);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween(
                                  begin: Offset(0, incoming ? 0.9 : -0.9),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            text,
                            key: ValueKey(text),
                            style: AppTextStyles.subheadline.copyWith(
                              color: colors.label,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const _ReportButton(),
        ],
      ),
    );
  }

  String _sentence(Insight insight) {
    final period = switch (ref.read(periodSelectionProvider).period) {
      AnalysisPeriod.week => AppStrings.insightWeek,
      AnalysisPeriod.month => AppStrings.insightMonth,
      AnalysisPeriod.year || AnalysisPeriod.all => AppStrings.insightYear,
    };
    return switch (insight) {
      CategoryChange(:final name, :final percent, up: true) =>
        AppStrings.insightMore(name, percent, period),
      CategoryChange(:final name, :final percent, up: false) =>
        AppStrings.insightLess(name, percent, period),
      NewCategory(:final name, :final totalMinor) => AppStrings.insightNew(
        name,
        formatWithSymbol(totalMinor),
        period,
      ),
      SameAsBefore(:final name) => AppStrings.insightSame(name, period),
      CategoryShare(:final name, :final totalMinor, :final percent) =>
        AppStrings.insightShare(name, formatWithSymbol(totalMinor), percent),
      BiggestDay(:final localDate, :final totalMinor) =>
        AppStrings.insightBiggestDay(
          formatDayMonth(parseLocalDate(localDate)),
          formatWithSymbol(totalMinor),
        ),
    };
  }
}

/// Opens the report: round glass, the summary line's height.
class _ReportButton extends StatelessWidget {
  const _ReportButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: AppStrings.report,
      child: Tooltip(
        message: AppStrings.report,
        child: Pressable(
          pressedScale: 0.9,
          onTap: () => showReportSheet(context),
          child: Container(
            width: AppSizes.rowMinHeight,
            height: AppSizes.rowMinHeight,
            decoration: cardDecoration(
              colors,
              radius: AppSizes.rowMinHeight / 2,
            ),
            alignment: Alignment.center,
            child: const UiIcon(UiIcons.receipt, size: AppSizes.reportIcon),
          ),
        ),
      ),
    );
  }
}
