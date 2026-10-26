/// All user-facing copy. Widget code never contains string literals.
library;

/// The only currency. It is not a setting and never comes from the locale.
const String kCurrencySymbol = 'RM';

/// `RM ` in front of an amount field.
const String kCurrencyPrefix = '$kCurrencySymbol ';

abstract final class AppStrings {
  static const String appTitle = 'Expenses';

  /// An amount with the currency in front, no space: `RM12.50`.
  static String withCurrency(String amount) => '$kCurrencySymbol$amount';

  // Root shell
  static const String tabLedger = 'Ledger';
  static const String tabAnalysis = 'Analysis';
  static const String addExpense = 'Add expense';

  // Shared actions
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String done = 'Done';
  static const String delete = 'Delete';
  static const String ok = 'OK';
  static const String dismiss = 'Dismiss';
  static const String previous = 'Previous';
  static const String next = 'Next';

  // Dates
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';
  static const String chooseDate = 'Choose date';
  static const String chooseMonth = 'Choose month';

  /// Indexed by ISO weekday - 1 (Monday first).
  static const List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// A week of the month on the total card's bars: `W1` is days 1–7.
  static String weekOfMonth(int week) => 'W$week';

  // Ledger
  static const String ledgerKicker = 'My ledger';
  static const String spentThisMonth = 'Spent this month';
  static String spentIn(String month) => 'Spent in $month';
  static const String receiptTotal = 'TOTAL';
  static const String todayBadge = 'TODAY';
  static const String allCategories = 'All categories';
  static const String clearCategoryFilter = 'Show all categories';
  static const String thisMonth = 'This Month';
  static String timeAndDetail(String time, String detail) => '$time · $detail';
  static const String settingsTooltip = 'Settings';
  static const String noExpensesThisMonth = 'No expenses this month';
  static const String exportNudgeNever = 'Back up your data — no export yet';
  static String exportNudge(int days) =>
      'Back up your data — last export was $days '
      '${days == 1 ? 'day' : 'days'} ago';
  static const String deleted = 'Deleted';
  static const String undo = 'Undo';
  static const String again = 'Again';

  // Reading a screenshot
  static const String scanScreenshot = 'Read a screenshot';
  static const String scanReading = 'Reading…';
  static const String scanNoAmount = 'No amount found';
  static const String scanNoPicture = 'No picture on the clipboard';
  static const String search = 'Search';
  static const String searchHint = 'Note, category or amount';
  static const String searchPrompt =
      'Search every month by note, category or amount.';
  static const String noSearchResults = 'No expenses match';
  static String searchResultCount(int count, String total) =>
      '${count == 1 ? '1 expense' : '$count expenses'} · $total';
  static const String recurringTooltip = 'Fixed monthly expense';

  // Add expense sheet
  static const String newExpense = 'New Expense';
  static const String editExpense = 'Edit Expense';
  static const String saveAndAdd = 'Save & Add';
  static const String notePlaceholder = 'Add a note';
  static const String newCategoryCell = 'New';
  static const String closeSheet = 'Close';
  static const String backspace = 'Delete digit';
  static const String keyPlus = '+';
  static const String keyMinus = '−';
  static const String keyDecimal = '.';
  static String expressionResult(String amount) => '= $amount';
  static const String duplicateTitle = 'Save it again?';
  static const String duplicateMessage =
      'You saved one with the same amount, category and note a few minutes '
      'ago.';
  static const String saveAgain = 'Save Again';
  static const String saved = 'Saved';

  // Analysis
  static const String analysisKicker = 'Insights';
  static const String spentStat = 'Spent';
  static const String perDayStat = 'Per day';
  static const String trendTitle = 'Last 6 months';

  /// The summary line's comparison: `Food: 12% more than last month`.
  static String insightMore(String category, int percent, String period) =>
      '$category: $percent% more than last $period';
  static String insightLess(String category, int percent, String period) =>
      '$category: $percent% less than last $period';

  /// `Travel: new this month, RM45.00`
  static String insightNew(String category, String amount, String period) =>
      '$category: new this $period, $amount';

  /// `Food: same as last month`
  static String insightSame(String category, String period) =>
      '$category: same as last $period';

  /// With nothing to compare: `Food: RM100.18, 85% of spending`
  static String insightShare(String category, String amount, int percent) =>
      '$category: $amount, $percent% of spending';

