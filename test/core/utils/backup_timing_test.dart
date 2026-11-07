import 'package:expense_tracker/core/utils/backup_timing.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime now = DateTime(2026, 11, 7, 14, 2);

int ago(Duration span) => now.subtract(span).millisecondsSinceEpoch;

bool decide({
  BackupMoment moment = BackupMoment.hidden,
  bool hasToken = true,
  bool setUp = true,
  int expenseCount = 5,
  int? lastTryAt,
  int? lastGoodAt,
}) => shouldUploadBackup(
  moment: moment,
  hasToken: hasToken,
  setUp: setUp,
  expenseCount: expenseCount,
  lastTryAt: lastTryAt,
  lastGoodAt: lastGoodAt,
  now: now,
);

void main() {
  test('hiding uploads when nothing has gone up yet', () {
    expect(decide(), isTrue);
  });

  test('hiding waits 10 minutes from the last try', () {
    final nine = ago(const Duration(minutes: 9));
    final ten = ago(const Duration(minutes: 10));
    expect(decide(lastTryAt: nine, lastGoodAt: nine), isFalse);
    expect(decide(lastTryAt: ten, lastGoodAt: ten), isTrue);
  });

  test('a failed try also waits 10 minutes', () {
    final nine = ago(const Duration(minutes: 9));
    expect(
      decide(lastTryAt: nine, lastGoodAt: ago(const Duration(days: 3))),
      isFalse,
    );
  });

  test('opening uploads only when the last good upload is over a day old', () {
    final hour = ago(const Duration(hours: 1));
    expect(
      decide(moment: BackupMoment.opened, lastTryAt: hour, lastGoodAt: hour),
      isFalse,
    );
    final day = ago(const Duration(days: 1));
    expect(
      decide(moment: BackupMoment.opened, lastTryAt: day, lastGoodAt: day),
      isTrue,
    );
    expect(decide(moment: BackupMoment.opened), isTrue);
  });

  test('opening retries a failed upload after a day without a good one', () {
    expect(
      decide(
        moment: BackupMoment.opened,
        lastTryAt: ago(const Duration(hours: 2)),
        lastGoodAt: ago(const Duration(days: 2)),
      ),
      isTrue,
    );
  });

  test('opening retries at once, even within 10 minutes of a failed try', () {
    expect(
      decide(
        moment: BackupMoment.opened,
        lastTryAt: ago(const Duration(minutes: 5)),
        lastGoodAt: ago(const Duration(days: 2)),
      ),
      isTrue,
    );
  });

  test('never with no expenses, no token, or a phone not set up here', () {
    expect(decide(expenseCount: 0), isFalse);
    expect(decide(hasToken: false), isFalse);
    expect(decide(setUp: false), isFalse);
    expect(decide(moment: BackupMoment.opened, setUp: false), isFalse);
  });

  test('a time in the future (the clock was changed) counts as long ago', () {
    final future = now.add(const Duration(days: 30)).millisecondsSinceEpoch;
    expect(decide(lastTryAt: future, lastGoodAt: future), isTrue);
    expect(
      decide(
        moment: BackupMoment.opened,
        lastTryAt: future,
        lastGoodAt: future,
      ),
      isTrue,
    );
  });
}
