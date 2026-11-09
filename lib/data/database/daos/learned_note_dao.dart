import 'package:drift/drift.dart';

import '../../../core/utils/learned_notes.dart';
import '../app_database.dart';
import '../tables/learned_notes_table.dart';

part 'learned_note_dao.g.dart';

@DriftAccessor(tables: [LearnedNotes])
class LearnedNoteDao extends DatabaseAccessor<AppDatabase>
    with _$LearnedNoteDaoMixin {
  LearnedNoteDao(super.attachedDatabase);

  /// The note learned for [shop] at exactly [amountMinor], or null.
  Future<String?> noteFor(String shop, int amountMinor) async {
    final row =
        await (select(learnedNotes)..where(
              (n) =>
                  n.shop.equals(shopKey(shop)) &
                  n.amountMinor.equals(amountMinor),
            ))
            .getSingleOrNull();
    return row?.note;
  }

  /// Remembers [note] for [shop] at [amountMinor], replacing an older one.
  Future<void> learn(String shop, int amountMinor, String note) async {
    await into(learnedNotes).insertOnConflictUpdate(
      LearnedNotesCompanion.insert(
        shop: shopKey(shop),
        amountMinor: amountMinor,
        note: note,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
