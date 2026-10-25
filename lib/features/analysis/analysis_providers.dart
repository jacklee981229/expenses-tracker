import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/analysis_dao.dart';
import '../../shared/today_provider.dart';
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

  void previous() => _shift(-1);

  void next() => _shift(1);

  void _shift(int step) {
    final anchor = state.anchor;
    final shifted = switch (state.period) {
      AnalysisPeriod.week => DateTime(
        anchor.year,
        anchor.month,
        anchor.day + DateTime.daysPerWeek * step,
      ),
      AnalysisPeriod.month => DateTime(anchor.year, anchor.month + step),
      AnalysisPeriod.year => DateTime(anchor.year + step, anchor.month),
      AnalysisPeriod.all => anchor,
    };
    state = PeriodSelection(state.period, shifted);
  }
}

/// Bounds of the selected period; null for All.
final periodBoundsProvider = Provider<DateBounds?>((ref) {
  final selection = ref.watch(periodSelectionProvider);
  final firstDayOfWeek = ref.watch(firstDayOfWeekProvider);
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

/// Days in the period with at least one (filtered) expense.
final periodActiveDaysProvider = StreamProvider<int>((ref) {
  final bounds = ref.watch(periodBoundsProvider);
  final filter = ref.watch(categoryFilterProvider);
  return ref
      .watch(analysisDaoProvider)
      .watchActiveDays(
        start: bounds?.start,
        end: bounds?.end,
        categoryIds: filter,
      );
});

/// The daily expense: the period total over the days with spending.
final dailyExpenseProvider = Provider<int>(
  (ref) => averageMinor(
    ref.watch(filteredTotalProvider),
    ref.watch(periodActiveDaysProvider).valueOrNull ?? 0,
  ),
);

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
