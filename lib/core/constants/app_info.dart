/// Shown in Settings > About. Keep in sync with `version:` in pubspec.yaml.
const String kAppVersion = '1.0.0';
const String kAppBuildNumber = '1';

/// The SQLite file in the app documents directory (included in iOS backups).
const String kDatabaseFileName = 'expenses.sqlite';

/// The ledger shows a backup banner once the last export is this old.
const int kExportNudgeDays = 14;

/// The `version` field written to, and required in, JSON backups.
const int kBackupFormatVersion = 1;

/// The cloud backup Worker (`backup-worker/`). A laptop run points it at a
/// local copy with `--dart-define=BACKUP_URL=http://10.0.2.2:8793`.
const String kBackupUrl = String.fromEnvironment(
  'BACKUP_URL',
  defaultValue: 'https://expenses-backup.jacklee981229.workers.dev',
);

/// Hiding the app uploads at most this often (counted from the last try).
const Duration kCloudBackupGap = Duration(minutes: 10);

/// Opening the app uploads when the last good upload is this old.
const Duration kCloudBackupStale = Duration(days: 1);

/// How long one call to the backup Worker may take.
const Duration kCloudBackupTimeout = Duration(seconds: 20);

/// How long Undo stays offered after deleting an expense.
const Duration kUndoDuration = Duration(seconds: 5);

/// How long the add sheet's title shows what reading a screenshot found
/// (`No amount found`) before going back to `New Expense`.
const Duration kScanNoticeDuration = Duration(seconds: 3);

/// The path of the `expenses://app/scan` link the Back Tap shortcut opens.
const String kScanLinkPath = '/scan';

/// A delivery receipt goes to the category with this icon (Food, unless
/// Jack renamed it).
const String kFoodIconKey = 'food';
