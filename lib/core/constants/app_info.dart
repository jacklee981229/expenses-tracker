/// Shown in Settings > About. Keep in sync with `version:` in pubspec.yaml.
const String kAppVersion = '1.0.0';
const String kAppBuildNumber = '1';

/// The SQLite file in the app documents directory (included in iOS backups).
const String kDatabaseFileName = 'expenses.sqlite';

/// The ledger shows a backup banner once the last export is this old.
const int kExportNudgeDays = 14;

/// The `version` field written to, and required in, JSON backups.
const int kBackupFormatVersion = 1;

/// How long Undo stays offered after deleting an expense.
const Duration kUndoDuration = Duration(seconds: 5);
