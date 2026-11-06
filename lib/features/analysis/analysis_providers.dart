import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/insights.dart';
import '../../core/utils/money.dart';
import '../../core/utils/report.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/analysis_dao.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../shared/today_provider.dart';
import '../../shared/widgets/colour_field.dart';
import '../categories/categories_providers.dart';
import '../ledger/ledger_providers.dart';
import '../settings/settings_providers.dart';

enum AnalysisPeriod { week, month, year, all }

/// Inclusive local-date bounds, `YYYY-MM-DD`.
typedef DateBounds = ({String start, String end});

@immutable
class PeriodSelection {
  const PeriodSelection(this.period, this.anchor);

  final AnalysisPeriod period;

  /// Any day inside the selected period.
  final DateTime anchor;
}

final periodSelectionProvider =
    NotifierProvider<PeriodSelectionNotifier, PeriodSelection>(
      PeriodSelectionNotifier.new,
    );

class PeriodSelectionNotifier extends Notifier<PeriodSelection> {
  @override
  PeriodSelection build() =>
      PeriodSelection(AnalysisPeriod.month, ref.read(todayProvider));

  void setPeriod(AnalysisPeriod period) =>
      state = PeriodSelection(period, state.anchor);

  void previous() => state = shiftPeriod(state, -1);

  void next() => state = shiftPeriod(state, 1);
}

/// [selection] moved by [step] periods; All stays put.
PeriodSelection shiftPeriod(PeriodSelection selection, int step) {
  final anchor = selection.anchor;
  final shifted = switch (selection.period) {
    AnalysisPeriod.week => DateTime(
      anchor.year,
      anchor.month,
      anchor.day + DateTime.daysPerWeek * step,
    ),
    AnalysisPeriod.month => DateTime(anchor.year, anchor.month + step),
    AnalysisPeriod.year => DateTime(anchor.year + step, anchor.month),
    AnalysisPeriod.all => anchor,
  };
  return PeriodSelection(selection.period, shifted);
}

/// Bounds of [selection]'s period; null for All.
DateBounds? boundsOf(PeriodSelection selection, int firstDayOfWeek) {
  final (String, String)? bounds = switch (selection.period) {
    AnalysisPeriod.week => weekBounds(
      selection.anchor,
      firstDayOfWeek: firstDayOfWeek,
    ),
    AnalysisPeriod.month => monthBounds(selection.anchor),
    AnalysisPeriod.year => yearBounds(selection.anchor),
    AnalysisPeriod.all => null,
  };
  return bounds == null ? null : (start: bounds.$1, end: bounds.$2);
}

/// Bounds of the selected period; null for All.
final periodBoundsProvider = Provider<DateBounds?>(
  (ref) => boundsOf(
    ref.watch(periodSelectionProvider),
    ref.watch(firstDayOfWeekProvider),
  ),
);

/// Bounds of the period before the selected one; null for All.
final previousPeriodBoundsProvider = Provider<DateBounds?>((ref) {
  final selection = ref.watch(periodSelectionProvider);
  if (selection.period == AnalysisPeriod.all) return null;
  return boundsOf(
    shiftPeriod(selection, -1),
    ref.watch(firstDayOfWeekProvider),
  );
});

/// `1–7 Sep 2026`, `September 2026`, `2026` or `All time`.
String periodLabel(PeriodSelection selection, DateBounds? bounds) {
  return switch (selection.period) {
    AnalysisPeriod.week when bounds != null => formatDateRange(
      bounds.start,
      bounds.end,
    ),
    AnalysisPeriod.month => formatMonthYear(selection.anchor),
    AnalysisPeriod.year => selection.anchor.year.toString(),
    _ => AppStrings.allTime,
  };
}

/// Category ids the chart and list are limited to. Empty means no filter.
final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, Set<String>>(
      CategoryFilterNotifier.new,
    );

class CategoryFilterNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) => state = state.contains(id)
      ? state.where((selected) => selected != id).toSet()
      : {...state, id};

  void clear() => state = const {};
}

/// Spending per category in the period, before the filter.
final periodCategoryTotalsProvider = StreamProvider<List<CategoryTotal>>((ref) {
  final bounds = ref.watch(periodBoundsProvider);
  return ref
      .watch(analysisDaoProvider)
      .watchCategoryTotals(start: bounds?.start, end: bounds?.end);
});

