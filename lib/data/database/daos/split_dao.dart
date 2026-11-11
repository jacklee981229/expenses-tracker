import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/note_utils.dart';
import '../app_database.dart';
import '../tables/split_tables.dart';

part 'split_dao.g.dart';

const Uuid _uuid = Uuid();

/// An entry with its shares, keyed by person id.
typedef SplitEntryWithShares = ({SplitEntry entry, Map<String, int> shares});

/// Groups, their people, entries and shares: four tables that only mean
/// something together, so one DAO.
@DriftAccessor(tables: [SplitGroups, SplitPeople, SplitEntries, SplitShares])
class SplitDao extends DatabaseAccessor<AppDatabase> with _$SplitDaoMixin {
  SplitDao(super.attachedDatabase);

  // Groups

  Stream<List<SplitGroup>> watchGroups() => (select(
    splitGroups,
  )..orderBy([(g) => OrderingTerm.desc(g.sortOrder)])).watch();

  /// Each group's number of people, total spent and the category it
  /// spent most on (null while it has no entries), by group id, for the
  /// Books list.
  Stream<Map<String, SplitGroupSize>> watchGroupSizes() {
    return customSelect(
      'SELECT g.id AS id, '
      '(SELECT COUNT(*) FROM split_people p WHERE p.group_id = g.id) '
      'AS people, '
      '(SELECT COALESCE(SUM(e.amount_minor), 0) FROM split_entries e '
      'WHERE e.group_id = g.id) AS total, '
      '(SELECT e.category_id FROM split_entries e WHERE e.group_id = g.id '
      'GROUP BY e.category_id ORDER BY SUM(e.amount_minor) DESC, '
      'e.category_id LIMIT 1) AS top_category '
      'FROM split_groups g',
      readsFrom: {splitGroups, splitPeople, splitEntries},
    ).watch().map(
      (rows) => {
        for (final row in rows)
          row.read<String>('id'): (
            people: row.read<int>('people'),
            totalMinor: row.read<int>('total'),
            topCategoryId: row.readNullable<String>('top_category'),
          ),
      },
    );
  }

  /// Jack's name in the newest group, for the next one.
  Future<String?> lastMeName() async {
    final row =
        await (select(splitPeople).join([
                innerJoin(
                  splitGroups,
                  splitGroups.id.equalsExp(splitPeople.groupId),
                ),
              ])
              ..where(splitPeople.isMe.equals(true))
              ..orderBy([OrderingTerm.desc(splitGroups.sortOrder)])
              ..limit(1))
            .getSingleOrNull();
    return row?.readTable(splitPeople).name;
  }

