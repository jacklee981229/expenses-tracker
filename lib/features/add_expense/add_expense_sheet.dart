import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/receipt_parser.dart';
import '../../data/data_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/services/receipt_reader.dart';
import '../../shared/today_provider.dart';
import '../../shared/widgets/circle_icon_button.dart';
import '../../shared/widgets/hero_surface.dart';
import '../../shared/widgets/receipt_card.dart';
import '../../shared/widgets/sheets.dart';
import '../categories/categories_providers.dart';
import '../categories/edit_category_screen.dart';
import 'add_expense_controller.dart';
import 'widgets/amount_display.dart';
import 'widgets/amount_keypad.dart';
import 'widgets/category_grid.dart';
import 'widgets/date_chip.dart';
import 'widgets/history_chip_strip.dart';

/// Opens the full-height add sheet, the edit sheet for [editing], or a new
/// expense copied from [template] (Again: same category, note and amount,
/// dated today). A [reading] still running (a screenshot from the Back Tap
/// shortcut) fills the sheet when it finishes; when it finds no picture the
/// title says [noPicture].
Future<void> showAddExpenseSheet(
  BuildContext context, {
  Expense? editing,
  Expense? template,
  Future<ReceiptReading?>? reading,
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
      reading: reading,
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
    this.reading,
    this.noPicture,
  });

  final Expense? editing;
  final Expense? template;
  final Future<ReceiptReading?>? reading;
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
  bool _reading = false;
  Timer? _noticeTimer;

  @override
  void initState() {
    super.initState();
    final reading = widget.reading;
    if (reading != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _read(reading, whenNone: widget.noPicture),
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

  /// Reads a screenshot and fills the sheet with what it found. Null from
  /// [reading] means nothing to read: a cancelled pick, or no picture on
  /// the clipboard, which shows [whenNone].
  Future<void> _read(
    Future<ReceiptReading?> reading, {
    String? whenNone,
  }) async {
    _noticeTimer?.cancel();
    setState(() {
      _reading = true;
      _notice = AppStrings.scanReading;
    });
    final result = await readSafely(reading);
    final args = _args;
    if (!mounted) return;
    setState(() => _reading = false);
    if (result != null && args != null) {
      final categories = ref.read(activeCategoriesProvider).valueOrNull;
      final food = categories?.where((c) => c.iconKey == kFoodIconKey);
      await ref
          .read(addExpenseControllerProvider(args).notifier)
          .applyReading(result, deliveryCategoryId: food?.firstOrNull?.id);
    }
    if (!mounted) return;
    final notice = result == null
        ? whenNone
        : (result.amountMinor == null ? AppStrings.scanNoAmount : null);
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

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Column(
        children: [
          _SheetHeader(
            title:
                _notice ??
                (state.isEditing
                    ? AppStrings.editExpense
                    : AppStrings.newExpense),
            onScan: state.isEditing || _reading
                ? null
                : () {
                    _noteFocus.unfocus();
                    _read(ref.read(receiptReaderProvider).pickAndRead());
                  },
          ),
          Expanded(
            child: CategoryGrid(
              categories: categories,
              selectedId: state.categoryId,
              onSelected: controller.selectCategory,
              onAddCategory: () => _addCategory(controller),
            ),
          ),
          _AmountBox(
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
            note: _NoteField(
              controller: _note,
              focusNode: _noteFocus,
              onChanged: controller.typeNote,
            ),
            history: HistoryChipStrip(
              categoryId: state.categoryId,
              note: state.note,
              onSelected: controller.setNote,
            ),
          ),
          // The system keyboard replaces the keypad while the note is edited.
          if (keyboardHeight == 0)
            AmountKeypad(
              onDigit: (digit) => _key(() => controller.digit(digit)),
              onDecimalPoint: () => _key(controller.decimalPoint),
              onOperator: (symbol) =>
                  _key(() => controller.applyOperator(symbol)),
              onBackspace: () => _key(controller.backspace),
              onSaveAndAdd: state.canSave && !state.isEditing
                  ? () => _save(controller, addAnother: true)
                  : null,
              onSave: state.canSave ? () => _save(controller) : null,
            )
          else
            const SizedBox(height: AppSpacing.xs),
        ],
      ),
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

  /// Opens New Category over the sheet and selects the result.
  Future<void> _addCategory(AddExpenseController controller) async {
    _noteFocus.unfocus();
    final id = await Navigator.of(context).push(
      MaterialPageRoute<String>(builder: (_) => const EditCategoryScreen()),
    );
    if (id != null && mounted) controller.selectCategory(id);
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onScan});

  final String title;

  /// Null hides the scan button (editing) or disables it (reading).
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm - 2),
        Container(
          width: AppSizes.sheetGrabWidth,
          height: AppSizes.sheetGrabHeight,
          decoration: BoxDecoration(
            color: colors.labelTertiary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSizes.sheetGrabHeight),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: AppSizes.sheetHeaderHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clear of the buttons on both sides; a long notice shrinks.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.navButton + AppSpacing.sm,
                ),
                child: AnimatedSwitcher(
                  duration: AppMotion.normal,
                  child: FittedBox(
                    key: ValueKey(title),
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      style: AppTextStyles.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.xs,
                child: CircleIconButton(
                  icon: Icons.close_rounded,
                  tooltip: AppStrings.closeSheet,
                  onPressed: () => Navigator.of(context).pop(),
                  background: colors.tile,
                ),
              ),
              Positioned(
                right: AppSpacing.xs,
                child: CircleIconButton(
                  icon: Icons.document_scanner_rounded,
                  tooltip: AppStrings.scanScreenshot,
                  onPressed: onScan,
                  background: colors.tile,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The violet amount box: the amount, then under a dashed line the date
/// pill beside the note field, then the note history chips.
class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.amount,
    required this.date,
    required this.note,
    required this.history,
  });

  final Widget amount;
  final Widget date;
  final Widget note;
  final Widget history;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onAccent;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm + 2,
        AppSpacing.xs,
        AppSpacing.sm + 2,
        AppSpacing.xxs,
      ),
      child: HeroSurface(
        radius: AppRadius.panel,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md + 2,
          AppSpacing.md,
          AppSpacing.md + 2,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            amount,
            const SizedBox(height: AppSpacing.xs),
            DashedLine(color: onHero.withValues(alpha: 0.28)),
            const SizedBox(height: AppSpacing.sm - 2),
            Row(
              children: [
                date,
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: note),
              ],
            ),
            history,
          ],
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onAccent;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onTapOutside: (_) => focusNode.unfocus(),
      maxLines: 1,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      cursorColor: onHero,
      style: AppTextStyles.callout.copyWith(color: onHero),
      decoration: InputDecoration(
        hintText: AppStrings.notePlaceholder,
        hintStyle: AppTextStyles.callout.copyWith(
          color: onHero.withValues(alpha: 0.62),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      ),
    );
  }
}
