import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/amount_input.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../shared/today_provider.dart';

/// The expense being edited (null for a new one), and the category a new
/// expense starts with.
typedef AddExpenseArgs = ({Expense? editing, String? defaultCategoryId});

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
  }) {
    return AddExpenseState(
      expression: expression ?? this.expression,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      editing: editing,
      replaceOnInput: replaceOnInput ?? this.replaceOnInput,
      saving: saving ?? this.saving,
    );
  }
}

/// Every distinct note used in a category, most recently used first.
final noteHistoryProvider = StreamProvider.autoDispose
    .family<List<String>, String>(
      (ref, categoryId) =>
          ref.watch(transactionDaoProvider).watchNoteHistory(categoryId),
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

  void selectCategory(String id) => state = state.copyWith(categoryId: id);

  void setNote(String note) {
    if (note != state.note) state = state.copyWith(note: note);
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
