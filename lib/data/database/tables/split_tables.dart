import 'package:drift/drift.dart';

import 'categories_table.dart';

/// A trip or a meal shared with other people: its own book, kept out of
/// the personal ledger and every personal figure.
class SplitGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();

  /// Epoch milliseconds.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One of a group's people: a name on this phone only.
@DataClassName('SplitPerson')
class SplitPeople extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(SplitGroups, #id)();
  TextColumn get name => text()();

  /// Jack himself: first in every group and never removed.
  BoolColumn get isMe => boolean().withDefault(const Constant(false))();

  /// The group's order: the leftover sen and ties in who pays whom go by
  /// it.
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// An expense in a group: one payer, shared by some of its people.
class SplitEntries extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(SplitGroups, #id)();

  /// Sen. Never a double.
  IntColumn get amountMinor => integer()();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get note => text().nullable()();

  /// Epoch milliseconds.
  IntColumn get occurredAt => integer()();

  /// `YYYY-MM-DD` in device local time, written from [occurredAt].
  TextColumn get localDate => text()();
  TextColumn get payerId => text().references(SplitPeople, #id)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A person's share of an entry, stored when it is saved, so a person
/// added later leaves older entries as they were.
class SplitShares extends Table {
  TextColumn get entryId => text().references(SplitEntries, #id)();
  TextColumn get personId => text().references(SplitPeople, #id)();

  /// Sen. An entry's shares add up to its amount.
  IntColumn get amountMinor => integer()();

  @override
  Set<Column<Object>> get primaryKey => {entryId, personId};
}
