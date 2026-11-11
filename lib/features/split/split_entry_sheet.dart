import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_colors.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/amount_input.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money.dart';
import '../../core/utils/split_settle.dart';
import '../../data/database/app_database.dart';
import '../../shared/today_provider.dart';
import '../../shared/widgets/pill_chip.dart';
import '../add_expense/widgets/amount_display.dart';
import '../add_expense/widgets/amount_keypad.dart';
import '../add_expense/widgets/category_grid.dart';
import '../add_expense/widgets/date_chip.dart';
import '../add_expense/widgets/entry_parts.dart';
import '../categories/categories_providers.dart';
import '../categories/edit_category_screen.dart';
import 'split_providers.dart';
import 'widgets/person_avatar.dart';

/// Opens the sheet that adds an expense to [groupId], or edits [editing].
Future<void> showSplitEntrySheet(
  BuildContext context, {
  required String groupId,
  SplitItem? editing,
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
    builder: (context) => _SplitEntrySheet(groupId: groupId, editing: editing),
  );
}

/// The add sheet's parts (categories, amount box, keypad) with who paid
/// (one) and who shares it (any, all to start) between the amount box and
/// the keypad, and what each pays as the chips change.
class _SplitEntrySheet extends ConsumerStatefulWidget {
  const _SplitEntrySheet({required this.groupId, this.editing});

  final String groupId;
  final SplitItem? editing;

  @override
  ConsumerState<_SplitEntrySheet> createState() => _SplitEntrySheetState();
}

class _SplitEntrySheetState extends ConsumerState<_SplitEntrySheet> {
  late final SplitEntry? _entry = widget.editing?.entry;
  late String _expression = _entry == null
      ? ''
      : formatMinor(_entry.amountMinor, grouping: false);

  /// When editing, the first digit typed replaces the amount.
  late bool _replaceOnInput = _entry != null;
  late String? _categoryId = _entry?.categoryId;
  late DateTime _date = _entry == null
      ? ref.read(todayProvider)
      : parseLocalDate(_entry.localDate);
  late final TextEditingController _note = TextEditingController(
    text: _entry?.note ?? '',
  );
  final FocusNode _noteFocus = FocusNode();

  /// Set from the group's people once they load: Jack pays and everyone
  /// shares, unless editing.
  String? _payerId;
  Set<String>? _sharerIds;
  bool _saving = false;

  /// Counts Save & Add presses, so the amount can play its "sent" motion.
  int _sent = 0;

  int? get _amount => evaluateAmountExpression(_expression);

