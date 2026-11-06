import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/category_colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/report.dart';
import '../../../core/utils/report_brief.dart';
import '../../../data/data_providers.dart';
import '../../../data/database/daos/analysis_dao.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/receipt_card.dart';
import '../analysis_providers.dart';
import 'claude_review.dart';

/// Opens the report for the period on screen, following the filter: one
/// printed statement whose lines print in one after another.
Future<void> showReportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.page,
      reverseDuration: AppMotion.normal,
    ),
    builder: (context) => const _ReportSheet(),
  );
}

class _ReportSheet extends ConsumerWidget {
  const _ReportSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final report = ref.watch(reportProvider);
    final selection = ref.watch(periodSelectionProvider);
    final filter = ref.watch(categoryFilterProvider);
    final period = periodLabel(selection, ref.watch(periodBoundsProvider));
    final totals = ref.watch(filteredCategoryTotalsProvider).valueOrNull;
    final colours = <String, Color>{
      for (final total in totals ?? const <CategoryTotal>[])
        total.category.id: colorFromHex(total.category.colorHex),
    };
    final word = switch (selection.period) {
      AnalysisPeriod.week => AppStrings.insightWeek,
      AnalysisPeriod.month => AppStrings.insightMonth,
      AnalysisPeriod.year || AnalysisPeriod.all => AppStrings.insightYear,
    };
    final apiKey = ref.watch(claudeKeyProvider).valueOrNull;
    final daysSoFar = ref.watch(periodDaysSoFarProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * AppSizes.reportMaxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            // The theme's drag handle already gives the top its room.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  AppStrings.report,
                  style: AppTextStyles.title2.copyWith(color: colors.label),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppStrings.reportPeriod(period, filter.length),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.footnote.copyWith(
                      color: colors.labelSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (report != null)
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
                ),
                // Upright: on a receipt this long, the day receipts' lean
                // would push its top corner out towards the edge.
                child: ReceiptCard(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: _Statement(
                      report: report,
                      word: word,
                      colours: colours,
                      claude: apiKey == null
                          ? null
                          : ClaudeReview(
                              apiKey: apiKey,
                              brief: () => reportBrief(
                                report,
                                period: period,
                                word: word,
                                daysSoFar: daysSoFar,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The statement's lines, each printing in a little after the one above.
class _Statement extends StatelessWidget {
  const _Statement({
    required this.report,
    required this.word,
    required this.colours,
    this.claude,
  });

  final Report report;

  /// The Claude section's body, shown only with an API key set.
  final Widget? claude;

  /// `week`, `month` or `year`, for "than last month".
  final String word;
  final Map<String, Color> colours;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // The words between figures are quieter, so names and figures lead.
    final text = AppTextStyles.reportLine.copyWith(
      color: colors.labelSecondary,
    );
    final strong = AppTextStyles.reportStrong.copyWith(color: colors.label);
    final label = AppTextStyles.stamp.copyWith(color: colors.sectionLabel);

    InlineSpan b(String value) => TextSpan(text: value, style: strong);
    InlineSpan plain(String value) => TextSpan(text: value);
    InlineSpan change(int percent) => TextSpan(
      text: percent > 0
          ? AppStrings.reportMore(percent)
          : AppStrings.reportLess(-percent),
      // More spending reads as bad news, as on the total card.
      style: strong.copyWith(
        color: percent > 0 ? colors.heroUp : colors.heroDown,
      ),
    );
    Widget line(String template, List<InlineSpan> parts) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text.rich(_fill(template, parts), style: text),
    );
    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: label),
    );
    const dash = Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: DashedLine(),
    );

    final r = report;
    final total = r.totalChange;
    final perDay = r.perDayChange;
    final rows = <Widget>[
      section(AppStrings.reportSpent),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          formatWithSymbol(r.totalMinor),
          style: AppTextStyles.tileValue.copyWith(color: colors.label),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      if (r.compared)
        total == 0
            ? line(AppStrings.reportSameAsLast, [plain(word)])
            : line(AppStrings.reportVsLast, [
                // The period before had spending, so a change is known.
                change(total!),
                plain(word),
                plain(formatWithSymbol(r.totalBeforeMinor)),
              ]),
      if (perDay == null)
        line(AppStrings.reportPerDay, [b(formatWithSymbol(r.perDayMinor))])
      else if (perDay == 0)
        line(AppStrings.reportPerDaySame, [
          b(formatWithSymbol(r.perDayMinor)),
          plain(word),
        ])
      else
        line(AppStrings.reportPerDayVs, [
          b(formatWithSymbol(r.perDayMinor)),
          change(perDay),
          plain(word),
          plain(formatWithSymbol(r.perDayBeforeMinor)),
        ]),
      dash,
      section(AppStrings.reportByCategory),
      for (final c in r.categories)
        _Dotted(
          color: colours[c.id],
          child: _categoryLine(c, line, b, plain, change),
        ),
      dash,
      section(AppStrings.reportFixed),
      if (r.fixedMinor == 0)
        line(AppStrings.reportNoFixed, const [])
      else
        line(AppStrings.reportFixedSplit, [
          b(formatWithSymbol(r.fixedMinor)),
          plain(
            AppStrings.shareOfMonth(
              (r.fixedMinor * 100 / r.totalMinor).round(),
            ),
          ),
          b(formatWithSymbol(r.everydayMinor)),
        ]),
      dash,
      section(AppStrings.reportHighlights),
      line(AppStrings.reportBiggestDay, [
        b(formatWeekdayDayMonth(parseLocalDate(r.biggestDay.localDate))),
        b(formatWithSymbol(r.biggestDay.totalMinor)),
      ]),
      if (r.biggestExpense.note case final note? when note.trim().isNotEmpty)
        line(AppStrings.reportBiggestExpense, [
          b(note.trim()),
          plain(r.biggestExpense.categoryName),
          b(formatWithSymbol(r.biggestExpense.amountMinor)),
        ])
      else
        line(AppStrings.reportBiggestExpenseNoNote, [
          b(formatWithSymbol(r.biggestExpense.amountMinor)),
          plain(r.biggestExpense.categoryName),
        ]),
      if (r.noSpendDays == 0)
        line(AppStrings.reportCountsEveryDay, [
          b(AppStrings.reportExpenses(r.count)),
        ])
      else
        line(AppStrings.reportCounts, [
          b(AppStrings.reportExpenses(r.count)),
          b(AppStrings.reportNoSpendDays(r.noSpendDays)),
        ]),
      if (r.notes.isNotEmpty) ...[
        dash,
        section(AppStrings.reportMostOften),
        for (final n in r.notes)
          line(AppStrings.reportNote, [
            b(n.note),
            plain(AppStrings.reportTimes(n.count)),
            plain(formatWithSymbol(n.totalMinor)),
          ]),
      ],
      if (claude case final claude?) ...[
        dash,
        section(AppStrings.reportClaude),
        claude,
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed)
          Entrance(
            delay: AppMotion.normal + staggerDelay(index, cap: 16),
            offset: const Offset(0, -6),
            fromTilt: 0,
            duration: AppMotion.slow,
            child: row,
          ),
      ],
    );
  }

