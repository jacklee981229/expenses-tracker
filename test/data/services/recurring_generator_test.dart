import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/database/tables/transactions_table.dart';
import 'package:expense_tracker/data/services/recurring_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late String categoryId;
  late DateTime now;
  late RecurringGenerator generator;

  Future<String> rule({
    int amountMinor = 150000,
    String? note = 'Rent',
    int dayOfMonth = 1,
    String startMonth = '2026-06',
    String? endMonth,
    bool isActive = true,
  }) => db.recurringDao.insertRule(
    amountMinor: amountMinor,
    categoryId: categoryId,
    note: note,
    dayOfMonth: dayOfMonth,
    startMonth: startMonth,
    endMonth: endMonth,
    isActive: isActive,
  );

  Future<List<Expense>> generated() async {
    final all = await db.transactionDao.getAll();
    return all.where((e) => e.source == TransactionSource.recurring).toList()
      ..sort((a, b) => a.localDate.compareTo(b.localDate));
  }

  Future<List<String>> generatedDates() async => [
    for (final expense in await generated()) expense.localDate,
  ];

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    categoryId = await db.categoryDao.insertCategory(
      name: 'Test Rent',
      iconKey: 'rent',
      colorHex: '8D6E63',
    );
    now = DateTime(2026, 9, 24, 10);
    generator = RecurringGenerator(db, clock: () => now);
  });

  tearDown(() => db.close());

  group('catch-up', () {
    test('adds one expense per month from a past start month to now', () async {
      await rule(startMonth: '2026-06', dayOfMonth: 15);

      expect(await generator.catchUp(), 4);
      expect(await generatedDates(), [
        '2026-06-15',
        '2026-07-15',
        '2026-08-15',
        '2026-09-15',
      ]);
    });

    test('copies the rule into each expense', () async {
      final id = await rule(
        startMonth: '2026-09',
        amountMinor: 4990,
        note: 'Netflix',
        dayOfMonth: 5,
      );
      await generator.catchUp();

      final expense = (await generated()).single;
      expect(expense.amountMinor, 4990);
      expect(expense.categoryId, categoryId);
      expect(expense.note, 'Netflix');
      expect(expense.source, TransactionSource.recurring);
      expect(expense.recurringRuleId, id);
      expect(expense.localDate, '2026-09-05');
    });

    test(
      'includes the current month even when its day is still ahead',
      () async {
        await rule(startMonth: '2026-09', dayOfMonth: 28);
        await generator.catchUp();
        expect(await generatedDates(), ['2026-09-28']);
      },
    );

    test('records the last generated month on the rule', () async {
      final id = await rule(startMonth: '2026-07');
      await generator.catchUp();
      expect(
        (await db.recurringDao.findById(id))!.lastGeneratedMonth,
        '2026-09',
      );
    });

    test('generates nothing for a start month in the future', () async {
      await rule(startMonth: '2026-10');
      expect(await generator.catchUp(), 0);
      expect(await generated(), isEmpty);
    });

    test('stops at the end month', () async {
      await rule(startMonth: '2026-05', endMonth: '2026-07');
      await generator.catchUp();
      expect(await generatedDates(), [
        '2026-05-01',
        '2026-06-01',
        '2026-07-01',
      ]);
    });

    test('skips paused rules', () async {
      await rule(startMonth: '2026-06', isActive: false);
      expect(await generator.catchUp(), 0);
    });

    test('continues from the last generated month as time passes', () async {
      await rule(startMonth: '2026-08');
      await generator.catchUp();

      now = DateTime(2026, 11, 2);
      expect(await generator.catchUp(), 2);
      expect(await generatedDates(), [
        '2026-08-01',
        '2026-09-01',
        '2026-10-01',
        '2026-11-01',
      ]);
    });

    test('crosses a year boundary', () async {
      now = DateTime(2027, 2, 1);
      await rule(startMonth: '2026-11', dayOfMonth: 10);
      await generator.catchUp();
      expect(await generatedDates(), [
        '2026-11-10',
        '2026-12-10',
        '2027-01-10',
        '2027-02-10',
      ]);
    });
  });

  group('idempotency', () {
    test('running catch-up twice adds nothing the second time', () async {
      await rule(startMonth: '2026-06');
      expect(await generator.catchUp(), 4);
      expect(await generator.catchUp(), 0);
      expect(await generated(), hasLength(4));
    });

    test('overlapping catch-ups do not double-post', () async {
      await rule(startMonth: '2026-06');
      final results = await Future.wait([
        generator.catchUp(),
        generator.catchUp(),
        RecurringGenerator(db, clock: () => now).catchUp(),
      ]);
      // The first two calls share one run; the separate generator re-reads
      // the rule inside its transaction and finds nothing left to add.
      expect(results[0], results[1]);
      expect(results[0] + results[2], 4);
      expect(await generated(), hasLength(4));
    });

    test('does not recreate a generated expense the user deleted', () async {
      await rule(startMonth: '2026-08');
      await generator.catchUp();
      final august = (await generated()).first;
      await db.transactionDao.deleteExpense(august.id);

      expect(await generator.catchUp(), 0);
      expect(await generatedDates(), ['2026-09-01']);
    });

    test('honours a start month moved later after generating', () async {
      final id = await rule(startMonth: '2026-06');
      now = DateTime(2026, 7, 3);
      await generator.catchUp();
      final saved = (await db.recurringDao.findById(id))!;
      await db.recurringDao.updateRule(
        id: id,
        amountMinor: saved.amountMinor,
        categoryId: saved.categoryId,
        note: saved.note,
        dayOfMonth: saved.dayOfMonth,
        startMonth: '2026-09',
        endMonth: saved.endMonth,
        isActive: true,
      );

      now = DateTime(2026, 9, 24);
      await generator.catchUp();
      expect(await generatedDates(), [
        '2026-06-01',
        '2026-07-01',
        '2026-09-01',
      ]);
    });
  });

  group('day-of-month clamping', () {
    test('day 31 uses the last day of shorter months', () async {
      now = DateTime(2026, 6, 15);
      await rule(startMonth: '2026-01', dayOfMonth: 31);
      await generator.catchUp();
      expect(await generatedDates(), [
        '2026-01-31',
        '2026-02-28',
        '2026-03-31',
        '2026-04-30',
        '2026-05-31',
        '2026-06-30',
      ]);
    });

    test('day 31 in a leap-year February is the 29th', () async {
      now = DateTime(2028, 2, 10);
      await rule(startMonth: '2028-02', dayOfMonth: 31);
      await generator.catchUp();
      expect(await generatedDates(), ['2028-02-29']);
    });

    test('day 30 in February is the 28th', () async {
      now = DateTime(2026, 2, 1);
      await rule(startMonth: '2026-02', dayOfMonth: 30);
      await generator.catchUp();
      expect(await generatedDates(), ['2026-02-28']);
    });
  });

  group('first month to generate', () {
    RecurringRule ruleWith({required String start, String? last}) =>
        RecurringRule(
          id: 'r',
          amountMinor: 100,
          categoryId: 'c',
          dayOfMonth: 1,
          startMonth: start,
          isActive: true,
          lastGeneratedMonth: last,
          createdAt: 0,
        );

    test('is the start month before anything was generated', () {
      expect(
        RecurringGenerator.firstMonthToGenerate(ruleWith(start: '2026-03')),
        '2026-03',
      );
    });

    test('is the month after the last generated one', () {
      expect(
        RecurringGenerator.firstMonthToGenerate(
          ruleWith(start: '2026-03', last: '2026-12'),
        ),
        '2027-01',
      );
    });
  });

  group('resuming a paused rule', () {
    final september = DateTime(2026, 9, 24);

    test('skips the months that passed while paused', () {
      expect(
        RecurringGenerator.lastGeneratedOnResume('2026-05', september),
        '2026-08',
      );
    });

    test('starts from the current month for a rule never generated', () {
      expect(
        RecurringGenerator.lastGeneratedOnResume(null, september),
        '2026-08',
      );
    });

    test('keeps a guard that is already current', () {
      expect(
        RecurringGenerator.lastGeneratedOnResume('2026-09', september),
        '2026-09',
      );
    });
  });
}