  @override
  void dispose() {
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _edit(String Function(String) change, {required bool replaces}) {
    _noteFocus.unfocus();
    HapticFeedback.selectionClick();
    setState(() {
      final base = _replaceOnInput && replaces ? '' : _expression;
      _expression = change(base);
      _replaceOnInput = false;
    });
  }

  bool _canSave(List<SplitPerson> people) =>
      !_saving &&
      _categoryId != null &&
      (_amount ?? 0) > 0 &&
      (_sharerIds?.isNotEmpty ?? false);

  Future<void> _save(
    List<SplitPerson> people, {
    bool addAnother = false,
  }) async {
    final amount = _amount;
    final categoryId = _categoryId;
    final payerId = _payerId;
    final sharers = _sharerIds;
    if (!_canSave(people) ||
        amount == null ||
        categoryId == null ||
        payerId == null ||
        sharers == null) {
      return;
    }
    _noteFocus.unfocus();
    setState(() => _saving = true);
    try {
      await ref
          .read(splitActionsProvider)
          .saveEntry(
            id: _entry?.id,
            groupId: widget.groupId,
            amountMinor: amount,
            categoryId: categoryId,
            occurredAt: _occurredAt(),
            note: _note.text,
            payerId: payerId,
            // In the group's order, which the leftover sen follow.
            sharerIds: [
              for (final p in people)
                if (sharers.contains(p.id)) p.id,
            ],
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    HapticFeedback.lightImpact();
    if (addAnother) {
      setState(() {
        _sent++;
        _expression = '';
        _note.clear();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  /// The chosen day at the current time of day; an edit on the same day
  /// keeps its time.
  DateTime _occurredAt() {
    final entry = _entry;
    if (entry != null) {
      final original = DateTime.fromMillisecondsSinceEpoch(entry.occurredAt);
      if (dateOnly(original) == _date) return original;
    }
    final now = DateTime.now();
    return DateTime(
      _date.year,
      _date.month,
      _date.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  Future<void> _addCategory() async {
    _noteFocus.unfocus();
    final id = await Navigator.of(context).push(
      MaterialPageRoute<String>(builder: (_) => const EditCategoryScreen()),
    );
    if (id != null && mounted) setState(() => _categoryId = id);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(activeCategoriesProvider).valueOrNull;
    final people = ref.watch(splitPeopleProvider(widget.groupId)).valueOrNull;
    if (categories == null || people == null || people.isEmpty) {
      return const SizedBox.shrink();
    }
    _categoryId ??= categories.firstOrNull?.id;
    _payerId ??= _entry?.payerId ?? people.first.id;
    _sharerIds ??=
        widget.editing?.saved.shares.keys.toSet() ??
        {for (final p in people) p.id};
    final category = ref
        .watch(allCategoriesProvider)
        .valueOrNull
        ?.where((c) => c.id == _categoryId)
        .firstOrNull;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final canSave = _canSave(people);

    return Column(
      children: [
        EntrySheetHeader(
          title: _entry == null
              ? AppStrings.newExpense
              : AppStrings.editExpense,
        ),
        Expanded(
          child: CategoryGrid(
            categories: categories,
            selectedId: _categoryId,
            onSelected: (id) => setState(() => _categoryId = id),
            onAddCategory: _addCategory,
          ),
        ),
        AmountBox(
          categoryColor: category == null
              ? null
              : colorFromHex(category.colorHex),
          amount: AmountDisplay(
            expression: _expression,
            resultMinor: _amount,
            showResult: hasOperator(_expression),
            sent: _sent,
          ),
          date: DateChip(
            date: _date,
            today: ref.watch(todayProvider),
            onChanged: (date) => setState(() => _date = dateOnly(date)),
          ),
          note: EntryNoteField(
            controller: _note,
            focusNode: _noteFocus,
            onChanged: (_) {},
          ),
        ),
        _PeoplePicker(
          people: people,
          payerId: _payerId!,
          sharerIds: _sharerIds!,
          amount: _amount,
          onPayer: (id) {
            HapticFeedback.selectionClick();
            setState(() => _payerId = id);
          },
          onSharer: (id) {
            HapticFeedback.selectionClick();
            setState(() {
              final sharers = _sharerIds!;
              if (!sharers.remove(id)) sharers.add(id);
            });
          },
        ),
        // As on the add sheet: the keyboard slides over the keypad.
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: keyboardHeight == 0 ? 0 : keyboardHeight + AppSpacing.xs,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1,
            child: AmountKeypad(
              showScan: false,
              onScan: null,
              onDigit: (digit) =>
                  _edit((e) => appendDigit(e, digit), replaces: true),
              onDecimalPoint: () => _edit(appendDecimalPoint, replaces: true),
              onPlusMinus: () => _edit(appendPlusMinus, replaces: false),
              onBackspace: () => _edit(removeLastCharacter, replaces: false),
              onSaveAndAdd: canSave && _entry == null
                  ? () => _save(people, addAnother: true)
                  : null,
              onSave: canSave ? () => _save(people) : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paid by (one) and Split between (any) as rows of people chips, with
/// what each pays on the right of Split between.
class _PeoplePicker extends StatelessWidget {
  const _PeoplePicker({
    required this.people,
    required this.payerId,
    required this.sharerIds,
    required this.amount,
    required this.onPayer,
    required this.onSharer,
  });

  final List<SplitPerson> people;
  final String payerId;
  final Set<String> sharerIds;
  final int? amount;
  final ValueChanged<String> onPayer;
  final ValueChanged<String> onSharer;

  /// `RM70.00 each`; one sharer: `RM210.00 for Ali`; when the odd sen
  /// make one share bigger: `RM33.33 each, Ali RM33.34`; several bigger:
  /// `RM3.33–RM3.34 each`.
  String _each() {
    final sharers = [
      for (final p in people)
        if (sharerIds.contains(p.id)) p,
    ];
    if (sharers.isEmpty) return AppStrings.pickSomeone;
    // Mid-sentence: `RM10.00 for you`.
    String name(SplitPerson p) => p.isMe ? AppStrings.youInLine : p.name;
    final shares = equalShares(
      amount: amount != null && amount! > 0 ? amount! : 0,
      payer: payerId,
      sharers: [for (final p in sharers) p.id],
    );
    if (sharers.length == 1) {
      return AppStrings.shareFor(
        formatWithSymbol(shares.values.single),
        name(sharers.single),
      );
    }
    final low = shares.values.reduce((a, b) => a < b ? a : b);
    final high = sharers.where((p) => shares[p.id] != low).toList();
    if (high.isEmpty) return AppStrings.shareEach(formatWithSymbol(low));
    if (high.length == 1) {
      return AppStrings.shareEachBut(
        formatWithSymbol(low),
        name(high.single),
        formatWithSymbol(shares[high.single.id]!),
      );
    }
    // Several take an odd sen: the range, since naming them all is long.
    return AppStrings.shareRange(
      formatWithSymbol(low),
      formatWithSymbol(low + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = AppTextStyles.caption1.copyWith(color: colors.sectionLabel);
    // Split between picks several, so its picked chips carry a tick;
    // Paid by picks one and has none.
    Widget chips(
      bool Function(SplitPerson) selected,
      ValueChanged<String> tap, {
      bool ticks = false,
    }) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2),
      child: Row(
        children: [
          for (final (index, person) in people.indexed)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: PillChip(
                label: person.isMe ? AppStrings.you : person.name,
                selected: selected(person),
                onTap: () => tap(person.id),
                trailing: ticks && selected(person)
                    ? Icon(
                        Icons.check_rounded,
                        size: AppSizes.labelIcon,
                        color: colors.onAccent,
                      )
                    : null,
                leading: PersonAvatar(
                  name: person.name,
                  index: index,
                  size: AppSizes.personChipAvatar,
                ),
              ),
            ),
        ],
      ),
    );
    Widget heading(String text, [String? trailing]) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 2,
        AppSpacing.xs,
        AppSpacing.md + 2,
        AppSpacing.xxs,
      ),
      child: Row(
        children: [
          Text(text.toUpperCase(), style: label),
          const SizedBox(width: AppSpacing.sm),
          if (trailing != null)
            // A long name shrinks the line rather than running off.
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedSwitcher(
                    duration: AppMotion.quick,
                    child: Text(
                      trailing,
                      key: ValueKey(trailing),
                      maxLines: 1,
                      style: AppTextStyles.chipFigure.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading(AppStrings.paidBy),
        chips((p) => p.id == payerId, onPayer),
        heading(AppStrings.splitBetween, _each()),
        chips((p) => sharerIds.contains(p.id), onSharer, ticks: true),
      ],
    );
  }
}