  Widget _categoryLine(
    ReportCategory c,
    Widget Function(String, List<InlineSpan>) line,
    InlineSpan Function(String) b,
    InlineSpan Function(String) plain,
    InlineSpan Function(int) change,
  ) {
    final share = plain(AppStrings.shareOfMonth(c.percent));
    final amount = b(formatWithSymbol(c.totalMinor));
    final percent = c.change;
    if (!report.compared) {
      return line(AppStrings.reportCategory, [b(c.name), share, amount]);
    }
    if (percent == null) {
      return line(AppStrings.reportCategoryNew, [b(c.name), share, amount]);
    }
    if (percent == 0) {
      return line(AppStrings.reportCategorySame, [b(c.name), share, amount]);
    }
    return line(AppStrings.reportCategoryVs, [
      b(c.name),
      share,
      amount,
      change(percent),
    ]);
  }
}

/// [template] with each `{}` replaced by the next of [parts].
TextSpan _fill(String template, List<InlineSpan> parts) {
  final pieces = template.split('{}');
  assert(pieces.length == parts.length + 1, template);
  return TextSpan(
    children: [
      for (final (index, piece) in pieces.indexed) ...[
        if (piece.isNotEmpty) TextSpan(text: piece),
        if (index < parts.length) parts[index],
      ],
    ],
  );
}

/// A category's line behind a small square of its colour.
class _Dotted extends StatelessWidget {
  const _Dotted({required this.color, required this.child});

  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSizes.reportDotTop,
            right: AppSpacing.sm,
          ),
          child: Container(
            width: AppSizes.reportDot,
            height: AppSizes.reportDot,
            decoration: BoxDecoration(
              color: color ?? context.colors.chartOther,
              borderRadius: BorderRadius.circular(AppSizes.reportDot / 3),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
