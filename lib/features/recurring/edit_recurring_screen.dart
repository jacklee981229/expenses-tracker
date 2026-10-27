import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/amount_input.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/money.dart';
import '../../data/database/app_database.dart';
import '../../shared/today_provider.dart';
import '../../shared/widgets/category_avatar.dart';
import '../../shared/widgets/inset_group.dart';
import '../../shared/widgets/inset_row.dart';
import '../../shared/widgets/sheets.dart';
import '../../shared/widgets/glow_scaffold.dart';
import '../categories/categories_providers.dart';
import 'recurring_providers.dart';

/// Creates a fixed monthly expense rule, or edits [existing].
class EditRecurringScreen extends ConsumerStatefulWidget {
  const EditRecurringScreen({super.key, this.existing});

  final RecurringRule? existing;

  @override
  ConsumerState<EditRecurringScreen> createState() =>
      _EditRecurringScreenState();
}

class _EditRecurringScreenState extends ConsumerState<EditRecurringScreen> {
  static const int _maxDay = 31;

  late final TextEditingController _amount;
  late final TextEditingController _note;
  String? _categoryId;
  late int _dayOfMonth;
  late String _startMonth;
  String? _endMonth;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final rule = widget.existing;
    final today = ref.read(todayProvider);
    _amount = TextEditingController(
      text: rule == null ? '' : formatMinor(rule.amountMinor, grouping: false),
    );
    _note = TextEditingController(text: rule?.note ?? '');
    _categoryId = rule?.categoryId;
    _dayOfMonth = rule?.dayOfMonth ?? today.day;
    _startMonth = rule?.startMonth ?? toMonthKey(today);
    _endMonth = rule?.endMonth;
    _isActive = rule?.isActive ?? true;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _amountMinor {
    try {
      return parseToMinor(_amount.text);
    } on FormatException {
      return null;
    }
  }

