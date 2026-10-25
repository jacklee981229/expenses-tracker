import 'package:drift/drift.dart';

/// Row class is `ExpenseCategory`: Flutter's foundation library already
/// exports a class named `Category`.
@DataClassName('ExpenseCategory')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Key into `kIconRegistry`.
  TextColumn get iconKey => text()();

  /// `RRGGBB`, no `#`.
  TextColumn get colorHex => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Epoch milliseconds.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
