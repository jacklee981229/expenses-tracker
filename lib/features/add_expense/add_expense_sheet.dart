import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/category_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/data_providers.dart';
import '../../core/utils/receipt_parser.dart';
import '../../data/database/app_database.dart';
import '../../data/services/receipt_reader.dart';
import '../../shared/today_provider.dart';
import '../../shared/widgets/sheets.dart';
import '../categories/categories_providers.dart';
import '../categories/edit_category_screen.dart';
import 'add_expense_controller.dart';
import 'widgets/amount_display.dart';
import 'widgets/amount_keypad.dart';
import 'widgets/category_grid.dart';
import 'widgets/date_chip.dart';
import 'widgets/entry_parts.dart';
import 'widgets/history_chip_strip.dart';
import 'widgets/scan_overlay.dart';

/// Opens the full-height add sheet, the edit sheet for [editing], or a new
/// expense copied from [template] (Again: same category, note and amount,
/// dated today). A [scan] still starting (a screenshot from the Back Tap
/// shortcut) fills the sheet when it is read; when it finds no picture the
/// title says [noPicture].
Future<void> showAddExpenseSheet(
  BuildContext context, {
  Expense? editing,
  Expense? template,
  Future<Future<ReceiptReading>?>? scan,
  String? noPicture,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.page,
      reverseDuration: AppMotion.normal,
    ),
    builder: (context) => AddExpenseSheet(
      editing: editing,
      template: template,
      scan: scan,
      noPicture: noPicture,
    ),
  );
}

