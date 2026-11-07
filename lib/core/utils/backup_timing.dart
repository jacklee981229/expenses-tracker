import '../constants/app_info.dart';

/// When the app checks whether to upload a cloud backup.
enum BackupMoment {
  /// Sent home or switched away from: the changes just made go up.
  hidden,

  /// Started or brought back: catches up after a failed or missed upload.
  opened,
}

/// Whether to upload a cloud backup now. Never without a token, on a phone
/// not set up here (an empty reinstall must not write over the good
/// copies), or with no expenses. Hiding uploads at most once every
/// [kCloudBackupGap] from the last try; opening uploads when the last good
/// upload is older than [kCloudBackupStale], so a failed one is retried at
/// once. A time in the future (the clock was changed) counts as long ago.
bool shouldUploadBackup({
  required BackupMoment moment,
  required bool hasToken,
  required bool setUp,
  required int expenseCount,
  required int? lastTryAt,
  required int? lastGoodAt,
  required DateTime now,
}) {
  if (!hasToken || !setUp || expenseCount == 0) return false;
  return switch (moment) {
    BackupMoment.hidden => !_within(lastTryAt, kCloudBackupGap, now),
    BackupMoment.opened => !_within(lastGoodAt, kCloudBackupStale, now),
  };
}

bool _within(int? epochMs, Duration span, DateTime now) {
  if (epochMs == null) return false;
  final since = now.difference(DateTime.fromMillisecondsSinceEpoch(epochMs));
  return !since.isNegative && since < span;
}
