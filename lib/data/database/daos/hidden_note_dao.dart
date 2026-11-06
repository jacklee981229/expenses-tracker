import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/hidden_notes_table.dart';

part 'hidden_note_dao.g.dart';

@DriftAccessor(tables: [HiddenNotes])
class HiddenNoteDao extends DatabaseAccessor<AppDatabase>
    with _$HiddenNoteDaoMixin {
  HiddenNoteDao(super.attachedDatabase);

  /// Takes [note] out of [categoryId]'s history chips from now on; hiding
  /// it again moves that moment forward.
  Future<void> hide(String categoryId, String note) async {
    await into(hiddenNotes).insertOnConflictUpdate(
      HiddenNotesCompanion.insert(
        categoryId: categoryId,
        note: note,
        hiddenAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
