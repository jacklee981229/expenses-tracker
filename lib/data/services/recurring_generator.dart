import '../../core/utils/date_utils.dart';
import '../database/app_database.dart';
import '../database/tables/transactions_table.dart';

/// Turns fixed monthly rules into expenses. Runs on app start and resume.
///
/// `lastGeneratedMonth` is the only idempotency guard: a generated expense
/// the user deletes is not recreated. Each rule's catch-up, including the
/// guard update, runs in one database transaction.
class RecurringGenerator {
  RecurringGenerator(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Set while a catch-up runs, so overlapping calls (start and resume at
  /// the same moment) share one run instead of racing.
  Future<int>? _running;

  /// Generates every due month for every active rule, up to and including
  /// the current month. Returns the number of expenses added.
  Future<int> catchUp() {
    return _running ??= _catchUpAll().whenComplete(() => _running = null);
  }

  Future<int> _catchUpAll() async {
    final currentMonth = toMonthKey(_clock());
    var added = 0;
    for (final rule in await _db.recurringDao.getActive()) {
      added += await _catchUpRule(rule.id, currentMonth);
    }
    return added;
  }

  Future<int> _catchUpRule(String ruleId, String currentMonth) {
    return _db.transaction(() async {
      // Re-read inside the transaction so the guard is current.
      final rule = await _db.recurringDao.findById(ruleId);
      if (rule == null || !rule.isActive) return 0;

      final endMonth = rule.endMonth;
      var cursor = firstMonthToGenerate(rule);
      var added = 0;
      while (cursor.compareTo(currentMonth) <= 0 &&
          (endMonth == null || cursor.compareTo(endMonth) <= 0)) {
        await _db.transactionDao.insertExpense(
          amountMinor: rule.amountMinor,
          categoryId: rule.categoryId,
          occurredAt: dateInMonth(cursor, rule.dayOfMonth),
          note: rule.note,
          source: TransactionSource.recurring,
          recurringRuleId: rule.id,
        );
        await _db.recurringDao.setLastGeneratedMonth(rule.id, cursor);
        added++;
        cursor = nextMonthKey(cursor);
      }
      return added;
    });
  }

  /// The month after the last generated one, but never before the rule's
  /// start month, so a start month moved later by an edit is honoured.
  static String firstMonthToGenerate(RecurringRule rule) {
    final last = rule.lastGeneratedMonth;
    if (last == null) return rule.startMonth;
    final next = nextMonthKey(last);
    return next.compareTo(rule.startMonth) < 0 ? rule.startMonth : next;
  }

  /// The guard to store when a paused rule is switched back on: generation
  /// resumes from the current month instead of back-filling the months the
  /// rule was paused.
  static String lastGeneratedOnResume(String? lastGenerated, DateTime now) {
    final previous = previousMonthKey(toMonthKey(now));
    if (lastGenerated == null || lastGenerated.compareTo(previous) < 0) {
      return previous;
    }
    return lastGenerated;
  }
}
