import 'package:drift/drift.dart';

/// The note Jack gave a screenshot's shop at one amount, so the next
/// screenshot of the same shop and amount fills it in (`CHIN CHIEH HUI`
/// at RM11.00 becomes `Panmee`). Lives only on the phone, not in backups.
@DataClassName('LearnedNoteRow')
class LearnedNotes extends Table {
  /// The shop as read, in its `shopKey` form.
  TextColumn get shop => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get note => text()();

  /// Epoch milliseconds of the save that taught it.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {shop, amountMinor};
}
