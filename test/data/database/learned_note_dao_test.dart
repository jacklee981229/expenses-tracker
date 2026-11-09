import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a learned note comes back for the same shop and amount only', () async {
    await db.learnedNoteDao.learn('CHIN CHIEH HUI', 1100, 'Panmee');
    expect(await db.learnedNoteDao.noteFor('Chin  Chieh Hui', 1100), 'Panmee');
    expect(await db.learnedNoteDao.noteFor('CHIN CHIEH HUI', 1200), isNull);
    expect(await db.learnedNoteDao.noteFor('ALI BIN AHMAD', 1100), isNull);
  });

  test('learning again replaces the note', () async {
    await db.learnedNoteDao.learn('CHIN CHIEH HUI', 1100, 'Panmee');
    await db.learnedNoteDao.learn('chin chieh hui', 1100, 'Kopi ice');
    expect(await db.learnedNoteDao.noteFor('CHIN CHIEH HUI', 1100), 'Kopi ice');
  });
}
