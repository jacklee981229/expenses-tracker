import 'package:expense_tracker/core/utils/month_palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const october = [
    ('rent', 90500),
    ('food', 18630),
    ('groceries', 9250),
    ('petrol', 6000),
    ('transport', 4800),
  ];

  group('fieldBlobs', () {
    test('takes the top four, sized by share within the nudge', () {
      final blobs = fieldBlobs(october);
      expect(blobs.map((b) => b.categoryId), [
        'rent',
        'food',
        'groceries',
        'petrol',
      ]);
      // Rent is 70% of the month but only reaches the cap.
      expect(blobs[0].scale, 1 + kBlobNudge);
      expect(blobs[1].scale, closeTo(0.9364, 0.0001));
      expect(blobs[2].scale, closeTo(0.8926, 0.0001));
      expect(blobs[3].scale, closeTo(0.8776, 0.0001));
    });

    test('an even split keeps every blob at its base size', () {
      final blobs = fieldBlobs([
        ('a', 100),
        ('b', 100),
        ('c', 100),
        ('d', 100),
      ]);
      expect(blobs.every((b) => b.scale == 1), isTrue);
    });

    test('never leaves the nudge range', () {
      final blobs = fieldBlobs([('big', 1000000), ('tiny', 1)]);
      expect(blobs[0].scale, 1 + kBlobNudge);
      expect(blobs[1].scale, 1 - kBlobNudge);
    });

    test('an empty month is four theme gaps', () {
      expect(fieldBlobs(const []), List.filled(4, const FieldBlob(null, 0.85)));
    });

    test('a one-category month fills the rest with gaps', () {
      final blobs = fieldBlobs([('rent', 90500)]);
      expect(blobs[0], const FieldBlob('rent', 1 + kBlobNudge));
      expect(blobs.skip(1).every((b) => b.categoryId == null), isTrue);
    });

    test('skips refunds and empty categories, keeps ties in order', () {
      final blobs = fieldBlobs([
        ('refund', -500),
        ('zero', 0),
        ('first', 300),
        ('second', 300),
      ]);
      expect(blobs.map((b) => b.categoryId), ['first', 'second', null, null]);
    });
  });

  group('topShares', () {
    test('whole percents of the month, largest first', () {
      expect(topShares(october), [
        ('rent', 70),
        ('food', 14),
        ('groceries', 7),
      ]);
    });

    test('rounds half up', () {
      expect(topShares([('a', 7), ('b', 1)]), [('a', 88), ('b', 13)]);
      expect(topShares([('a', 2), ('b', 1)]), [('a', 67), ('b', 33)]);
    });

    test('fewer categories than asked, or none', () {
      expect(topShares([('only', 1250)]), [('only', 100)]);
      expect(topShares(const []), isEmpty);
      expect(topShares([('refund', -200)]), isEmpty);
    });
  });
}
