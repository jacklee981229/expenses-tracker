import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/database/app_database.dart';
import '../../shared/widgets/category_avatar.dart';
import '../../shared/widgets/inset_group.dart';
import '../../shared/widgets/inset_row.dart';
import '../../shared/widgets/swipe_action_row.dart';
import '../../shared/widgets/glow_scaffold.dart';
import 'categories_providers.dart';
import 'edit_category_screen.dart';

/// Active categories in a reorderable list (drag handle sets `sortOrder`,
/// swipe left archives), with a collapsed Archived section below.
class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends ConsumerState<ManageCategoriesScreen> {
  /// The dropped order, shown until the database stream catches up so the
  /// list does not jump back for a frame.
  List<ExpenseCategory>? _pendingOrder;
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(activeCategoriesProvider, (_, _) {
      if (_pendingOrder != null) setState(() => _pendingOrder = null);
    });
    final active =
        _pendingOrder ?? ref.watch(activeCategoriesProvider).valueOrNull ?? [];
    final archived = ref.watch(archivedCategoriesProvider).valueOrNull ?? [];

    return GlowScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageCategories),
        actions: [
          IconButton(
            tooltip: AppStrings.newCategoryTitle,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _open(context, null),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        buildDefaultDragHandles: false,
        itemCount: active.length,
        onReorder: (from, to) => _reorder(active, from, to),
        proxyDecorator: (child, _, animation) => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) => Material(
            color: Colors.transparent,
            elevation: AppSizes.dragElevation * animation.value,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: child,
          ),
        ),
        itemBuilder: (context, index) => _ActiveRow(
          key: ValueKey(active[index].id),
          category: active[index],
          index: index,
          isFirst: index == 0,
          isLast: index == active.length - 1,
          onTap: () => _open(context, active[index]),
        ),
        footer: _Footer(
          archived: archived,
          expanded: _showArchived,
          onToggle: () => setState(() => _showArchived = !_showArchived),
          onOpen: (category) => _open(context, category),
        ),
      ),
    );
  }

  void _reorder(List<ExpenseCategory> current, int from, int to) {
    final reordered = [...current];
    final target = to > from ? to - 1 : to;
    reordered.insert(target, reordered.removeAt(from));
    setState(() => _pendingOrder = reordered);
    ref.read(categoryActionsProvider).reorder([
      for (final category in reordered) category.id,
    ]);
  }

  void _open(BuildContext context, ExpenseCategory? category) {
    Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (_) => EditCategoryScreen(category: category),
      ),
    );
  }
}

class _ActiveRow extends ConsumerWidget {
  const _ActiveRow({
    super.key,
    required this.category,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final ExpenseCategory category;
  final int index;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    const corner = Radius.circular(AppRadius.card);
    final hairline = AppSizes.hairline(context);
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? corner : Radius.zero,
        bottom: isLast ? corner : Radius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwipeActionRow(
            actions: [
              SwipeAction(
                label: AppStrings.archive,
                color: colors.swipeNeutral,
                onPressed: () =>
                    ref.read(categoryActionsProvider).archive(category.id),
              ),
            ],
            child: InsetRow(
              leading: CategoryAvatar.of(category),
              title: category.name,
              onTap: onTap,
              trailing: ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    size: AppSizes.inlineIcon + 4,
                    color: colors.labelTertiary,
                  ),
                ),
              ),
            ),
          ),
          if (!isLast)
            ColoredBox(
              color: colors.surface,
              child: Divider(
                height: hairline,
                thickness: hairline,
                indent: AppSpacing.md,
                color: colors.separator,
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({
    required this.archived,
    required this.expanded,
    required this.onToggle,
    required this.onOpen,
  });

  final List<ExpenseCategory> archived;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<ExpenseCategory> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final secondary = AppTextStyles.footnote.copyWith(
      color: colors.labelSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            0,
          ),
          child: Text(AppStrings.categoriesFootnote, style: secondary),
        ),
        if (archived.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.archivedSection(archived.length),
                      style: secondary,
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.labelSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            InsetGroup(
              margin: EdgeInsets.zero,
              children: [
                for (final category in archived)
                  InsetRow(
                    leading: CategoryAvatar.of(category),
                    title: category.name,
                    onTap: () => onOpen(category),
                    trailing: TextButton(
                      onPressed: () => ref
                          .read(categoryActionsProvider)
                          .restore(category.id),
                      child: const Text(AppStrings.restore),
                    ),
                  ),
              ],
            ),
        ],
      ],
    );
  }
}
