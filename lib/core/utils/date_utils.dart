/// Local-date helpers. Periods are inclusive `YYYY-MM-DD` string bounds, and
/// string comparison on that format is correctly ordered, so SQL never parses
/// dates. Everything uses device local time (Asia/Kuala_Lumpur, no DST).
library;

import 'package:intl/intl.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// `'YYYY-MM-DD'` in device local time.
String toLocalDateString(DateTime dt) {
  final local = dt.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${_two(local.month)}-'
      '${_two(local.day)}';
}

/// `'2026-09-04'` -> local midnight on that date.
DateTime parseLocalDate(String localDate) {
  final parts = localDate.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

/// Local midnight of [dt]'s calendar day.
DateTime dateOnly(DateTime dt) {
  final local = dt.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Inclusive bounds of the week containing [anchor]. [firstDayOfWeek] is an
/// ISO weekday: 1 = Monday ... 7 = Sunday.
(String start, String end) weekBounds(
  DateTime anchor, {
  int firstDayOfWeek = DateTime.monday,
}) {
  final day = dateOnly(anchor);
  final offset = (day.weekday - firstDayOfWeek + 7) % 7;
  final start = DateTime(day.year, day.month, day.day - offset);
  final end = DateTime(start.year, start.month, start.day + 6);
  return (toLocalDateString(start), toLocalDateString(end));
}

(String start, String end) monthBounds(DateTime anchor) {
  final local = anchor.toLocal();
  final last = daysInMonth(local.year, local.month);
  return (
    toLocalDateString(DateTime(local.year, local.month)),
    toLocalDateString(DateTime(local.year, local.month, last)),
  );
}

(String start, String end) yearBounds(DateTime anchor) {
  final year = anchor.toLocal().year.toString().padLeft(4, '0');
  return ('$year-01-01', '$year-12-31');
}

/// `'YYYY-MM'`.
String toMonthKey(DateTime dt) {
  final local = dt.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${_two(local.month)}';
}

/// `'2026-09'` -> 1 September 2026, local midnight.
DateTime monthKeyToDate(String monthKey) {
  final parts = monthKey.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]));
}

String nextMonthKey(String monthKey) {
  final month = monthKeyToDate(monthKey);
  return toMonthKey(DateTime(month.year, month.month + 1));
}

String previousMonthKey(String monthKey) {
  final month = monthKeyToDate(monthKey);
  return toMonthKey(DateTime(month.year, month.month - 1));
}

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Local midnight on [dayOfMonth] of [monthKey], clamped to the month's last
/// day: day 31 in a 30-day month is the 30th, in February the 28th or 29th.
DateTime dateInMonth(String monthKey, int dayOfMonth) {
  final month = monthKeyToDate(monthKey);
  final last = daysInMonth(month.year, month.month);
  return DateTime(month.year, month.month, dayOfMonth.clamp(1, last));
}

/// Whole calendar days from [from] to [to] (local dates, time ignored).
int calendarDaysBetween(DateTime from, DateTime to) {
  final start = dateOnly(from);
  final end = dateOnly(to);
  return DateTime.utc(
    end.year,
    end.month,
    end.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
}

// Display formats (English only).

/// The stamp on top of a day's receipt: `SUN · 25 OCT`.
String formatReceiptStamp(DateTime date) =>
    '${DateFormat('EEE').format(date)} · ${DateFormat('d MMM').format(date)}'
        .toUpperCase();

/// The add sheet's date pill for a day other than today or yesterday:
/// `09/22 Tue`, with the year when it is not [today]'s: `2025/12/31`.
String formatChipDate(DateTime date, DateTime today) => date.year == today.year
    ? DateFormat('MM/dd EEE').format(date)
    : DateFormat('yyyy/MM/dd').format(date);

/// `Sep 2026`
String formatMonthShort(DateTime date) => DateFormat('MMM yyyy').format(date);

/// 24-hour time of day: `18:58`.
String formatTime(DateTime dateTime) => DateFormat('HH:mm').format(dateTime);

/// `4 Sep 2026`
String formatShortDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

/// `September 2026`
String formatMonthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

/// `'2026-09'` -> `Sep 2026`
String formatMonthKey(String monthKey) =>
    DateFormat('MMM yyyy').format(monthKeyToDate(monthKey));

/// Inclusive local-date bounds as a label: `1–7 Sep 2026`,
/// `29 Sep – 5 Oct 2026`, `29 Dec 2025 – 4 Jan 2026`.
String formatDateRange(String start, String end) {
  final from = parseLocalDate(start);
  final to = parseLocalDate(end);
  if (from.year != to.year) {
    return '${formatShortDate(from)} – ${formatShortDate(to)}';
  }
  if (from.month != to.month) {
    return '${DateFormat('d MMM').format(from)} – ${formatShortDate(to)}';
  }
  return '${from.day}–${formatShortDate(to)}';
}
