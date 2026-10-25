import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toLocalDateString', () {
    test('uses the local calendar date, even late at night', () {
      expect(toLocalDateString(DateTime(2026, 9, 4, 23, 59)), '2026-09-04');
      expect(toLocalDateString(DateTime(2026, 9, 5, 0, 1)), '2026-09-05');
      expect(toLocalDateString(DateTime(2026, 1, 1)), '2026-01-01');
    });

    test('converts UTC to local time before taking the date', () {
      final utc = DateTime.utc(2026, 9, 4, 20, 30);
      final local = utc.toLocal();
      expect(
        toLocalDateString(utc),
        toLocalDateString(DateTime(local.year, local.month, local.day)),
      );
    });
  });

  group('weekBounds', () {
    // 2026-09-23 is a Wednesday.
    final wednesday = DateTime(2026, 9, 23, 15);

    test('starts on Monday by default', () {
      expect(weekBounds(wednesday), ('2026-09-21', '2026-09-27'));
    });

    test('honours a Sunday week start', () {
      expect(weekBounds(wednesday, firstDayOfWeek: DateTime.sunday), (
        '2026-09-20',
        '2026-09-26',
      ));
    });

    test('honours a Saturday week start', () {
      expect(weekBounds(wednesday, firstDayOfWeek: DateTime.saturday), (
        '2026-09-19',
        '2026-09-25',
      ));
    });

    test('includes the first and last day of the week itself', () {
      expect(weekBounds(DateTime(2026, 9, 21)), ('2026-09-21', '2026-09-27'));
      expect(weekBounds(DateTime(2026, 9, 27, 23)), (
        '2026-09-21',
        '2026-09-27',
      ));
    });

    test('crosses month and year boundaries', () {
      expect(weekBounds(DateTime(2026, 10, 1)), ('2026-09-28', '2026-10-04'));
      expect(weekBounds(DateTime(2027, 1, 1)), ('2026-12-28', '2027-01-03'));
    });
  });

  group('monthBounds', () {
    test('covers the whole month', () {
      expect(monthBounds(DateTime(2026, 9, 15)), ('2026-09-01', '2026-09-30'));
      expect(monthBounds(DateTime(2026, 12, 31)), ('2026-12-01', '2026-12-31'));
    });

    test('handles February in leap and common years', () {
      expect(monthBounds(DateTime(2028, 2, 10)), ('2028-02-01', '2028-02-29'));
      expect(monthBounds(DateTime(2026, 2, 10)), ('2026-02-01', '2026-02-28'));
    });
  });

  test('yearBounds covers 1 Jan to 31 Dec', () {
    expect(yearBounds(DateTime(2026, 6, 1)), ('2026-01-01', '2026-12-31'));
  });

  group('daysInMonth', () {
    test('knows month lengths', () {
      expect(daysInMonth(2026, 1), 31);
      expect(daysInMonth(2026, 4), 30);
      expect(daysInMonth(2026, 12), 31);
    });

    test('follows leap-year rules for February', () {
      expect(daysInMonth(2024, 2), 29);
      expect(daysInMonth(2026, 2), 28);
      expect(daysInMonth(2000, 2), 29);
      expect(daysInMonth(2100, 2), 28);
    });
  });

  group('month keys', () {
    test('toMonthKey formats YYYY-MM', () {
      expect(toMonthKey(DateTime(2026, 9, 5)), '2026-09');
      expect(toMonthKey(DateTime(2027, 1, 31)), '2027-01');
    });

    test('next and previous cross year boundaries', () {
      expect(nextMonthKey('2026-12'), '2027-01');
      expect(nextMonthKey('2026-09'), '2026-10');
      expect(previousMonthKey('2027-01'), '2026-12');
    });

    test('dateInMonth clamps to the last day of the month', () {
      expect(dateInMonth('2026-09', 15), DateTime(2026, 9, 15));
      expect(dateInMonth('2026-09', 31), DateTime(2026, 9, 30));
      expect(dateInMonth('2026-02', 31), DateTime(2026, 2, 28));
      expect(dateInMonth('2028-02', 30), DateTime(2028, 2, 29));
    });
  });

  test('calendarDaysBetween ignores the time of day', () {
    expect(
      calendarDaysBetween(DateTime(2026, 9, 1, 23), DateTime(2026, 9, 2, 1)),
      1,
    );
    expect(
      calendarDaysBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 15)),
      14,
    );
    expect(calendarDaysBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 1)), 0);
  });

  test('formatDateRange shortens same-month and same-year ranges', () {
    expect(formatDateRange('2026-09-01', '2026-09-07'), '1–7 Sep 2026');
    expect(formatDateRange('2026-09-28', '2026-10-04'), '28 Sep – 4 Oct 2026');
    expect(
      formatDateRange('2026-12-28', '2027-01-03'),
      '28 Dec 2026 – 3 Jan 2027',
    );
  });
}