/// The colour field behind Analysis: the period on screen's top categories.
final analysisFieldProvider = Provider<List<FieldSpot>>(
  (ref) => fieldSpots([
    for (final total
        in ref.watch(periodCategoryTotalsProvider).valueOrNull ?? const [])
      (total.category, total.totalMinor),
  ]),
);

/// Spending per category in the period, limited to the filter.
final filteredCategoryTotalsProvider = StreamProvider<List<CategoryTotal>>((
  ref,
) {
  final bounds = ref.watch(periodBoundsProvider);
  final filter = ref.watch(categoryFilterProvider);
  return ref
      .watch(analysisDaoProvider)
      .watchCategoryTotals(
        start: bounds?.start,
        end: bounds?.end,
        categoryIds: filter,
      );
});

/// The period total, reflecting the filter.
final filteredTotalProvider = Provider<int>(
  (ref) => sumTotals(ref.watch(filteredCategoryTotalsProvider).valueOrNull),
);

/// The first expense's date, where All's days start.
final firstExpenseDateProvider = StreamProvider<String?>(
  (ref) => ref.watch(analysisDaoProvider).watchFirstDate(),
);

/// Calendar days of the period so far; All runs from the first expense.
/// The filter never changes it, so a category's per day compares fairly.
final periodDaysSoFarProvider = Provider<int>((ref) {
  final today = ref.watch(todayProvider);
  final bounds = ref.watch(periodBoundsProvider);
  if (bounds != null) return daysSoFar(bounds.start, bounds.end, today);
  final first = ref.watch(firstExpenseDateProvider).valueOrNull;
  return first == null ? 0 : daysSoFar(first, toLocalDateString(today), today);
});

/// The daily expense: the period total over its calendar days so far, not
/// only the days with spending, which read as a far bigger daily figure.
final dailyExpenseProvider = Provider<int>(
  (ref) => averageMinor(
    ref.watch(filteredTotalProvider),
    ref.watch(periodDaysSoFarProvider),
  ),
);

/// Spending per category in the period before, limited to the filter;
/// null for All.
final previousCategoryTotalsProvider = StreamProvider<List<CategoryTotal>?>((
  ref,
) {
  final bounds = ref.watch(previousPeriodBoundsProvider);
  if (bounds == null) return Stream.value(null);
  return ref
      .watch(analysisDaoProvider)
      .watchCategoryTotals(
        start: bounds.start,
        end: bounds.end,
        categoryIds: ref.watch(categoryFilterProvider),
      );
});

/// The period's day with the most (filtered) spending.
final biggestDayProvider = StreamProvider<DaySpend?>((ref) {
  final bounds = ref.watch(periodBoundsProvider);
  return ref
      .watch(analysisDaoProvider)
      .watchBiggestDay(
        start: bounds?.start,
        end: bounds?.end,
        categoryIds: ref.watch(categoryFilterProvider),
      );
});

/// The summary's sentences, one per tap; empty while loading or when there
/// is no spending.
final insightLoopProvider = Provider<List<Insight>>((ref) {
  final current = ref.watch(filteredCategoryTotalsProvider);
  final previous = ref.watch(previousCategoryTotalsProvider);
  final biggestDay = ref.watch(biggestDayProvider);
  if (!current.hasValue || !previous.hasValue || !biggestDay.hasValue) {
    return const [];
  }
  final before = previous.value;
  return insightLoop(
    current: _spends(current.value!),
    previous: before == null ? null : _spends(before),
    biggestDay: biggestDay.value,
  );
});

/// The period's expenses, following the filter, for the report.
final periodExpensesProvider = StreamProvider.autoDispose((ref) {
  final bounds = ref.watch(periodBoundsProvider);
  return ref
      .watch(analysisDaoProvider)
      .watchExpenses(
        start: bounds?.start,
        end: bounds?.end,
        categoryIds: ref.watch(categoryFilterProvider),
      );
});