  /// A new group, newest first, with Jack (named [meName]) and [others] in
  /// that order. Returns its id.
  Future<String> createGroup({
    required String name,
    required String meName,
    required List<String> others,
  }) {
    return transaction(() async {
      final id = _uuid.v4();
      final max = splitGroups.sortOrder.max();
      final row = await (selectOnly(
        splitGroups,
      )..addColumns([max])).getSingle();
      await into(splitGroups).insert(
        SplitGroupsCompanion.insert(
          id: id,
          name: name.trim(),
          sortOrder: (row.read(max) ?? -1) + 1,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await _insertPerson(id, meName, 0, isMe: true);
      for (final (index, other) in others.indexed) {
        await _insertPerson(id, other, index + 1);
      }
      return id;
    });
  }

  Future<void> renameGroup(String id, String name) async {
    await (update(splitGroups)..where((g) => g.id.equals(id))).write(
      SplitGroupsCompanion(name: Value(name.trim())),
    );
  }

  Future<void> setArchived(String id, {required bool archived}) async {
    await (update(splitGroups)..where((g) => g.id.equals(id))).write(
      SplitGroupsCompanion(isArchived: Value(archived)),
    );
  }

  /// The group and everything in it.
  Future<void> deleteGroup(String id) {
    return transaction(() async {
      final entryIds = selectOnly(splitEntries)
        ..addColumns([splitEntries.id])
        ..where(splitEntries.groupId.equals(id));
      await (delete(
        splitShares,
      )..where((s) => s.entryId.isInQuery(entryIds))).go();
      await (delete(splitEntries)..where((e) => e.groupId.equals(id))).go();
      await (delete(splitPeople)..where((p) => p.groupId.equals(id))).go();
      await (delete(splitGroups)..where((g) => g.id.equals(id))).go();
    });
  }

  // People

  /// In the group's order: Jack first.
  Stream<List<SplitPerson>> watchPeople(String groupId) =>
      (select(splitPeople)
            ..where((p) => p.groupId.equals(groupId))
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .watch();

  /// Adds [name] at the end of the group's order and returns its id.
  Future<String> addPerson(String groupId, String name) {
    return transaction(() async {
      final max = splitPeople.sortOrder.max();
      final row =
          await (selectOnly(splitPeople)
                ..addColumns([max])
                ..where(splitPeople.groupId.equals(groupId)))
              .getSingle();
      return _insertPerson(groupId, name, (row.read(max) ?? -1) + 1);
    });
  }

  Future<void> renamePerson(String id, String name) async {
    await (update(splitPeople)..where((p) => p.id.equals(id))).write(
      SplitPeopleCompanion(name: Value(name.trim())),
    );
  }

  /// Removes someone no entry names (as payer or sharer) and who isn't
  /// Jack. Returns whether they were removed.
  Future<bool> removePerson(String id) {
    return transaction(() async {
      final person = await (select(
        splitPeople,
      )..where((p) => p.id.equals(id))).getSingleOrNull();
      if (person == null || person.isMe) return false;
      final paid =
          await (select(splitEntries)
                ..where((e) => e.payerId.equals(id))
                ..limit(1))
              .get();
      final shared =
          await (select(splitShares)
                ..where((s) => s.personId.equals(id))
                ..limit(1))
              .get();
      if (paid.isNotEmpty || shared.isNotEmpty) return false;
      await (delete(splitPeople)..where((p) => p.id.equals(id))).go();
      return true;
    });
  }

  /// Names from every group but Jack's own, the newest group's first,
  /// each once (ignoring case and spaces), for a new group's chips.
  Future<List<String>> earlierNames() async {
    final rows =
        await (select(splitPeople).join([
                innerJoin(
                  splitGroups,
                  splitGroups.id.equalsExp(splitPeople.groupId),
                ),
              ])
              ..where(splitPeople.isMe.equals(false))
              ..orderBy([
                OrderingTerm.desc(splitGroups.sortOrder),
                OrderingTerm.asc(splitPeople.sortOrder),
              ]))
            .get();
    final seen = <String>{};
    return [
      for (final row in rows)
        if (seen.add(_nameKey(row.readTable(splitPeople).name)))
          row.readTable(splitPeople).name,
    ];
  }

  Future<String> _insertPerson(
    String groupId,
    String name,
    int sortOrder, {
    bool isMe = false,
  }) async {
    final id = _uuid.v4();
    await into(splitPeople).insert(
      SplitPeopleCompanion.insert(
        id: id,
        groupId: groupId,
        name: name.trim(),
        isMe: Value(isMe),
        sortOrder: sortOrder,
      ),
    );
    return id;
  }

  // Entries

  /// The group's entries with their shares, newest first.
  Stream<List<SplitEntryWithShares>> watchEntries(String groupId) {
    final query =
        select(splitEntries).join([
            leftOuterJoin(
              splitShares,
              splitShares.entryId.equalsExp(splitEntries.id),
            ),
          ])
          ..where(splitEntries.groupId.equals(groupId))
          ..orderBy([
            OrderingTerm.desc(splitEntries.occurredAt),
            OrderingTerm.desc(splitEntries.createdAt),
          ]);
    return query.watch().map((rows) {
      final entries = <String, SplitEntry>{};
      final shares = <String, Map<String, int>>{};
      for (final row in rows) {
        final entry = row.readTable(splitEntries);
        entries[entry.id] = entry;
        final share = row.readTableOrNull(splitShares);
        final map = shares.putIfAbsent(entry.id, () => {});
        if (share != null) map[share.personId] = share.amountMinor;
      }
      return [
        for (final entry in entries.values)
          (entry: entry, shares: shares[entry.id]!),
      ];
    });
  }

  /// Saves an entry with its [shares] (person id to sen, adding up to
  /// [amountMinor]); with an [id], replaces that entry and its shares.
  /// Returns the entry's id.
  Future<String> saveEntry({
    String? id,
    required String groupId,
    required int amountMinor,
    required String categoryId,
    required DateTime occurredAt,
    String? note,
    required String payerId,
    required Map<String, int> shares,
  }) {
    assert(
      shares.values.fold(0, (a, b) => a + b) == amountMinor,
      'shares must add up to the amount',
    );
    return transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final entryId = id ?? _uuid.v4();
      final values = SplitEntriesCompanion(
        groupId: Value(groupId),
        amountMinor: Value(amountMinor),
        categoryId: Value(categoryId),
        note: Value(cleanNote(note)),
        occurredAt: Value(occurredAt.millisecondsSinceEpoch),
        localDate: Value(toLocalDateString(occurredAt)),
        payerId: Value(payerId),
        updatedAt: Value(now),
      );
      if (id == null) {
        await into(
          splitEntries,
        ).insert(values.copyWith(id: Value(entryId), createdAt: Value(now)));
      } else {
        await (update(
          splitEntries,
        )..where((e) => e.id.equals(id))).write(values);
        await (delete(splitShares)..where((s) => s.entryId.equals(id))).go();
      }
      await _insertShares(entryId, shares);
      return entryId;
    });
  }

  Future<void> deleteEntry(String id) {
    return transaction(() async {
      await (delete(splitShares)..where((s) => s.entryId.equals(id))).go();
      await (delete(splitEntries)..where((e) => e.id.equals(id))).go();
    });
  }

  /// Undo of [deleteEntry].
  Future<void> restoreEntry(SplitEntryWithShares saved) {
    return transaction(() async {
      await into(
        splitEntries,
      ).insert(saved.entry, mode: InsertMode.insertOrIgnore);
      await _insertShares(saved.entry.id, saved.shares);
    });
  }

  Future<void> _insertShares(String entryId, Map<String, int> shares) => batch(
    (batch) => batch.insertAll(splitShares, [
      for (final MapEntry(key: personId, value: amount) in shares.entries)
        SplitSharesCompanion.insert(
          entryId: entryId,
          personId: personId,
          amountMinor: amount,
        ),
    ], mode: InsertMode.insertOrIgnore),
  );

  // Backup

  Future<SplitBackup> getAll() async => (
    groups: await select(splitGroups).get(),
    people: await select(splitPeople).get(),
    entries: await select(splitEntries).get(),
    shares: await select(splitShares).get(),
  );

  /// Backup import. With [skipExisting], rows already here are left alone
  /// (merge); otherwise a clash is an error.
  Future<void> importRows(SplitBackup rows, {required bool skipExisting}) {
    final mode = skipExisting ? InsertMode.insertOrIgnore : InsertMode.insert;
    return batch((batch) {
      batch
        ..insertAll(splitGroups, rows.groups, mode: mode)
        ..insertAll(splitPeople, rows.people, mode: mode)
        ..insertAll(splitEntries, rows.entries, mode: mode)
        ..insertAll(splitShares, rows.shares, mode: mode);
    });
  }

  /// Backup import (replace): before the categories go.
  Future<void> deleteAll() async {
    await delete(splitShares).go();
    await delete(splitEntries).go();
    await delete(splitPeople).go();
    await delete(splitGroups).go();
  }
}

/// A group's size in the Books list.
typedef SplitGroupSize = ({int people, int totalMinor, String? topCategoryId});

/// Every split row, as the backup carries them.
typedef SplitBackup = ({
  List<SplitGroup> groups,
  List<SplitPerson> people,
  List<SplitEntry> entries,
  List<SplitShare> shares,
});

String _nameKey(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
