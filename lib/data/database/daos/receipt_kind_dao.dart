import 'package:drift/drift.dart';

import '../../../core/utils/receipt_kinds.dart';
import '../app_database.dart';
import '../tables/receipt_kinds_table.dart';

part 'receipt_kind_dao.g.dart';

@DriftAccessor(tables: [ReceiptKinds])
class ReceiptKindDao extends DatabaseAccessor<AppDatabase>
    with _$ReceiptKindDaoMixin {
  ReceiptKindDao(super.attachedDatabase);

  static const String _separator = '\n';

  Future<List<ReceiptKind>> getAll() async => [
    for (final row in await select(receiptKinds).get()) _kind(row),
  ];

  /// Names the kind of page with [labels]: renames the kind it matches
  /// (taking these labels, the latest look of the page), or adds one. A
  /// page with too few labels to ever match is not kept.
  Future<void> remember(Set<String> labels, String name) async {
    if (labels.length < kKindMinShared) return;
    final rows = await select(receiptKinds).get();
    final kinds = [for (final row in rows) _kind(row)];
    final match = matchKind(labels, kinds);
    final companion = ReceiptKindsCompanion(
      labels: Value((labels.toList()..sort()).join(_separator)),
      name: Value(name),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
    if (match == null) {
      await into(receiptKinds).insert(companion);
      return;
    }
    final id = rows[kinds.indexOf(match)].id;
    await (update(
      receiptKinds,
    )..where((k) => k.id.equals(id))).write(companion);
  }

  ReceiptKind _kind(ReceiptKindRow row) =>
      (labels: row.labels.split(_separator).toSet(), name: row.name);
}
