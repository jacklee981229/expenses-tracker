import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/database/daos/analysis_dao.dart';
import 'package:expense_tracker/data/database/daos/transaction_dao.dart';
import 'package:expense_tracker/data/database/tables/transactions_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late String food;
  late String transport;
  late String rent;

  Future<String> category(String name) => db.categoryDao.insertCategory(
    name: name,
    iconKey: 'others',
    colorHex: '78909C',
  );

  Future<void> spend(String categoryId, int amountMinor, DateTime at) =>
      db.transactionDao.insertExpense(
        amountMinor: amountMinor,
        categoryId: categoryId,
        occurredAt: at,
      );

  Map<String, (int, int)> byCategory(List<CategoryTotal> totals) => {
    for (final total in totals)
      total.category.id: (total.totalMinor, total.count),
  };

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    food = await category('Test Food');
    transport = await category('Test Transport');
    rent = await category('Test Rent');

    await spend(food, 1250, DateTime(2026, 9, 1, 8));
    await spend(food, 800, DateTime(2026, 9, 30, 23, 59));
    await spend(transport, 300, DateTime(2026, 9, 15));
    await spend(rent, 150000, DateTime(2026, 9, 5));
    // Outside September on both sides.
    await spend(food, 999, DateTime(2026, 8, 31, 23, 59));
    await spend(transport, 111, DateTime(2026, 10, 1));
  });

  tearDown(() => db.close());

  test('sums and counts per category within inclusive bounds', () async {
    final totals = await db.analysisDao.categoryTotals(
      start: '2026-09-01',
      end: '2026-09-30',
    );
    expect(byCategory(totals), {
      rent: (150000, 1),
      food: (2050, 2),
      transport: (300, 1),
    });
  });

  test('orders categories by total, largest first', () async {
    final totals = await db.analysisDao.categoryTotals(
      start: '2026-09-01',
      end: '2026-09-30',
    );
    expect([for (final t in totals) t.category.id], [rent, food, transport]);
  });

  test('includes both boundary days and nothing outside them', () async {
    final firstDay = await db.analysisDao.categoryTotals(
      start: '2026-09-01',
      end: '2026-09-01',
    );
    expect(byCategory(firstDay), {food: (1250, 1)});

    final lastDay = await db.analysisDao.categoryTotals(
      start: '2026-09-30',
      end: '2026-09-30',
    );
    expect(byCategory(lastDay), {food: (800, 1)});
  });

  test('covers all time when no bounds are given', () async {
    final totals = await db.analysisDao.categoryTotals();
    expect(byCategory(totals), {
      rent: (150000, 1),
      food: (3049, 3),
      transport: (411, 2),
    });
  });

  test('limits to the filtered categories', () async {
    final totals = await db.analysisDao.categoryTotals(
      start: '2026-09-01',
      end: '2026-09-30',
      categoryIds: {food, transport},
    );
    expect(byCategory(totals), {food: (2050, 2), transport: (300, 1)});
  });

  test('returns nothing for a period without expenses', () async {
    final totals = await db.analysisDao.categoryTotals(
      start: '2026-07-01',
      end: '2026-07-31',
    );
    expect(totals, isEmpty);
  });

  test('breaks ties by category sort order', () async {
    final second = await category('Tie B');
    final first = await category('Tie A');
    await db.categoryDao.reorder([first, second]);
    await spend(second, 500, DateTime(2026, 6, 10));
    await spend(first, 500, DateTime(2026, 6, 11));

    final totals = await db.analysisDao.categoryTotals(
      start: '2026-06-01',
      end: '2026-06-30',
    );
    expect([for (final t in totals) t.category.id], [first, second]);
  });

  test('finds the earliest expense date', () async {
    expect(await db.analysisDao.firstDate(), '2026-08-31');
    await spend(rent, 100, DateTime(2025, 12, 31, 23, 59));
    expect(await db.analysisDao.firstDate(), '2025-12-31');
  });

  test('has no first date without expenses', () async {
    final empty = AppDatabase(NativeDatabase.memory());
    addTearDown(empty.close);
    expect(await empty.analysisDao.firstDate(), isNull);
  });

  test('emits fresh totals when expenses change', () async {
    final stream = db.analysisDao.watchCategoryTotals(
      start: '2026-09-01',
      end: '2026-09-30',
      categoryIds: {transport},
    );
    expect(byCategory(await stream.first), {transport: (300, 1)});

    await spend(transport, 700, DateTime(2026, 9, 20));
    expect(byCategory(await stream.first), {transport: (1000, 2)});
  });

  test('sums spending per month within inclusive bounds', () async {
    expect(
      await db.analysisDao.monthTotals(start: '2026-08-01', end: '2026-10-31'),
      {'2026-08': 999, '2026-09': 152350, '2026-10': 111},
    );
    expect(
      await db.analysisDao.monthTotals(start: '2026-09-15', end: '2026-10-31'),
      {'2026-09': 1100, '2026-10': 111},
    );
  });

  test('month totals follow the category filter', () async {
    expect(
      await db.analysisDao.monthTotals(
        start: '2026-08-01',
        end: '2026-10-31',
        categoryIds: {food},
      ),
      {'2026-08': 999, '2026-09': 2050},
    );
  });

  test('week totals group by the week a day falls in', () async {
    // 1 Sep 2026 is a Tuesday, 5 Sep a Saturday, 15 Sep a Tuesday,
    // 30 Sep a Wednesday, 31 Aug a Monday, 1 Oct a Thursday.
    expect(
      await db.analysisDao.weekTotals(
        start: '2026-08-31',
        end: '2026-10-04',
        firstDayOfWeek: DateTime.monday,
      ),
      {
        '2026-08-31': 999 + 1250 + 150000,
        '2026-09-14': 300,
        '2026-09-28': 800 + 111,
      },
    );
  });

  test('week totals follow the first day of week', () async {
    // Weeks from Sunday: 31 Aug and 1–5 Sep share the week of 30 Aug.
    expect(
      await db.analysisDao.weekTotals(
        start: '2026-08-30',
        end: '2026-10-03',
        firstDayOfWeek: DateTime.sunday,
      ),
      {
        '2026-08-30': 999 + 1250 + 150000,
        '2026-09-13': 300,
        '2026-09-27': 800 + 111,
      },
    );
    // Weeks from Saturday: 5 Sep starts a new one.
    expect(
      await db.analysisDao.weekTotals(
        start: '2026-08-29',
        end: '2026-10-02',
        firstDayOfWeek: DateTime.saturday,
      ),
      {
        '2026-08-29': 999 + 1250,
        '2026-09-05': 150000,
        '2026-09-12': 300,
        '2026-09-26': 800 + 111,
      },
    );
  });

  test('week totals stay inside the bounds and follow the filter', () async {
    expect(
      await db.analysisDao.weekTotals(
        start: '2026-09-01',
        end: '2026-09-30',
        firstDayOfWeek: DateTime.monday,
        categoryIds: {food},
      ),
      {'2026-08-31': 1250, '2026-09-28': 800},
    );
  });

  test('finds the biggest day, filtered or not', () async {
    expect(
      await db.analysisDao.biggestDay(start: '2026-09-01', end: '2026-09-30'),
      (localDate: '2026-09-05', totalMinor: 150000),
    );
    expect(
      await db.analysisDao.biggestDay(
        start: '2026-09-01',
        end: '2026-09-30',
        categoryIds: {food},
      ),
      (localDate: '2026-09-01', totalMinor: 1250),
    );
    expect(
      await db.analysisDao.biggestDay(start: '2026-07-01', end: '2026-07-31'),
      isNull,
    );
  });

  test('sums fixed expenses only, in bounds and filtered', () async {
    Future<void> fixed(String categoryId, int amountMinor, DateTime at) =>
        db.transactionDao.insertExpense(
          amountMinor: amountMinor,
          categoryId: categoryId,
          occurredAt: at,
          source: TransactionSource.recurring,
        );
    await fixed(rent, 88000, DateTime(2026, 9, 25));
    await fixed(transport, 5000, DateTime(2026, 9, 1));
    await fixed(rent, 88000, DateTime(2026, 10, 25));

    Future<int> total([Set<String> ids = const {}]) => db.analysisDao
        .watchFixedTotal(
          start: '2026-09-01',
          end: '2026-09-30',
          categoryIds: ids,
        )
        .first;
    expect(await total(), 93000);
    expect(await total({rent}), 88000);
    expect(await total({food}), 0);
  });

  test('the later day wins a tie for the biggest day', () async {
    await spend(food, 1250, DateTime(2026, 9, 20));
    expect(
      await db.analysisDao.biggestDay(
        start: '2026-09-01',
        end: '2026-09-30',
        categoryIds: {food},
      ),
      (localDate: '2026-09-20', totalMinor: 1250),
    );
  });

  test('lists the expenses in bounds, newest first, filtered or not', () async {
    List<(int, String)> amounts(List<ExpenseWithCategory> rows) => [
      for (final row in rows) (row.expense.amountMinor, row.category.id),
    ];
    expect(
      amounts(
        await db.analysisDao.expenses(start: '2026-09-01', end: '2026-09-30'),
      ),
      [(800, food), (300, transport), (150000, rent), (1250, food)],
    );
    expect(
      amounts(
        await db.analysisDao.expenses(
          start: '2026-09-01',
          end: '2026-09-30',
          categoryIds: {food, transport},
        ),
      ),
      [(800, food), (300, transport), (1250, food)],
    );
    expect(await db.analysisDao.expenses(), hasLength(6));
  });
}