/// The entry sheet: a close button, the title and a scan button (read a
/// screenshot), the category tiles, the violet amount box (amount, date,
/// note, and under them the notes used before in this category), and the
/// keypad, whose word keys save.
class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({
    super.key,
    this.editing,
    this.template,
    this.scan,
    this.noPicture,
  });

  final Expense? editing;
  final Expense? template;
  final Future<Future<ReceiptReading>?>? scan;
  final String? noPicture;

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  late final TextEditingController _note = TextEditingController(
    text: widget.editing?.note ?? widget.template?.note ?? '',
  );
  final FocusNode _noteFocus = FocusNode();

  /// Fixed once categories first load, so the controller is never rebuilt.
  AddExpenseArgs? _args;

  /// Counts Save & Add presses, so the amount can play its "sent" motion.
  int _sent = 0;

  /// Shown instead of the title while a screenshot is read, and briefly
  /// after when it found nothing.
  String? _notice;
  Timer? _noticeTimer;

  bool _reading = false;

  @override
  void initState() {
    super.initState();
    final scan = widget.scan;
    if (scan != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _read(scan, whenNone: widget.noPicture),
      );
    }
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  /// Reads a screenshot and fills the sheet with what it found. A null
  /// [scan] means nothing to read: a cancelled pick, or no picture on the
  /// clipboard, which shows [whenNone].
  Future<void> _read(
    Future<Future<ReceiptReading>?> pending, {
    String? whenNone,
  }) async {
    Future<ReceiptReading>? reading;
    try {
      // readSafely right away, so a failure after the sheet closes is still
      // handled.
      final started = await pending;
      reading = started == null ? null : readSafely(started);
    } on Exception {
      // The picker refused (no photo access, already open).
      reading = null;
    }
    if (!mounted) return;
    _noticeTimer?.cancel();
    if (reading == null) {
      _showNotice(whenNone);
      return;
    }
    setState(() {
      _reading = true;
      _notice = AppStrings.scanReading;
    });
    final result = await reading;
    // A Back Tap launch can finish reading before the categories load.
    if (_args == null && mounted) {
      await ref.read(activeCategoriesProvider.future);
      await WidgetsBinding.instance.endOfFrame;
    }
    final args = _args;
    if (!mounted) return;
    setState(() => _reading = false);
    if (args != null) {
      final categories = ref.read(activeCategoriesProvider).valueOrNull;
      final food = categories?.where((c) => c.iconKey == kFoodIconKey);
      await ref
          .read(addExpenseControllerProvider(args).notifier)
          .applyReading(result, deliveryCategoryId: food?.firstOrNull?.id);
    }
    if (!mounted) return;
    _showNotice(result.amountMinor == null ? AppStrings.scanNoAmount : null);
  }

  /// Shows [notice] in place of the title for a few seconds; null puts the
  /// title back.
  void _showNotice(String? notice) {
    setState(() => _notice = notice);
    if (notice != null) {
      _noticeTimer = Timer(kScanNoticeDuration, () {
        if (mounted) setState(() => _notice = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(activeCategoriesProvider).valueOrNull;
    if (categories == null) return const SizedBox.shrink();

    final template = widget.template;
    // A copied expense keeps its category only while that is still active.
    final templateCategory =
        template != null && categories.any((c) => c.id == template.categoryId)
        ? template.categoryId
        : null;
    final args = _args ??= (
      editing: widget.editing,
      defaultCategoryId: templateCategory ?? categories.firstOrNull?.id,
      template: template,
      sheet: this,
    );
    final provider = addExpenseControllerProvider(args);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    ref.listen(provider.select((s) => s.note), (_, note) {
      if (_note.text != note) _note.text = note;
    });
    final today = ref.watch(todayProvider);
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      children: [
        EntrySheetHeader(
          title:
              _notice ??
              (state.isEditing
                  ? AppStrings.editExpense
                  : AppStrings.newExpense),
        ),
        Expanded(
          child: CategoryGrid(
            categories: categories,
            selectedId: state.categoryId,
            onSelected: controller.selectCategory,
            onAddCategory: () => _addCategory(controller),
          ),
        ),
        AmountBox(
          categoryColor: switch (categories
              .where((c) => c.id == state.categoryId)
              .firstOrNull) {
            final category? => colorFromHex(category.colorHex),
            null => null,
          },
          reading: _reading,
          overlay: ScanOverlay(reading: _reading),
          amount: AmountDisplay(
            expression: state.expression,
            resultMinor: state.amountMinor,
            showResult: state.showsResult,
            sent: _sent,
          ),
          date: DateChip(
            date: state.date,
            today: today,
            onChanged: controller.setDate,
          ),
          note: EntryNoteField(
            controller: _note,
            focusNode: _noteFocus,
            onChanged: controller.typeNote,
          ),
          history: HistoryChipStrip(
            categoryId: state.categoryId,
            note: state.note,
            typed: state.noteTyped,
            onSelected: controller.setNote,
            onHide: (note) => _hideNote(controller, note),
          ),
        ),
        // The system keyboard slides up over the keypad while the note is
        // edited. Removing the keypad instead dropped the amount box to the
        // bottom and back up on every open and close; this way the box only
        // moves once the keyboard is taller than the keypad.
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: keyboardHeight == 0 ? 0 : keyboardHeight + AppSpacing.xs,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1,
            child: AmountKeypad(
              onDigit: (digit) => _key(() => controller.digit(digit)),
              onDecimalPoint: () => _key(controller.decimalPoint),
              onPlusMinus: () => _key(controller.toggleOperator),
              onScan: state.isEditing || _reading
                  ? null
                  : () {
                      _noteFocus.unfocus();
                      _read(ref.read(receiptReaderProvider).pick());
                    },
              onBackspace: () => _key(controller.backspace),
              onSaveAndAdd: state.canSave && !state.isEditing
                  ? () => _save(controller, addAnother: true)
                  : null,
              onSave: state.canSave ? () => _save(controller) : null,
            ),
          ),
        ),
      ],
    );
  }

  void _key(VoidCallback action) {
    _noteFocus.unfocus();
    HapticFeedback.selectionClick();
    action();
  }

  Future<void> _save(
    AddExpenseController controller, {
    bool addAnother = false,
  }) async {
    _noteFocus.unfocus();
    if (await controller.looksLikeDuplicate()) {
      if (!mounted) return;
      final again = await showOptionsSheet<bool>(
        context,
        title: AppStrings.duplicateTitle,
        message: AppStrings.duplicateMessage,
        options: const [SheetOption(AppStrings.saveAgain, true)],
      );
      if (again != true) return;
    }
    final saved = await controller.save(addAnother: addAnother);
    if (!saved || !mounted) return;
    HapticFeedback.lightImpact();
    if (addAnother) {
      setState(() => _sent++);
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Asks before taking [note] out of the category's chips.
  Future<void> _hideNote(AddExpenseController controller, String note) async {
    final confirmed = await confirmDestructive(
      context,
      title: AppStrings.hideNoteTitle(note),
      confirmLabel: AppStrings.hideNote,
    );
    if (confirmed && mounted) await controller.hideNote(note);
  }

  /// Opens New Category over the sheet and selects the result.
  Future<void> _addCategory(AddExpenseController controller) async {
    _noteFocus.unfocus();
    final id = await Navigator.of(context).push(
      MaterialPageRoute<String>(builder: (_) => const EditCategoryScreen()),
    );
    if (id != null && mounted) controller.selectCategory(id);
  }
}