/// The report sheet's figures; null while loading or with nothing spent.
/// Both stop watching once the sheet closes.
final reportProvider = Provider.autoDispose<Report?>((ref) {
  final expenses = ref.watch(periodExpensesProvider).valueOrNull;
  final previous = ref.watch(previousCategoryTotalsProvider);
  final kinds = ref.watch(receiptKindsProvider);
  if (expenses == null || !previous.hasValue || kinds.isLoading) return null;
  // All counts its days from the first expense: wait for it, or the per
  // day shows RM0.00 for a moment.
  if (ref.watch(periodBoundsProvider) == null &&
      !ref.watch(firstExpenseDateProvider).hasValue) {
    return null;
  }
  final before = ref.watch(previousPeriodBoundsProvider);
  return buildReport(
    current: [
      for (final item in expenses)
        (
          categoryId: item.category.id,
          categoryName: item.category.name,
          amountMinor: item.expense.amountMinor,
          localDate: item.expense.localDate,
          note: item.expense.note,
          fixed: item.expense.source == TransactionSource.recurring,
        ),
    ],
    previous: previous.value == null ? null : _spends(previous.value!),
    daysSoFar: ref.watch(periodDaysSoFarProvider),
    previousDays: before == null
        ? 0
        : calendarDaysBetween(
                parseLocalDate(before.start),
                parseLocalDate(before.end),
              ) +
              1,
    // A failed read only stops kinds counting as one.
    kindNames: [for (final kind in kinds.valueOrNull ?? []) kind.name],
  );
});

/// The named kinds of receipt page, read each time the report opens.
final receiptKindsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(receiptKindDaoProvider).getAll(),
);

List<CategorySpend> _spends(List<CategoryTotal> totals) => [
  for (final total in totals)
    (
      id: total.category.id,
      name: total.category.name,
      totalMinor: total.totalMinor,
    ),
];

/// How many weeks or months the trend card shows before the period.
const int kTrendBars = 6;

typedef TrendBar = ({String label, int totalMinor, bool lit});

/// The trend card: its title and bars, oldest first.
typedef Trend = ({String title, List<TrendBar> bars});

/// The trend card for the period on screen, following the category filter:
/// Week the [kTrendBars] weeks and Month the [kTrendBars] months ending with
/// the one on screen (never past this one), Year that year's 12 months. The
/// bar of the period on screen is lit; in a Year, this month when it is in
/// that year. Null under All, which has no card.
final trendProvider = StreamProvider<Trend?>((ref) {
  final selection = ref.watch(periodSelectionProvider);
  final today = ref.watch(todayProvider);
  final categoryIds = ref.watch(categoryFilterProvider);
  final dao = ref.watch(analysisDaoProvider);
  switch (selection.period) {
    case AnalysisPeriod.all:
      return Stream.value(null);
    case AnalysisPeriod.week:
      final firstDayOfWeek = ref.watch(firstDayOfWeekProvider);
      DateTime weekStart(DateTime day) =>
          parseLocalDate(weekBounds(day, firstDayOfWeek: firstDayOfWeek).$1);
      final thisWeek = weekStart(today);
      final shownWeek = weekStart(selection.anchor);
      final shown = shownWeek.isAfter(thisWeek) ? null : shownWeek;
      final last = shown ?? thisWeek;
      final weeks = [
        for (var back = kTrendBars - 1; back >= 0; back--)
          DateTime(
            last.year,
            last.month,
            last.day - DateTime.daysPerWeek * back,
          ),
      ];
      return dao
          .watchWeekTotals(
            start: toLocalDateString(weeks.first),
            end: toLocalDateString(
              DateTime(
                last.year,
                last.month,
                last.day + DateTime.daysPerWeek - 1,
              ),
            ),
            firstDayOfWeek: firstDayOfWeek,
            categoryIds: categoryIds,
          )
          .map(
            (totals) => (
              title: AppStrings.trendWeeksTitle,
              bars: [
                for (final week in weeks)
                  (
                    label: formatDayMonth(week),
                    totalMinor: totals[toLocalDateString(week)] ?? 0,
                    lit: week == shown,
                  ),
              ],
            ),
          );
    case AnalysisPeriod.month:
    case AnalysisPeriod.year:
      final isYear = selection.period == AnalysisPeriod.year;
      final DateTime lastMonth;
      final DateTime? lit;
      if (isYear) {
        lastMonth = DateTime(selection.anchor.year, DateTime.december);
        lit = selection.anchor.year == today.year
            ? DateTime(today.year, today.month)
            : null;
      } else {
        final thisMonth = DateTime(today.year, today.month);
        final shown = DateTime(selection.anchor.year, selection.anchor.month);
        lastMonth = shown.isAfter(thisMonth) ? thisMonth : shown;
        lit = shown.isAfter(thisMonth) ? null : shown;
      }
      final count = isYear ? DateTime.monthsPerYear : kTrendBars;
      final months = [
        for (var back = count - 1; back >= 0; back--)
          DateTime(lastMonth.year, lastMonth.month - back),
      ];
      return dao
          .watchMonthTotals(
            start: toLocalDateString(months.first),
            end: monthBounds(months.last).$2,
            categoryIds: categoryIds,
          )
          .map(
            (totals) => (
              title: isYear
                  ? AppStrings.trendYearTitle(selection.anchor.year)
                  : AppStrings.trendMonthsTitle,
              bars: [
                for (final month in months)
                  (
                    label: formatMonthAbbrev(month),
                    totalMinor: totals[toMonthKey(month)] ?? 0,
                    lit: month == lit,
                  ),
              ],
            ),
          );
  }
});