  bool _canSave(String? categoryId) {
    final endMonth = _endMonth;
    return !_saving &&
        categoryId != null &&
        (_amountMinor ?? 0) > 0 &&
        (endMonth == null || endMonth.compareTo(_startMonth) >= 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // All categories, so a rule on an archived category still shows its name;
    // only active ones are offered in the picker.
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];
    final active = [
      for (final category in categories)
        if (!category.isArchived) category,
    ];
    final categoryId = _categoryId ?? active.firstOrNull?.id;
    final category = categories.where((c) => c.id == categoryId).firstOrNull;
    final existing = widget.existing;
    final canSave = _canSave(categoryId);

    return GlowScaffold(
      appBar: AppBar(
        leadingWidth: AppSizes.navTextButtonWidth,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        title: Text(
          existing == null
              ? AppStrings.newFixedExpense
              : AppStrings.editFixedExpense,
        ),
        actions: [
          TextButton(
            onPressed: canSave ? () => _save(categoryId!) : null,
            child: const Text(AppStrings.save, style: AppTextStyles.headline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          InsetGroup(
            children: [
              _FieldRow(
                label: AppStrings.amountLabel,
                child: TextField(
                  controller: _amount,
                  autofocus: existing == null,
                  onChanged: (_) => setState(() {}),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [amountInputFormatter],
                  style: AppTextStyles.amount.copyWith(color: colors.label),
                  decoration: InputDecoration(
                    hintText: formatMinor(0),
                    prefixText: kCurrencyPrefix,
                    isDense: true,
                  ),
                ),
              ),
              InsetRow(
                title: AppStrings.categoryLabel,
                showChevron: true,
                onTap: () => _pickCategory(context, active, categoryId),
                trailing: category == null
                    ? Text(
                        AppStrings.chooseCategory,
                        style: AppTextStyles.body.copyWith(
                          color: colors.labelSecondary,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategoryAvatar.of(
                            category,
                            size: AppSizes.smallAvatar,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            category.name,
                            style: AppTextStyles.body.copyWith(
                              color: colors.labelSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
              _FieldRow(
                label: AppStrings.noteLabel,
                child: TextField(
                  controller: _note,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  textAlign: TextAlign.right,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.body.copyWith(color: colors.label),
                  decoration: const InputDecoration(
                    hintText: AppStrings.notePlaceholder,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          InsetGroup(
            children: [
              InsetRow(
                title: AppStrings.dayOfMonthLabel,
                trailing: _Value(_dayOfMonth.toString()),
                onTap: _pickDay,
              ),
              InsetRow(
                title: AppStrings.startMonthLabel,
                trailing: _Value(formatMonthKey(_startMonth)),
                onTap: _pickStartMonth,
              ),
              InsetRow(
                title: AppStrings.endMonthLabel,
                onTap: _pickEndMonth,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Value(
                      _endMonth == null
                          ? AppStrings.never
                          : formatMonthKey(_endMonth!),
                    ),
                    if (_endMonth != null)
                      IconButton(
                        tooltip: AppStrings.never,
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.cancel, color: colors.labelTertiary),
                        onPressed: () => setState(() => _endMonth = null),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          InsetGroup(
            footer: AppStrings.recurringEditFootnote,
            children: [
              InsetRow(
                title: AppStrings.activeLabel,
                trailing: Switch.adaptive(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ),
            ],
          ),
          if (existing != null) ...[
            const SizedBox(height: AppSpacing.xl),
            InsetGroup(
              children: [
                TextButton(
                  onPressed: () => _delete(existing),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.destructive,
                  ),
                  child: const Text(AppStrings.deleteFixedExpense),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickCategory(
    BuildContext context,
    List<ExpenseCategory> categories,
    String? current,
  ) async {
    final picked = await showOptionsSheet<String>(
      context,
      title: AppStrings.categoryLabel,
      options: [
        for (final category in categories)
          SheetOption(
            category.name,
            category.id,
            selected: category.id == current,
          ),
      ],
    );
    if (picked != null) setState(() => _categoryId = picked);
  }

  Future<void> _pickDay() async {
    final index = await showItemPickerSheet(
      context,
      items: [for (var day = 1; day <= _maxDay; day++) day.toString()],
      initialIndex: _dayOfMonth - 1,
    );
    if (index != null) setState(() => _dayOfMonth = index + 1);
  }

  Future<void> _pickStartMonth() async {
    final picked = await showDatePickerSheet(
      context,
      initial: monthKeyToDate(_startMonth),
      mode: CupertinoDatePickerMode.monthYear,
    );
    if (picked != null) setState(() => _startMonth = toMonthKey(picked));
  }

  Future<void> _pickEndMonth() async {
    final picked = await showDatePickerSheet(
      context,
      initial: monthKeyToDate(_endMonth ?? _startMonth),
      mode: CupertinoDatePickerMode.monthYear,
      minimum: monthKeyToDate(_startMonth),
    );
    if (picked != null) setState(() => _endMonth = toMonthKey(picked));
  }

  Future<void> _save(String categoryId) async {
    final amount = _amountMinor;
    if (amount == null) return;
    setState(() => _saving = true);
    await ref
        .read(recurringActionsProvider)
        .save(
          existing: widget.existing,
          amountMinor: amount,
          categoryId: categoryId,
          note: _note.text,
          dayOfMonth: _dayOfMonth,
          startMonth: _startMonth,
          endMonth: _endMonth,
          isActive: _isActive,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(RecurringRule rule) async {
    final actions = ref.read(recurringActionsProvider);
    final navigator = Navigator.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: AppStrings.deleteRuleTitle,
      message: AppStrings.deleteRuleMessage,
      confirmLabel: AppStrings.deleteFixedExpense,
    );
    if (!confirmed) return;
    await actions.delete(rule.id);
    navigator.pop();
  }
}

/// A row with a label on the left and an input on the right.
class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Sits on its group's glass, so it adds no tint of its own.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.rowMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.body),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(color: context.colors.labelSecondary),
    );
  }
}
