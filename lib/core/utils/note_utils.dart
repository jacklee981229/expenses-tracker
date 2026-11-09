import 'dart:math' as math;

/// Trims a note; an empty note becomes null. Case is never changed, because
/// history chips match notes exactly (`mamak` and `Mamak` are two chips).
String? cleanNote(String? note) {
  final trimmed = note?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

/// One past use of a note: when the expense happened.
typedef NoteUse = ({String note, DateTime at});

/// A use's weight halves every [_halfLifeDays]: a note used often last year
/// still shows, but last week's habits come first.
const double _halfLifeDays = 30;

/// Uses within this many hours of the current time of day count double, so
/// breakfast notes lead in the morning and dinner notes in the evening.
const int _sameTimeWindowHours = 2;

/// Distinct notes, best first: each use adds a weight that fades with age,
/// doubled when it happened around this time of day. Ties go to the more
/// recently used note, then alphabetical order, so the order is stable.
List<String> rankNotes(Iterable<NoteUse> uses, DateTime now) {
  final scores = <String, double>{};
  final lastUsed = <String, DateTime>{};
  for (final use in uses) {
    final ageDays = math.max(0, now.difference(use.at).inMinutes) / 1440;
    var weight = math.pow(0.5, ageDays / _halfLifeDays).toDouble();
    if (_hoursApart(use.at, now) <= _sameTimeWindowHours) weight *= 2;
    scores.update(use.note, (s) => s + weight, ifAbsent: () => weight);
    final previous = lastUsed[use.note];
    if (previous == null || use.at.isAfter(previous)) {
      lastUsed[use.note] = use.at;
    }
  }
  return scores.keys.toList()..sort((a, b) {
    final byScore = scores[b]!.compareTo(scores[a]!);
    if (byScore != 0) return byScore;
    final byRecency = lastUsed[b]!.compareTo(lastUsed[a]!);
    if (byRecency != 0) return byRecency;
    return a.compareTo(b);
  });
}

/// Distance between two times of day in hours, across midnight (23:00 and
/// 01:00 are 2 hours apart).
double _hoursApart(DateTime a, DateTime b) {
  final minutesA = a.hour * 60 + a.minute;
  final minutesB = b.hour * 60 + b.minute;
  final diff = (minutesA - minutesB).abs();
  return math.min(diff, 1440 - diff) / 60;
}

/// The [notes] with a word starting with what Jack [typed] (`p` keeps
/// `Panmee`, `i` keeps `Kopi ice`), case ignored, in their order. Nothing
/// typed keeps them all.
List<String> notesStartingWith(List<String> notes, String typed) {
  final query = typed.trim().toLowerCase();
  if (query.isEmpty) return notes;
  return [
    for (final note in notes)
      if (_startsAWord(note.toLowerCase(), query)) note,
  ];
}

// A Chinese character is a word of its own: `肉` keeps `猪肉面`.
final RegExp _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);
final RegExp _han = RegExp(r'\p{Script=Han}', unicode: true);

/// Whether [query] sits in [note] at the start of a word: at the start, or
/// after a space, a dash or other mark, or anywhere for Chinese.
bool _startsAWord(String note, String query) {
  if (_han.hasMatch(query[0])) return note.contains(query);
  for (
    var at = note.indexOf(query);
    at >= 0;
    at = note.indexOf(query, at + 1)
  ) {
    if (at == 0 || !_wordChar.hasMatch(note[at - 1])) return true;
  }
  return false;
}
