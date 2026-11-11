import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/core/utils/split_settle.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late String food;
  late String trip;
  late List<SplitPerson> people;

  String id(String name) => people.firstWhere((p) => p.name == name).id;

  Future<String> spend(
    int amount,
    String payer,
    List<String> sharers, {
    String? entryId,
  }) {
    final ids = [for (final name in sharers) id(name)];
    return db.splitDao.saveEntry(
      id: entryId,
      groupId: trip,
      amountMinor: amount,
      categoryId: food,
      occurredAt: DateTime(2026, 11, 8, 20),
      note: 'Test dinner',
      payerId: id(payer),
      shares: equalShares(amount: amount, payer: id(payer), sharers: ids),
    );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    food = await db.categoryDao.insertCategory(
      name: 'Test Food',
      iconKey: 'others',
      colorHex: '78909C',
    );
    trip = await db.splitDao.createGroup(
      name: ' Test trip ',
      meName: 'Jack',
      others: ['Ali', 'Mei'],
    );
    people = await db.splitDao.watchPeople(trip).first;
  });

  tearDown(() => db.close());

  test('a new group has Jack first, then the others in order', () async {
    expect([for (final p in people) p.name], ['Jack', 'Ali', 'Mei']);
    expect([for (final p in people) p.isMe], [true, false, false]);
    final groups = await db.splitDao.watchGroups().first;
    expect(groups.single.name, 'Test trip');
  });

  test('an entry keeps its shares, adding up to the amount', () async {
    await spend(10000, 'Ali', ['Jack', 'Ali', 'Mei']);
    final saved = (await db.splitDao.watchEntries(trip).first).single;
    expect(saved.shares, {id('Jack'): 3333, id('Ali'): 3334, id('Mei'): 3333});
    expect(saved.entry.localDate, '2026-11-08');
  });

  test('group sizes: people and total per group, empty groups too', () async {
    final empty = await db.splitDao.createGroup(
      name: 'Test meal',
      meName: 'Jack',
      others: const [],
    );
    await spend(10000, 'Ali', ['Jack', 'Ali', 'Mei']);
    await spend(250, 'Jack', ['Jack', 'Mei']);
    final sizes = await db.splitDao.watchGroupSizes().first;
    expect(sizes[trip], (people: 3, totalMinor: 10250, topCategoryId: food));
    expect(sizes[empty], (people: 1, totalMinor: 0, topCategoryId: null));
    expect(await db.splitDao.lastMeName(), 'Jack');
  });

  test('editing an entry rewrites its shares', () async {
    final entry = await spend(9000, 'Ali', ['Jack', 'Ali', 'Mei']);
    await spend(9000, 'Mei', ['Jack', 'Mei'], entryId: entry);
    final saved = (await db.splitDao.watchEntries(trip).first).single;
    expect(saved.entry.payerId, id('Mei'));
    expect(saved.shares, {id('Jack'): 4500, id('Mei'): 4500});
  });

  test('deleting an entry and undoing it brings back its shares', () async {
    final entry = await spend(600, 'Jack', ['Jack', 'Ali']);
    final saved = (await db.splitDao.watchEntries(trip).first).single;
    await db.splitDao.deleteEntry(entry);
    expect(await db.splitDao.watchEntries(trip).first, isEmpty);
    await db.splitDao.restoreEntry(saved);
    expect(
      (await db.splitDao.watchEntries(trip).first).single.shares,
      saved.shares,
    );
  });

  test('a person named by an entry, or Jack, cannot be removed', () async {
    final raj = await db.splitDao.addPerson(trip, 'Raj');
    await spend(1000, 'Ali', ['Jack', 'Mei']);
    expect(await db.splitDao.removePerson(id('Ali')), isFalse); // payer
    expect(await db.splitDao.removePerson(id('Mei')), isFalse); // sharer
    expect(await db.splitDao.removePerson(id('Jack')), isFalse);
    expect(await db.splitDao.removePerson(raj), isTrue);
    expect((await db.splitDao.watchPeople(trip).first).length, 3);
  });

  test('deleting a group takes everything in it', () async {
    await spend(1000, 'Ali', ['Jack', 'Mei']);
    await db.splitDao.deleteGroup(trip);
    final all = await db.splitDao.getAll();
    expect(all.groups, isEmpty);
    expect(all.people, isEmpty);
    expect(all.entries, isEmpty);
    expect(all.shares, isEmpty);
  });

  test('a category used only by a group expense counts as used', () async {
    expect(await db.categoryDao.usageCount(food), 0);
    await spend(1000, 'Ali', ['Jack', 'Mei']);
    expect(await db.categoryDao.usageCount(food), 1);
  });

  test('earlier names: newest group first, each once, never Jack', () async {
    await db.splitDao.createGroup(
      name: 'Test meal',
      meName: 'Jack',
      others: ['Siti', 'ali '],
    );
    expect(await db.splitDao.earlierNames(), ['Siti', 'ali', 'Mei']);
  });
}
