import '../../core/utils/backup_timing.dart';
import '../../core/utils/date_utils.dart';
import '../database/daos/settings_dao.dart';
import '../database/daos/transaction_dao.dart';
import 'cloud_backup_api.dart';
import 'cloud_backup_store.dart';
import 'export_service.dart';
import 'import_service.dart';

/// Cloud backup on this phone, for Settings: whether a token is kept, and
/// the state in `cloud_backup.json`.
typedef CloudBackupStatus = ({bool hasToken, CloudBackupState state});

/// Uploads the backup file to Jack's Worker by itself, and sets it up,
/// lists, fetches and turns it off for Settings.
class CloudBackup {
  CloudBackup({
    required CloudBackupApi api,
    required CloudBackupTokenStore tokens,
    required CloudBackupStateStore states,
    required ExportService exporter,
    required ImportService importer,
    required SettingsDao settings,
    required TransactionDao transactions,
    DateTime Function()? clock,
  }) : _api = api,
       _tokens = tokens,
       _states = states,
       _exporter = exporter,
       _importer = importer,
       _settings = settings,
       _transactions = transactions,
       _clock = clock ?? DateTime.now;

  final CloudBackupApi _api;
  final CloudBackupTokenStore _tokens;
  final CloudBackupStateStore _states;
  final ExportService _exporter;
  final ImportService _importer;
  final SettingsDao _settings;
  final TransactionDao _transactions;
  final DateTime Function() _clock;

  /// The upload running now, which a second call joins instead of writing
  /// the same key again within a second (KV allows one write a second).
  Future<CloudResult<bool>>? _uploading;

  Future<CloudBackupStatus> status() async =>
      (hasToken: await _tokens.read() != null, state: await _states.read());

  /// Uploads when [shouldUploadBackup] says so; whether it uploaded. Never
  /// throws: a failure waits for the next moment.
  Future<bool> maybeUpload(BackupMoment moment) async {
    try {
      final token = await _tokens.read();
      final state = await _states.read();
      final go = shouldUploadBackup(
        moment: moment,
        hasToken: token != null,
        setUp: state.setUp,
        expenseCount: await _transactions.watchCount().first,
        lastTryAt: state.lastTryAt,
        lastGoodAt: state.lastGoodAt,
        now: _clock(),
      );
      if (!go || token == null) return false;
      return (await _upload(token)).value ?? false;
    } on Object {
      return false;
    }
  }

  /// Back Up Now. `ok(false)` when there are no expenses to back up.
  Future<CloudResult<bool>> uploadNow() async {
    final token = await _tokens.read();
    if (token == null) return const CloudResult.failed(CloudFailure.wrongToken);
    return _upload(token);
  }

  Future<CloudResult<bool>> _upload(String token) =>
      _uploading ??= _send(token).whenComplete(() => _uploading = null);

  Future<CloudResult<bool>> _send(String token) async {
    final now = _clock();
    final backup = await _exporter.buildBackup();
    if (backup.count == 0) return const CloudResult.ok(false);
    final state = await _states.read();
    await _states.write(
      CloudBackupState(
        setUp: state.setUp,
        lastTryAt: now.millisecondsSinceEpoch,
        lastGoodAt: state.lastGoodAt,
      ),
    );
    final result = await _api.upload(
      token: token,
      bytes: backup.bytes,
      day: toLocalDateString(now),
      exportedAt: backup.exportedAt,
      count: backup.count,
    );
    if (result.value ?? false) {
      await _states.write(
        CloudBackupState(
          setUp: state.setUp,
          lastTryAt: now.millisecondsSinceEpoch,
          lastGoodAt: now.millisecondsSinceEpoch,
        ),
      );
      // A cloud backup is a backup: the ledger's banner stops nudging.
      await _settings.setLastExportAt(now.millisecondsSinceEpoch);
    }
    return result;
  }

  /// Sets cloud backup up on this phone with [typed], or with the token kept
  /// from an earlier install when null. The token is checked with a list
  /// (never an upload, which could write an empty phone over the good
  /// copies) and kept only when it works; the list comes back for a restore.
  Future<CloudResult<CloudListing>> turnOn([String? typed]) async {
    final token = typed == null ? await _tokens.read() : tidyToken(typed);
    if (token == null || token.isEmpty) {
      return const CloudResult.failed(CloudFailure.wrongToken);
    }
    final result = await _api.list(token);
    if (result.value != null) {
      await _tokens.write(token);
      await markSetUp();
    }
    return result;
  }

  Future<CloudResult<CloudListing>> list() async {
    final token = await _tokens.read();
    if (token == null) return const CloudResult.failed(CloudFailure.wrongToken);
    return _api.list(token);
  }

  /// Fetches [copy] and reads it as a backup file. Throws what
  /// [ImportService.parse] throws for a bad one.
  Future<CloudResult<BackupData>> fetch(
    CloudListing listing,
    CloudCopy copy,
  ) async {
    final token = await _tokens.read();
    if (token == null) return const CloudResult.failed(CloudFailure.wrongToken);
    final download = await _api.download(token, copyName(listing, copy));
    final bytes = download.value;
    if (bytes == null) return CloudResult.failed(download.failure!);
    return CloudResult.ok(_importer.parse(bytes));
  }

  /// After a restore or Turn On: this phone's data may now go up.
  Future<void> markSetUp() async {
    final state = await _states.read();
    await _states.write(
      CloudBackupState(
        setUp: true,
        lastTryAt: state.lastTryAt,
        lastGoodAt: state.lastGoodAt,
      ),
    );
  }

  /// Forgets the token on this phone; the copies in the cloud stay.
  Future<void> turnOff() async {
    await _tokens.delete();
    await _states.write(const CloudBackupState());
  }
}
