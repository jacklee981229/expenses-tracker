import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/utils/date_utils.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/transaction_dao.dart';
import '../../shared/today_provider.dart';
import '../settings/settings_providers.dart';

/// First day of the month shown in the ledger.
final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(
  SelectedMonthNotifier.new,
);

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final today = ref.read(todayProvider);
    return DateTime(today.year, today.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() => state = DateTime(state.year, state.month + 1);

  void select(DateTime month) => state = DateTime(month.year, month.month);
}

final monthExpensesProvider = StreamProvider<List<ExpenseWithCategory>>((ref) {
  final (start, end) = monthBounds(ref.watch(selectedMonthProvider));
  return ref
      .watch(transactionDaoProvider)
      .watchWithCategory(start: start, end: end);
});

final monthTotalProvider = Provider<int>(
  (ref) => sumExpenses(ref.watch(monthExpensesProvider).valueOrNull ?? []),
);

/// The category the ledger list is narrowed to from the drawer, or null for
/// all. Clears when the month changes.
final ledgerCategoryFilterProvider =
    NotifierProvider<LedgerCategoryFilterNotifier, String?>(
      LedgerCategoryFilterNotifier.new,
    );

class LedgerCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(selectedMonthProvider);
    return null;
  }

  void toggle(String categoryId) =>
      state = state == categoryId ? null : categoryId;

  void clear() => state = null;
}

/// The drawer's category while it still has spending this month, else null
/// (deleting a category's last expense drops the filter).
final effectiveLedgerFilterProvider = Provider<String?>((ref) {
  final filter = ref.watch(ledgerCategoryFilterProvider);
  if (filter == null) return null;
  final totals = ref.watch(monthCategoryTotalsProvider);
  return totals.any((total) => total.category.id == filter) ? filter : null;
});

/// The month's days, newest first, narrowed to the drawer's category.
final monthDayGroupsProvider = Provider<AsyncValue<List<DayGroup>>>((ref) {
  final filter = ref.watch(effectiveLedgerFilterProvider);
  return ref
      .watch(monthExpensesProvider)
      .whenData(
        (items) => groupByDay(
          filter == null
              ? items
              : [
                  for (final item in items)
                    if (item.category.id == filter) item,
                ],
        ),
      );
});

/// What the month spent per category, largest first: the drawer's tags.
final monthCategoryTotalsProvider = Provider<List<LedgerCategoryTotal>>((ref) {
  final items = ref.watch(monthExpensesProvider).valueOrNull ?? const [];
  final byId = <String, LedgerCategoryTotal>{};
  for (final item in items) {
    final previous = byId[item.category.id];
    byId[item.category.id] = LedgerCategoryTotal(
      item.category,
      (previous?.totalMinor ?? 0) + item.expense.amountMinor,
    );
  }
  return byId.values.toList()
    ..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
});

@immutable
class LedgerCategoryTotal {
  const LedgerCategoryTotal(this.category, this.totalMinor);

  final ExpenseCategory category;
  final int totalMinor;
}

/// Spending on each of the last seven days, oldest first, ending today:
/// the bars on the total card.
final lastSevenDaysProvider = StreamProvider<List<DayTotal>>((ref) {
  final today = ref.watch(todayProvider);
  final days = [
    for (var back = DateTime.daysPerWeek - 1; back >= 0; back--)
      DateTime(today.year, today.month, today.day - back),
  ];
  return ref
      .watch(transactionDaoProvider)
      .watchWithCategory(
        start: toLocalDateString(days.first),
        end: toLocalDateString(days.last),
      )
      .map((items) {
        final byDate = <String, int>{};
        for (final item in items) {
          byDate.update(
            item.expense.localDate,
            (sum) => sum + item.expense.amountMinor,
            ifAbsent: () => item.expense.amountMinor,
          );
        }
        return [
          for (final day in days)
            DayTotal(day, byDate[toLocalDateString(day)] ?? 0),
        ];
      });
});

@immutable
class DayTotal {
  const DayTotal(this.date, this.totalMinor);

  final DateTime date;
  final int totalMinor;
}

final todayTotalProvider = StreamProvider<int>((ref) {
  final today = toLocalDateString(ref.watch(todayProvider));
  return ref.watch(transactionDaoProvider).watchTotal(start: today, end: today);
});

final expenseCountProvider = StreamProvider<int>(
  (ref) => ref.watch(transactionDaoProvider).watchCount(),
);

/// Whether the backup banner was dismissed. In memory, so it lasts for the
/// session only.
final exportNudgeDismissedProvider =
    NotifierProvider<ExportNudgeDismissedNotifier, bool>(
      ExportNudgeDismissedNotifier.new,
    );

class ExportNudgeDismissedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void dismiss() => state = true;
}

@immutable
class ExportNudge {
  const ExportNudge(this.daysSinceExport);

  /// Null when the data has never been exported.
  final int? daysSinceExport;
}

/// The backup banner, or null when it should not show: shown when there is
/// at least one expense and the last export is missing or older than
/// [kExportNudgeDays].
final exportNudgeProvider = Provider<ExportNudge?>((ref) {
  if (ref.watch(exportNudgeDismissedProvider)) return null;
  if ((ref.watch(expenseCountProvider).valueOrNull ?? 0) == 0) return null;
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null) return null;
  final lastExportAt = settings.lastExportAt;
  if (lastExportAt == null) return const ExportNudge(null);
  final days = calendarDaysBetween(
    DateTime.fromMillisecondsSinceEpoch(lastExportAt),
    ref.watch(todayProvider),
  );
  return days > kExportNudgeDays ? ExportNudge(days) : null;
});

final ledgerActionsProvider = Provider<LedgerActions>(
  (ref) => LedgerActions(ref.watch(transactionDaoProvider)),
);

class LedgerActions {
  const LedgerActions(this._dao);

  final TransactionDao _dao;

  Future<void> deleteExpense(String id) => _dao.deleteExpense(id);
}

/// One day of expenses with its subtotal.
class DayGroup {
  DayGroup({required this.localDate, required this.items})
    : date = parseLocalDate(localDate),
      totalMinor = sumExpenses(items);

  final String localDate;
  final DateTime date;
  final List<ExpenseWithCategory> items;
  final int totalMinor;
}

int sumExpenses(Iterable<ExpenseWithCategory> items) =>
    items.fold(0, (sum, item) => sum + item.expense.amountMinor);

/// Groups a newest-first list by `localDate`, keeping the order.
List<DayGroup> groupByDay(List<ExpenseWithCategory> items) {
  final byDate = <String, List<ExpenseWithCategory>>{};
  for (final item in items) {
    byDate.putIfAbsent(item.expense.localDate, () => []).add(item);
  }
  return [
    for (final entry in byDate.entries)
      DayGroup(localDate: entry.key, items: entry.value),
  ];
}
