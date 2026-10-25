import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/amount_input.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/duplicate_check.dart';
import '../../core/utils/money.dart';
import '../../core/utils/note_utils.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../shared/today_provider.dart';

/// The expense being edited (null for a new one), the category a new
/// expense starts with, and an expense to copy into a new one (Again).
typedef AddExpenseArgs = ({
  Expense? editing,
  String? defaultCategoryId,
  Expense? template,
});

@immutable
class AddExpenseState {
  const AddExpenseState({
    required this.expression,
    required this.categoryId,
    required this.note,
    required this.date,
    this.editing,
    this.replaceOnInput = false,
    this.saving = false,
    this.categoryTapped = false,
  });

  /// Keypad expression, e.g. `12.50+3`.
  final String expression;
  final String? categoryId;
  final String note;

  /// Local midnight of the chosen day.
  final DateTime date;
  final Expense? editing;

  /// When editing, the first digit typed replaces the prefilled amount.
  final bool replaceOnInput;
  final bool saving;

  /// Whether a category was tapped in this sheet; a typed note then no
  /// longer switches the category.
  final bool categoryTapped;

  bool get isEditing => editing != null;

  int? get amountMinor => evaluateAmountExpression(expression);

  /// Whether the display should show the resolved total under the expression.
  bool get showsResult => hasOperator(expression);

  /// Save stays disabled while the amount resolves to zero (or below).
  bool get canSave => !saving && categoryId != null && (amountMinor ?? 0) > 0;

  AddExpenseState copyWith({
    String? expression,
    String? categoryId,
    String? note,
    DateTime? date,
    bool? replaceOnInput,
    bool? saving,
    bool? categoryTapped,
  }) {
    return AddExpenseState(
      expression: expression ?? this.expression,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      editing: editing,
      replaceOnInput: replaceOnInput ?? this.replaceOnInput,
      saving: saving ?? this.saving,
      categoryTapped: categoryTapped ?? this.categoryTapped,
    );
  }
}

/// Every distinct note used in a category, best first: often and recently
/// used notes lead, and notes usually used around now get a lift.
final noteHistoryProvider = StreamProvider.autoDispose
    .family<List<String>, String>(
      (ref, categoryId) => ref
          .watch(transactionDaoProvider)
          .watchNoteUses(categoryId)
          .map((uses) => rankNotes(uses, DateTime.now())),
    );

final addExpenseControllerProvider = NotifierProvider.autoDispose
    .family<AddExpenseController, AddExpenseState, AddExpenseArgs>(
      AddExpenseController.new,
    );

class AddExpenseController
    extends AutoDisposeFamilyNotifier<AddExpenseState, AddExpenseArgs> {
  @override
  AddExpenseState build(AddExpenseArgs arg) {
    final editing = arg.editing;
    if (editing != null) {
      return AddExpenseState(
        expression: formatMinor(editing.amountMinor, grouping: false),
        categoryId: editing.categoryId,
        note: editing.note ?? '',
        date: parseLocalDate(editing.localDate),
        editing: editing,
        replaceOnInput: true,
      );
    }
    final template = arg.template;
    if (template != null) {
      return AddExpenseState(
        expression: formatMinor(template.amountMinor, grouping: false),
        categoryId: arg.defaultCategoryId,
        note: template.note ?? '',
        date: ref.read(todayProvider),
        replaceOnInput: true,
      );
    }
    return AddExpenseState(
      expression: '',
      categoryId: arg.defaultCategoryId,
      note: '',
      date: ref.read(todayProvider),
    );
  }

  void digit(String digit) =>
      _edit((expression) => appendDigit(expression, digit), replaces: true);

  void decimalPoint() => _edit(appendDecimalPoint, replaces: true);

  void applyOperator(String symbol) => _edit(
    (expression) => appendOperator(expression, symbol),
    replaces: false,
  );

  void backspace() => _edit(removeLastCharacter, replaces: false);

  void _edit(String Function(String) change, {required bool replaces}) {
    final base = state.replaceOnInput && replaces ? '' : state.expression;
    state = state.copyWith(expression: change(base), replaceOnInput: false);
  }

  /// A category picked in the sheet ([tapped]) or set for it (a new
  /// category, a note's last category).
  void selectCategory(String id, {bool tapped = true}) => state = state
      .copyWith(categoryId: id, categoryTapped: state.categoryTapped || tapped);

  void setNote(String note) {
    if (note != state.note) state = state.copyWith(note: note);
  }

  /// A note typed by hand: when it was used before, switch to the category
  /// it was last used with, unless a category was tapped in this sheet or
  /// an existing expense is being edited.
  Future<void> typeNote(String note) async {
    setNote(note);
    final cleaned = cleanNote(note);
    if (cleaned == null || state.categoryTapped || state.isEditing) return;
    final categoryId = await ref
        .read(transactionDaoProvider)
        .lastCategoryForNote(cleaned);
    // The note may have changed while the lookup ran.
    if (categoryId == null || state.note != note || state.categoryTapped) {
      return;
    }
    if (categoryId != state.categoryId) {
      selectCategory(categoryId, tapped: false);
    }
  }

  /// Whether saving now would repeat an expense saved in the last few
  /// minutes (same amount, category and note). Never for an edit.
  Future<bool> looksLikeDuplicate() async {
    final amount = state.amountMinor;
    final categoryId = state.categoryId;
    if (state.isEditing || amount == null || categoryId == null) return false;
    final now = DateTime.now();
    final recent = await ref
        .read(transactionDaoProvider)
        .savedSince(now.subtract(kDuplicateWindow));
    return looksLikeDuplicateOf(
      (amountMinor: amount, categoryId: categoryId, note: state.note),
      [
        for (final expense in recent)
          (
            key: (
              amountMinor: expense.amountMinor,
              categoryId: expense.categoryId,
              note: expense.note,
            ),
            savedAt: DateTime.fromMillisecondsSinceEpoch(expense.createdAt),
          ),
      ],
      now,
    );
  }

  void setDate(DateTime date) => state = state.copyWith(date: dateOnly(date));

  /// Saves the expense and returns whether it did. With [addAnother] the
  /// amount and note reset for the next entry; category and date stay.
  Future<bool> save({bool addAnother = false}) async {
    final amount = state.amountMinor;
    final categoryId = state.categoryId;
    if (!state.canSave || amount == null || categoryId == null) return false;

    state = state.copyWith(saving: true);
    final dao = ref.read(transactionDaoProvider);
    final editing = state.editing;
    try {
      if (editing == null) {
        await dao.insertExpense(
          amountMinor: amount,
          categoryId: categoryId,
          occurredAt: _occurredAt(),
          note: state.note,
        );
      } else {
        await dao.updateExpense(
          id: editing.id,
          amountMinor: amount,
          categoryId: categoryId,
          occurredAt: _occurredAt(),
          note: state.note,
        );
      }
    } finally {
      state = state.copyWith(saving: false);
    }
    if (addAnother) state = state.copyWith(expression: '', note: '');
    return true;
  }

  /// The chosen day at the current time of day. An edit keeps its original
  /// time, and its original timestamp when the day did not change.
  DateTime _occurredAt() {
    final date = state.date;
    final editing = state.editing;
    final DateTime time;
    if (editing != null) {
      final original = DateTime.fromMillisecondsSinceEpoch(editing.occurredAt);
      if (dateOnly(original) == date) return original;
      time = original;
    } else {
      time = DateTime.now();
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );
  }
}
