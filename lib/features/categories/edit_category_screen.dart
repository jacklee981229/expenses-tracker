import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_colors.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/icon_registry.dart';
import '../../data/database/app_database.dart';
import '../../shared/widgets/category_avatar.dart';
import '../../shared/widgets/entrance.dart';
import '../../shared/widgets/inset_group.dart';
import '../../shared/widgets/sheets.dart';
import '../../shared/widgets/glow_scaffold.dart';
import 'categories_providers.dart';
import 'widgets/colour_picker.dart';
import 'widgets/icon_picker.dart';

/// Creates a category (when [category] is null) or edits one. Pops with the
/// category's id after saving.
class EditCategoryScreen extends ConsumerStatefulWidget {
  const EditCategoryScreen({super.key, this.category});

  final ExpenseCategory? category;

  @override
  ConsumerState<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends ConsumerState<EditCategoryScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.category?.name ?? '',
  );
  late String _iconKey = widget.category?.iconKey ?? kFallbackIconKey;
  late String _colorHex =
      widget.category?.colorHex ?? kCategoryColorHexes.first;
  bool _saving = false;

  bool get _isNew => widget.category == null;

  bool get _canSave => !_saving && _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final category = widget.category;
    return GlowScaffold(
      appBar: AppBar(
        leadingWidth: AppSizes.navTextButtonWidth,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        title: Text(
          _isNew ? AppStrings.newCategoryTitle : AppStrings.editCategoryTitle,
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: const Text(AppStrings.save, style: AppTextStyles.headline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          Center(
            // Re-keyed on every change, so the preview pops each time.
            child: Entrance(
              key: ValueKey('$_iconKey|$_colorHex'),
              offset: Offset.zero,
              fromTilt: -20,
              fromScale: 0.6,
              curve: AppMotion.pop,
              child: CategoryAvatar(
                iconKey: _iconKey,
                colorHex: _colorHex,
                size: AppSizes.previewAvatar,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InsetGroup(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _name,
                  autofocus: _isNew,
                  onChanged: (_) => setState(() {}),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyles.body.copyWith(color: colors.label),
                  decoration: const InputDecoration(
                    hintText: AppStrings.categoryNamePlaceholder,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          InsetGroup(
            header: AppStrings.iconLabel,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: IconPicker(
                  selectedKey: _iconKey,
                  colorHex: _colorHex,
                  onSelected: (key) => setState(() => _iconKey = key),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          InsetGroup(
            header: AppStrings.colourLabel,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ColourPicker(
                  selectedHex: _colorHex,
                  onSelected: (hex) => setState(() => _colorHex = hex),
                ),
              ),
            ],
          ),
          if (category != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _DeleteSection(category: category),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final actions = ref.read(categoryActionsProvider);
    final category = widget.category;
    final String id;
    if (category == null) {
      id = await actions.create(
        name: _name.text,
        iconKey: _iconKey,
        colorHex: _colorHex,
      );
    } else {
      id = category.id;
      await actions.update(
        id: id,
        name: _name.text,
        iconKey: _iconKey,
        colorHex: _colorHex,
      );
    }
    if (mounted) Navigator.of(context).pop(id);
  }
}

/// Delete is only offered for a category that nothing uses; otherwise a
/// footnote explains that it can only be archived.
class _DeleteSection extends ConsumerWidget {
  const _DeleteSection({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(categoryUsageProvider(category.id)).valueOrNull;
    if (usage == null) return const SizedBox.shrink();
    if (usage > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Text(
          AppStrings.categoryInUseFootnote,
          style: AppTextStyles.footnote.copyWith(
            color: context.colors.labelSecondary,
          ),
        ),
      );
    }
    return InsetGroup(
      children: [
        TextButton(
          onPressed: () => _delete(context, ref),
          style: TextButton.styleFrom(
            foregroundColor: context.colors.destructive,
          ),
          child: const Text(AppStrings.deleteCategory),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(categoryActionsProvider);
    final navigator = Navigator.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: AppStrings.deleteCategoryTitle,
      confirmLabel: AppStrings.deleteCategory,
    );
    if (!confirmed) return;
    await actions.delete(category.id);
    navigator.pop();
  }
}
