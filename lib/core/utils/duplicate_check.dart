import 'note_utils.dart';

/// How recently a matching expense must have been saved to count as a
/// likely duplicate.
const Duration kDuplicateWindow = Duration(minutes: 10);

/// What the duplicate check compares.
typedef ExpenseKey = ({int amountMinor, String categoryId, String? note});

/// A saved expense: its key and when it was saved.
typedef SavedExpense = ({ExpenseKey key, DateTime savedAt});

/// Whether [candidate] matches an expense saved within [kDuplicateWindow]
/// before [now]: same amount, same category and the same note (compared
/// after trimming; no note matches no note).
bool looksLikeDuplicateOf(
  ExpenseKey candidate,
  Iterable<SavedExpense> saved,
  DateTime now,
) {
  final note = cleanNote(candidate.note);
  final since = now.subtract(kDuplicateWindow);
  return saved.any(
    (s) =>
        !s.savedAt.isBefore(since) &&
        !s.savedAt.isAfter(now) &&
        s.key.amountMinor == candidate.amountMinor &&
        s.key.categoryId == candidate.categoryId &&
        cleanNote(s.key.note) == note,
  );
}
