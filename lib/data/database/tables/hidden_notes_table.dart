import 'package:drift/drift.dart';

/// A note Jack took out of a category's history chips (usually a typo). Its
/// past expenses keep the note; only uses saved after [hiddenAt] bring the
/// chip back.
@DataClassName('HiddenNoteRow')
class HiddenNotes extends Table {
  // No foreign key: a category is only deleted once it has no expenses,
  // and a leftover row for it hides nothing.
  TextColumn get categoryId => text()();

  /// Exactly as stored, case included, as the chips match it.
  TextColumn get note => text()();

  /// Epoch milliseconds, compared with an expense's `createdAt`.
  IntColumn get hiddenAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {categoryId, note};
}
