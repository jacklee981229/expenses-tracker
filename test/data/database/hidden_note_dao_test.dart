import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late String food;
  late String drinks;

  Future<String> category(String name) => db.categoryDao.insertCategory(
    name: name,
    iconKey: 'others',
    colorHex: '78909C',
  );

  Future<void> spend(String categoryId, String note) =>
      db.transactionDao.insertExpense(
        amountMinor: 1000,
        categoryId: categoryId,
        occurredAt: DateTime(2026, 11, 1, 12),
        note: note,
      );

  Future<Set<String>> chips(String categoryId) async => {
    for (final use in await db.transactionDao.watchNoteUses(categoryId).first)
      use.note,
  };

  // Saving and hiding are stamped in milliseconds: keep them apart.
  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 5));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    food = await category('Test Food');
    drinks = await category('Test Drinks');
    await spend(food, 'Mamak');
    await spend(food, 'Mamk');
    await spend(food, 'Mamk');
    await spend(drinks, 'Mamk');
  });
  tearDown(() => db.close());

  test('a hidden note leaves its category\'s chips only', () async {
    await tick();
    await db.hiddenNoteDao.hide(food, 'Mamk');
    expect(await chips(food), {'Mamak'});
    expect(await chips(drinks), {'Mamk'});
  });

  test('the match is exact: other spellings stay', () async {
    await tick();
    await db.hiddenNoteDao.hide(food, 'mamk');
    expect(await chips(food), {'Mamak', 'Mamk'});
  });

  test('using the note again after hiding brings the chip back', () async {
    await tick();
    await db.hiddenNoteDao.hide(food, 'Mamk');
    await tick();
    await spend(food, 'Mamk');
    expect(await chips(food), {'Mamak', 'Mamk'});
    final uses = await db.transactionDao.watchNoteUses(food).first;
    // Only the new use counts towards its rank.
    expect(uses.where((use) => use.note == 'Mamk'), hasLength(1));
  });

  test('hiding again hides the newer uses too', () async {
    await tick();
    await db.hiddenNoteDao.hide(food, 'Mamk');
    await tick();
    await spend(food, 'Mamk');
    await tick();
    await db.hiddenNoteDao.hide(food, 'Mamk');
    expect(await chips(food), {'Mamak'});
  });
}
