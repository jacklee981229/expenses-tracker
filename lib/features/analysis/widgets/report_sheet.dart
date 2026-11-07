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
import '../../../data/data_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/daos/analysis_dao.dart';
import '../../../data/services/picture_share.dart';
import '../../../shared/today_provider.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/circle_icon_button.dart';
import '../../../shared/widgets/colour_field.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/receipt_card.dart';
import '../analysis_providers.dart';
import 'change_sticker.dart';
import 'claude_review.dart';

/// Opens the report for the period on screen, following the filter: one
/// short printed statement whose lines print in one after another.
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
    final report = ref.watch(reportProvider);
    final selection = ref.watch(periodSelectionProvider);
    final filter = ref.watch(categoryFilterProvider);
    final period = periodLabel(selection, ref.watch(periodBoundsProvider));
    final categories = <String, ExpenseCategory>{
      for (final total
          in ref.watch(filteredCategoryTotalsProvider).valueOrNull ??
              const <CategoryTotal>[])
        total.category.id: total.category,
    };
    final word = switch (selection.period) {
      AnalysisPeriod.week => AppStrings.insightWeek,
      AnalysisPeriod.month => AppStrings.insightMonth,
      AnalysisPeriod.year || AnalysisPeriod.all => AppStrings.insightYear,
    };
    final hasKey = ref.watch(claudeKeyProvider).valueOrNull != null;

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
              children: [
                Expanded(
                  child: _Heading(
                    AppStrings.reportPeriod(period, filter.length),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // There from the start, so the heading keeps its height
                // when the report comes in.
                CircleIconButton(
                  icon: Icons.ios_share_rounded,
                  tooltip: AppStrings.shareReport,
                  onPressed: report == null
                      ? null
                      : () => shareOffscreen(
                          context,
                          _ReportPicture(
                            spots: ref.read(analysisFieldProvider),
                            period: AppStrings.reportPeriod(
                              period,
                              filter.length,
                            ),
                            printed: ref.read(todayProvider),
                            statement: _Statement(
                              report: report,
                              word: word,
                              categories: categories,
                              animate: false,
                            ),
                          ),
                          width: MediaQuery.sizeOf(context).width,
                          fileName: AppStrings.reportFileName,
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
                      categories: categories,
                      claude: hasKey
                          ? ClaudeReview(
                              count: report.count,
                              colours: {
                                for (final category in categories.values)
                                  category.name: colorFromHex(
                                    category.colorHex,
                                  ),
                              },
                            )
                          : null,
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

/// `Report` and, after it, [period] (with the filter's categories).
class _Heading extends StatelessWidget {
  const _Heading(this.period);

  final String period;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
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
            period,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.footnote.copyWith(
              color: colors.labelSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The report as a picture to share: the receipt upright on the month's
/// colour field, with the heading at its top and, at its foot, the day it
/// was printed and the app's name. Claude's take stays out: it is Claude's,
/// not the report's.
class _ReportPicture extends StatelessWidget {
  const _ReportPicture({
    required this.spots,
    required this.period,
    required this.printed,
    required this.statement,
  });

  final List<FieldSpot> spots;
  final String period;
  final DateTime printed;
  final Widget statement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foot = AppTextStyles.footnote.copyWith(color: colors.labelSecondary);
    return ColourField(
      spots: spots,
      child: Padding(
        // Room enough for the month's colours to frame the receipt.
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ReceiptCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Heading(period),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: DashedLine(),
                ),
                statement,
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: DashedLine(),
                ),
                Row(
                  children: [
                    Text(
                      AppStrings.printedOn(formatShortDate(printed)),
                      style: foot,
                    ),
                    const Spacer(),
                    Text(AppStrings.appTitle, style: foot),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The statement's lines, each printing in a little after the one above
/// unless [animate] is off: Claude's take when there is a key, a dashed
/// line, then the total with its change and the biggest categories.
class _Statement extends StatelessWidget {
  const _Statement({
    required this.report,
    required this.word,
    required this.categories,
    this.claude,
    this.animate = true,
  });

  /// False shows every line at once, as the shared picture needs.
  final bool animate;

  final Report report;

  /// Claude's part, shown only with an API key set.
  final Widget? claude;

  /// `week`, `month` or `year`, for `vs last month's RM…`.
  final String word;

  /// The period's categories by id, for each row's icon and the others'
  /// colours.
  final Map<String, ExpenseCategory> categories;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final r = report;
    final change = r.change;
    final others = r.others;
    final rows = <Widget>[
      if (claude case final claude?) ...[
        claude,
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: DashedLine(),
        ),
      ],
      Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatWithSymbol(r.totalMinor),
                style: AppTextStyles.reportTotal.copyWith(color: colors.label),
              ),
            ),
          ),
          if (change != null) ...[
            const SizedBox(width: AppSpacing.sm),
            ChangeSticker(change: change, percent: false),
          ],
        ],
      ),
      if (change != null)
        Text(
          AppStrings.reportVsLast(word, formatWithSymbol(r.totalBeforeMinor)),
          style: AppTextStyles.footnote.copyWith(color: colors.labelSecondary),
        ),
      const SizedBox(height: AppSpacing.xs),
      for (final c in r.rows)
        _Row(
          icon: switch (categories[c.id]) {
            final category? => CategoryIcon(
              category.iconKey,
              size: AppSizes.reportRowIcon,
            ),
            null => const SizedBox.square(dimension: AppSizes.reportRowIcon),
          },
          name: c.name,
          amount: formatWithSymbol(c.totalMinor),
          sticker: switch (c.change) {
            final change? => ChangeSticker(change: change, percent: false),
            null => null,
          },
        ),
      if (others != null)
        _Row(
          icon: _ColourGrid([
            for (final id in others.ids)
              switch (categories[id]) {
                final category? => colorFromHex(category.colorHex),
                null => colors.chartOther,
              },
          ]),
          name: AppStrings.reportOthers(others.count),
          amount: formatWithSymbol(others.totalMinor),
          quiet: true,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, row) in rows.indexed)
          Entrance(
            animate: animate,
            delay: AppMotion.normal + staggerDelay(index, cap: 16),
            offset: const Offset(0, -6),
            fromTilt: 0,
            duration: AppMotion.slow,
            child: row,
          ),
      ],
    );
  }
}

/// A category's row: its icon, name, amount and, in a column of their own,
/// its change sticker. The others row is [quiet] and has no sticker.
class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.name,
    required this.amount,
    this.sticker,
    this.quiet = false,
  });

  final Widget icon;
  final String name;
  final String amount;
  final Widget? sticker;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nameStyle = quiet
        ? AppTextStyles.reportOthers.copyWith(color: colors.labelSecondary)
        : AppTextStyles.rowTitle.copyWith(color: colors.label);
    final amountStyle = quiet
        ? nameStyle
        : AppTextStyles.amount.copyWith(color: colors.label);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: nameStyle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(amount, style: amountStyle),
          // The stickers keep one column, so the amounts keep one edge.
          SizedBox(
            width: AppSizes.tagColumn,
            child: Align(alignment: Alignment.centerRight, child: sticker),
          ),
        ],
      ),
    );
  }
}

/// The others' colours as a small 2×2 grid in an icon's square.
class _ColourGrid extends StatelessWidget {
  const _ColourGrid(this.colours);

  final List<Color> colours;

  @override
  Widget build(BuildContext context) {
    const gap = AppSizes.othersGridGap;
    const cell = (AppSizes.reportRowIcon - gap * 3) / 2;
    return SizedBox.square(
      dimension: AppSizes.reportRowIcon,
      child: Padding(
        padding: const EdgeInsets.all(gap),
        child: Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final colour in colours)
              Container(
                width: cell,
                height: cell,
                decoration: BoxDecoration(
                  color: colour,
                  borderRadius: BorderRadius.circular(
                    AppSizes.othersGridRadius,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
