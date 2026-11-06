// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_note_dao.dart';

// ignore_for_file: type=lint
mixin _$HiddenNoteDaoMixin on DatabaseAccessor<AppDatabase> {
  $HiddenNotesTable get hiddenNotes => attachedDatabase.hiddenNotes;
  HiddenNoteDaoManager get managers => HiddenNoteDaoManager(this);
}

class HiddenNoteDaoManager {
  final _$HiddenNoteDaoMixin _db;
  HiddenNoteDaoManager(this._db);
  $$HiddenNotesTableTableManager get hiddenNotes =>
      $$HiddenNotesTableTableManager(_db.attachedDatabase, _db.hiddenNotes);
}