  /// `Biggest day: 24 Sep, RM72.58`
  static String insightBiggestDay(String day, String amount) =>
      'Biggest day: $day, $amount';
  static const String insightWeek = 'week';
  static const String insightMonth = 'month';
  static const String insightYear = 'year';
  static const String periodWeek = 'Week';
  static const String periodMonth = 'Month';
  static const String periodYear = 'Year';
  static const String periodAll = 'All';
  static const String allTime = 'All time';
  static const String expenseStat = 'Expense';
  static const String filter = 'Filter';
  static const String filterCategories = 'Filter Categories';
  static const String filterHint =
      'Show only these categories in the chart and list.';
  static const String clearFilter = 'Clear';
  static const String otherSlice = 'Other';
  static const String noExpensesInPeriod = 'No expenses in this period';
  static String expenseCount(int count) =>
      count == 1 ? '1 expense' : '$count expenses';

  // Categories
  static const String manageCategories = 'Manage Categories';
  static const String newCategoryTitle = 'New Category';
  static const String editCategoryTitle = 'Edit Category';
  static const String categoryNamePlaceholder = 'Category name';
  static const String iconLabel = 'Icon';
  static const String colourLabel = 'Colour';
  static const String archive = 'Archive';
  static const String restore = 'Restore';
  static String archivedSection(int count) => 'Archived ($count)';
  static const String deleteCategory = 'Delete Category';
  static const String deleteCategoryTitle = 'Delete this category?';
  static const String categoryInUseFootnote =
      'This category is used by expenses or fixed monthly expenses, so it can '
      'be archived but not deleted.';
  static const String categoriesFootnote =
      'Drag to reorder. Swipe left to archive. Archived categories keep their '
      'expenses but are hidden when adding new ones.';

  // Fixed monthly expenses
  static const String fixedMonthlyExpenses = 'Fixed Monthly Expenses';
  static const String newFixedExpense = 'New Fixed Expense';
  static const String editFixedExpense = 'Edit Fixed Expense';
  static const String noFixedExpenses = 'No fixed monthly expenses';
  static const String addFixedExpense = 'Add Fixed Expense';
  static String everyMonthOn(int day) => 'Monthly on the ${_ordinal(day)}';
  static String categoryAndSchedule(String category, String schedule) =>
      '$category · $schedule';
  static const String paused = 'Paused';
  static const String amountLabel = 'Amount';
  static const String categoryLabel = 'Category';
  static const String noteLabel = 'Note';
  static const String dayOfMonthLabel = 'Day of month';
  static const String startMonthLabel = 'Starts';
  static const String endMonthLabel = 'Ends';
  static const String never = 'Never';
  static const String activeLabel = 'Active';
  static const String chooseCategory = 'Choose';
  static const String recurringEditFootnote =
      'Changes apply to future months only. Expenses already added are not '
      'changed. A day past the end of a month uses that month\'s last day.';
  static const String deleteFixedExpense = 'Delete Fixed Expense';
  static const String deleteRuleTitle = 'Delete this fixed expense?';
  static const String deleteRuleMessage =
      'Expenses it already added stay in the ledger.';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String sectionData = 'Data';
  static const String sectionPreferences = 'Preferences';
  static const String sectionBackup = 'Backup';
  static const String sectionAbout = 'About';
  static const String firstDayOfWeek = 'First day of week';
  static const String appearance = 'Appearance';
  static const String appearanceSystem = 'System';
  static const String appearanceLight = 'Light';
  static const String appearanceDark = 'Dark';
  static const String exportCsv = 'Export CSV';
  static const String exportJson = 'Export JSON';
  static const String importJson = 'Import JSON';
  static String lastExport(String date) => 'Last export: $date';
  static const String lastExportNever = 'Last export: never';
  static const String version = 'Version';
  static const String build = 'Build';

  // Backup
  static const String importTitle = 'Import backup';
  static String importSummary(int categories, int rules, int expenses) =>
      'This file has ${_count(categories, 'category', 'categories')}, '
      '${_count(rules, 'fixed monthly expense', 'fixed monthly expenses')} '
      'and ${_count(expenses, 'expense', 'expenses')}. Merge adds the ones '
      'that are not here yet. Replace deletes everything here first.';
  static const String importMerge = 'Merge';
  static const String importReplace = 'Replace';
  static String importDone(int expenses) =>
      'Import complete: $expenses ${expenses == 1 ? 'expense' : 'expenses'}';
  static const String importFailedTitle = 'Import failed';
  static const String importInvalidFile = 'This file is not a valid backup.';
  static String importUnsupportedVersion(Object? version) =>
      'This backup is version $version, which this app cannot read.';
  static const String importNothingChanged = 'Nothing was changed.';
  static String importFailure(String reason) => '$reason $importNothingChanged';
  static const String exportFailedTitle = 'Export failed';
  static const String exported = 'Exported';
}

String _count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

String _ordinal(int n) {
  final lastTwo = n % 100;
  if (lastTwo >= 11 && lastTwo <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}
