// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_kind_dao.dart';

// ignore_for_file: type=lint
mixin _$ReceiptKindDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReceiptKindsTable get receiptKinds => attachedDatabase.receiptKinds;
  ReceiptKindDaoManager get managers => ReceiptKindDaoManager(this);
}

class ReceiptKindDaoManager {
  final _$ReceiptKindDaoMixin _db;
  ReceiptKindDaoManager(this._db);
  $$ReceiptKindsTableTableManager get receiptKinds =>
      $$ReceiptKindsTableTableManager(_db.attachedDatabase, _db.receiptKinds);
}
