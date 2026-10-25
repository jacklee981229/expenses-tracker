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
