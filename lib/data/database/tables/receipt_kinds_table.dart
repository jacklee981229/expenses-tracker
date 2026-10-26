import 'package:drift/drift.dart';

/// A kind of receipt page Jack has named, so its screenshots fill that name
/// in (`Food App - Kedai Ali`). Names live only on the phone.
@DataClassName('ReceiptKindRow')
class ReceiptKinds extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The page's labels, one per line (see `parseReceipt`).
  TextColumn get labels => text()();
  TextColumn get name => text()();

  /// Epoch milliseconds of the last save that named it.
  IntColumn get updatedAt => integer()();
}
