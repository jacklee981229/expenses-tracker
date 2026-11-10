import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/amount_input.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/duplicate_check.dart';
import '../../core/utils/money.dart';
import '../../core/utils/note_utils.dart';
import '../../core/utils/learned_notes.dart';
import '../../core/utils/receipt_kinds.dart';
import '../../core/utils/receipt_parser.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../shared/field_pulse_provider.dart';
import '../../shared/today_provider.dart';

/// The expense being edited (null for a new one), the category a new
/// expense starts with, an expense to copy into a new one (Again), and the
/// sheet itself, so two open sheets (the scan link opening one over another)
/// never share an entry.
typedef AddExpenseArgs = ({
  Expense? editing,
  String? defaultCategoryId,
  Expense? template,
  Object sheet,
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
    this.noteTyped = false,
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

  /// Whether the note was last typed by hand, not filled by a chip or a
  /// screenshot; only then does it narrow the history chips.
  final bool noteTyped;

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
    bool? noteTyped,
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
      noteTyped: noteTyped ?? this.noteTyped,
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
  /// The last screenshot read into this sheet, until it is saved: its page
  /// labels, shop and amount, and the note it filled in, so the saved note
  /// can name its kind of page and a note Jack changed is learned.
  ({Set<String> labels, String? shop, int? amountMinor, String filled})?
  _scanned;

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

  void toggleOperator() => _edit(appendPlusMinus, replaces: false);

  void backspace() => _edit(removeLastCharacter, replaces: false);

  void _edit(String Function(String) change, {required bool replaces}) {
    final base = state.replaceOnInput && replaces ? '' : state.expression;
    state = state.copyWith(expression: change(base), replaceOnInput: false);
  }

  /// A category picked in the sheet ([tapped]) or set for it (a new
  /// category, a note's last category).
  void selectCategory(String id, {bool tapped = true}) => state = state
      .copyWith(categoryId: id, categoryTapped: state.categoryTapped || tapped);

  /// A note set by a chip or a screenshot ([typed] false), or typed.
  void setNote(String note, {bool typed = false}) {
    if (note != state.note || typed != state.noteTyped) {
      state = state.copyWith(note: note, noteTyped: typed);
    }
  }

  /// Takes [note] out of the selected category's history chips; its past
  /// expenses keep it.
  Future<void> hideNote(String note) async {
    final categoryId = state.categoryId;
    if (categoryId == null) return;
    await ref.read(hiddenNoteDaoProvider).hide(categoryId, note);
  }

  /// A note typed by hand: when it was used before, switch to the category
  /// it was last used with, unless a category was tapped in this sheet or
  /// an existing expense is being edited.
  /// A screenshot's note goes the same way, but as not [typed].
  Future<void> typeNote(String note, {bool typed = true}) async {
    setNote(note, typed: typed);
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

  /// Fills the sheet from a read screenshot, replacing what was there: the
  /// amount (the next key typed replaces it), the date (today when none was
  /// found or it is in the future) and the shop as the note; what was not
  /// found is cleared. When Jack gave the same shop at the same amount a
  /// note of his own before, that note goes in instead; otherwise a kind of
  /// page he named before puts its name in front (`Food App - Kedai Ali`,
  /// or the name alone without a shop). A delivery goes to
  /// [deliveryCategoryId]; otherwise the note picks its category as a typed
  /// note does.
  Future<void> applyReading(
    ReceiptReading reading, {
    String? deliveryCategoryId,
  }) async {
    final amount = reading.amountMinor;
    final date = reading.date;
    final today = ref.read(todayProvider);
    state = state.copyWith(
      expression: amount == null ? '' : formatMinor(amount, grouping: false),
      replaceOnInput: amount != null,
      date: date == null || date.isAfter(today) ? today : dateOnly(date),
    );
    final shop = reading.shop;
    final learned = shop == null || amount == null
        ? null
        : await ref.read(learnedNoteDaoProvider).noteFor(shop, amount);
    final kinds = learned != null
        ? const <ReceiptKind>[]
        : await ref.read(receiptKindDaoProvider).getAll();
    final note =
        learned ??
        receiptNote(
          shop: shop,
          kindName: matchKind(reading.labels, kinds)?.name,
        );
    _scanned = (
      labels: reading.labels,
      shop: shop,
      amountMinor: amount,
      filled: note ?? '',
    );
    if (reading.delivery && deliveryCategoryId != null) {
      selectCategory(deliveryCategoryId, tapped: false);
      setNote(note ?? '');
    } else if (note != null) {
      await typeNote(note, typed: false);
    } else {
      setNote('');
    }
  }

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
        ref.read(fieldPulseProvider.notifier).pulse(categoryId);
      } else {
        await dao.updateExpense(
          id: editing.id,
          amountMinor: amount,
          categoryId: categoryId,
          occurredAt: _occurredAt(),
          note: state.note,
        );
      }
      await _learnNote();
    } finally {
      state = state.copyWith(saving: false);
    }
    if (addAnother) {
      state = state.copyWith(expression: '', note: '', noteTyped: false);
    }
    return true;
  }

  /// After saving a read screenshot, names its kind of page from the note,
  /// and when Jack changed the note, remembers it for that shop and amount,
  /// so the next screenshot like it fills them in. A failure only loses
  /// what was learned; the expense is already saved.
  Future<void> _learnNote() async {
    final scanned = _scanned;
    _scanned = null;
    if (scanned == null) return;
    final shop = scanned.shop;
    final amount = scanned.amountMinor;
    final kindName = learnedKindName(note: state.note, shop: shop);
    final note = noteToLearn(
      shop: shop,
      amountMinor: amount,
      filled: scanned.filled,
      saved: state.note,
    );
    try {
      if (kindName != null) {
        await ref
            .read(receiptKindDaoProvider)
            .remember(scanned.labels, kindName);
      }
      if (note != null && shop != null && amount != null) {
        await ref.read(learnedNoteDaoProvider).learn(shop, amount, note);
      }
    } on Exception {
      // Nothing to tell Jack: the next scan simply fills the shop.
    }
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
