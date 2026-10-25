import 'package:expense_tracker/core/utils/note_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 25, 8, 30);

  NoteUse use(String note, DateTime at) => (note: note, at: at);

  group('rankNotes', () {
    test('a note used often beats one used once', () {
      final ranked = rankNotes([
        use('Lunch', DateTime(2026, 10, 24, 13)),
        use('Nasi lemak', DateTime(2026, 10, 20, 13)),
        use('Nasi lemak', DateTime(2026, 10, 21, 13)),
        use('Nasi lemak', DateTime(2026, 10, 22, 13)),
      ], now);
      expect(ranked, ['Nasi lemak', 'Lunch']);
    });

    test('old uses fade: last week beats the same count last year', () {
      final ranked = rankNotes([
        use('Old', DateTime(2025, 10, 1, 13)),
        use('Old', DateTime(2025, 10, 2, 13)),
        use('New', DateTime(2026, 10, 18, 13)),
        use('New', DateTime(2026, 10, 19, 13)),
      ], now);
      expect(ranked, ['New', 'Old']);
    });

    test('uses around this time of day count double', () {
      final ranked = rankNotes([
        use('Dinner', DateTime(2026, 10, 24, 19)),
        use('Teh tarik', DateTime(2026, 10, 24, 8)),
      ], now);
      expect(ranked.first, 'Teh tarik');
    });

    test('time of day wraps around midnight', () {
      final late = DateTime(2026, 10, 25, 23, 30);
      final ranked = rankNotes([
        use('Lunch', DateTime(2026, 10, 24, 12)),
        use('Supper', DateTime(2026, 10, 24, 0, 30)),
      ], late);
      expect(ranked.first, 'Supper');
    });

    test('ties go to the more recent note, then alphabetical', () {
      final at = DateTime(2026, 10, 24, 13);
      expect(rankNotes([use('B', at), use('A', at)], now), ['A', 'B']);
    });

    test('notes are matched exactly; case makes two notes', () {
      final at = DateTime(2026, 10, 24, 13);
      expect(rankNotes([use('mamak', at), use('Mamak', at)], now).length, 2);
    });

    test('no uses gives no notes', () {
      expect(rankNotes(const [], now), isEmpty);
    });
  });

  group('cleanNote', () {
    test('trims and turns blank into null', () {
      expect(cleanNote('  Mamak '), 'Mamak');
      expect(cleanNote('   '), isNull);
      expect(cleanNote(null), isNull);
    });
  });
}
