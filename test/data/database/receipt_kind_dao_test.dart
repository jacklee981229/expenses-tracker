import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  const page = {'order details', 'item details', 'item subtotal', 'order info'};

  test('a named page comes back with its labels', () async {
    await db.receiptKindDao.remember(page, 'Food App');
    final kinds = await db.receiptKindDao.getAll();
    expect(kinds, hasLength(1));
    expect(kinds.single.name, 'Food App');
    expect(kinds.single.labels, page);
  });

  test('naming the same kind again renames it instead of adding one', () async {
    await db.receiptKindDao.remember(page, 'Food App');
    await db.receiptKindDao.remember({...page, 'ask me first'}, 'Food Go');
    final kinds = await db.receiptKindDao.getAll();
    expect(kinds, hasLength(1));
    expect(kinds.single.name, 'Food Go');
    expect(kinds.single.labels, contains('ask me first'));
  });

  test('a different page gets its own name', () async {
    await db.receiptKindDao.remember(page, 'Food App');
    await db.receiptKindDao.remember({
      'transferred',
      'receiver',
      'remark',
      'date time',
    }, 'Wallet');
    expect(await db.receiptKindDao.getAll(), hasLength(2));
  });

  test('a page without labels is not remembered', () async {
    await db.receiptKindDao.remember(const {}, 'Nothing');
    expect(await db.receiptKindDao.getAll(), isEmpty);
  });
}
