// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learned_note_dao.dart';

// ignore_for_file: type=lint
mixin _$LearnedNoteDaoMixin on DatabaseAccessor<AppDatabase> {
  $LearnedNotesTable get learnedNotes => attachedDatabase.learnedNotes;
  LearnedNoteDaoManager get managers => LearnedNoteDaoManager(this);
}

class LearnedNoteDaoManager {
  final _$LearnedNoteDaoMixin _db;
  LearnedNoteDaoManager(this._db);
  $$LearnedNotesTableTableManager get learnedNotes =>
      $$LearnedNotesTableTableManager(_db.attachedDatabase, _db.learnedNotes);
}
