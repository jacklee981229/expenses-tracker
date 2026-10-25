import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/database/daos/analysis_dao.dart';
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

  test('counts the distinct days that have expenses', () async {
    // September has expenses on the 1st, 5th, 15th and 30th.
    expect(
      await db.analysisDao.activeDays(start: '2026-09-01', end: '2026-09-30'),
      4,
    );
    await spend(food, 100, DateTime(2026, 9, 15, 20));
    expect(
      await db.analysisDao.activeDays(start: '2026-09-01', end: '2026-09-30'),
      4,
      reason: 'a second expense on the 15th is the same day',
    );
  });

  test('limits the day count to the filter and to all time', () async {
    expect(
      await db.analysisDao.activeDays(
        start: '2026-09-01',
        end: '2026-09-30',
        categoryIds: {food},
      ),
      2,
    );
    expect(await db.analysisDao.activeDays(), 6);
    expect(
      await db.analysisDao.activeDays(start: '2026-07-01', end: '2026-07-31'),
      0,
    );
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
}