int sumTotals(List<CategoryTotal>? totals) =>
    (totals ?? const []).fold(0, (sum, total) => sum + total.totalMinor);

/// Filter chips: categories with spending in the period, plus any selected
/// category that has none (so it can still be deselected).
final filterChoicesProvider = Provider<List<ExpenseCategory>>((ref) {
  final spent = [
    for (final total
        in ref.watch(periodCategoryTotalsProvider).valueOrNull ??
            const <CategoryTotal>[])
      total.category,
  ];
  final missing = ref.watch(categoryFilterProvider).difference({
    for (final category in spent) category.id,
  });
  if (missing.isEmpty) return spent;
  final all = ref.watch(allCategoriesProvider).valueOrNull ?? const [];
  return [
    ...spent,
    for (final category in all)
      if (missing.contains(category.id)) category,
  ];
});

/// Categories below this share of the total merge into one Other slice.
const int kOtherSlicePercent = 3;

/// Only slices with at least this share get a label beside the donut; the
/// list under the chart still names every category.
const int kPieLabelMinPercent = 5;

@immutable
class PieSlice {
  const PieSlice({
    required this.categoryIds,
    required this.totalMinor,
    this.category,
  });

  /// Null for the merged Other slice.
  final ExpenseCategory? category;
  final Set<String> categoryIds;
  final int totalMinor;

  bool get isOther => category == null;
}

/// One slice per category, largest first, with categories under
/// [kOtherSlicePercent] merged into a final Other slice. The list below the
/// chart still shows them separately.
List<PieSlice> buildPieSlices(List<CategoryTotal> totals) {
  final grandTotal = sumTotals(totals);
  if (grandTotal <= 0) return const [];
  final slices = <PieSlice>[];
  final otherIds = <String>{};
  var otherTotal = 0;
  for (final total in totals) {
    if (total.totalMinor * 100 < grandTotal * kOtherSlicePercent) {
      otherIds.add(total.category.id);
      otherTotal += total.totalMinor;
    } else {
      slices.add(
        PieSlice(
          category: total.category,
          categoryIds: {total.category.id},
          totalMinor: total.totalMinor,
        ),
      );
    }
  }
  if (otherIds.isNotEmpty) {
    slices.add(PieSlice(categoryIds: otherIds, totalMinor: otherTotal));
  }
  return slices;
}

final pieSlicesProvider = Provider<List<PieSlice>>(
  (ref) => buildPieSlices(
    ref.watch(filteredCategoryTotalsProvider).valueOrNull ?? const [],
  ),
);

/// Index of the tapped pie slice. Resets whenever the slices change.
final touchedSliceProvider = NotifierProvider<TouchedSliceNotifier, int?>(
  TouchedSliceNotifier.new,
);

class TouchedSliceNotifier extends Notifier<int?> {
  @override
  int? build() {
    ref.watch(pieSlicesProvider);
    return null;
  }

  void toggle(int index) => state = state == index ? null : index;

  void clear() => state = null;
}

/// Categories of the tapped slice, highlighted in the breakdown list.
final highlightedCategoryIdsProvider = Provider<Set<String>>((ref) {
  final index = ref.watch(touchedSliceProvider);
  final slices = ref.watch(pieSlicesProvider);
  if (index == null || index < 0 || index >= slices.length) return const {};
  return slices[index].categoryIds;
});

typedef CategoryPeriod = ({String categoryId, String? start, String? end});

/// One category's expenses in a period, grouped by day (drilldown).
final categoryDetailProvider = StreamProvider.autoDispose
    .family<List<DayGroup>, CategoryPeriod>(
      (ref, args) => ref
          .watch(transactionDaoProvider)
          .watchWithCategory(
            start: args.start,
            end: args.end,
            categoryId: args.categoryId,
          )
          .map(groupByDay),
    );
