import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/icon_registry.dart';
import '../../core/utils/money.dart';
import '../../data/database/app_database.dart';
import '../../shared/widgets/category_avatar.dart';
import '../../shared/widgets/inset_group.dart';
import '../../shared/widgets/inset_row.dart';
import '../categories/categories_providers.dart';
import 'group_screen.dart';
import 'group_sheets.dart';
import 'split_providers.dart';

/// Books, from the ledger's book button: Jack's own ledger, the groups
/// (each its own book, opening as a page), archived ones folded below,
/// and New group.
Future<void> showBooksSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.page,
      reverseDuration: AppMotion.normal,
    ),
    builder: (context) => const _BooksSheet(),
  );
}

class _BooksSheet extends ConsumerStatefulWidget {
  const _BooksSheet();

  @override
  ConsumerState<_BooksSheet> createState() => _BooksSheetState();
}

class _BooksSheetState extends ConsumerState<_BooksSheet> {
  bool _showArchived = false;

  /// Closes Books and opens [groupId]'s page in its place.
  void _open(String groupId) {
    final navigator = Navigator.of(context);
    navigator
      ..pop()
      ..push(
        MaterialPageRoute<void>(builder: (_) => GroupScreen(groupId: groupId)),
      );
  }

  Future<void> _newGroup() async {
    final id = await showNewGroupSheet(context);
    if (id != null && mounted) _open(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final groups = ref.watch(splitGroupsProvider).valueOrNull ?? const [];
    final sizes = ref.watch(splitGroupSizesProvider).valueOrNull ?? const {};
    final categories = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? const [])
        c.id: c,
    };
    final active = [
      for (final g in groups)
        if (!g.isArchived) g,
    ];
    final archived = [
      for (final g in groups)
        if (g.isArchived) g,
    ];
    Widget row(SplitGroup group) {
      final size = sizes[group.id];
      final top = categories[size?.topCategoryId];
      return InsetRow(
        title: group.name,
        subtitle: size == null
            ? null
            : AppStrings.groupDetail(
                size.people,
                formatWithSymbol(size.totalMinor),
              ),
        leading: top == null
            ? const _BookTile()
            : CategoryAvatar.of(top, size: AppSizes.smallAvatar),
        showChevron: true,
        onTap: () => _open(group.id),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            // The theme's drag handle already gives the top its room.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              AppStrings.books,
              style: AppTextStyles.title2.copyWith(color: colors.label),
            ),
          ),
          InsetGroup(
            children: [
              InsetRow(
                title: AppStrings.myLedger,
                subtitle: AppStrings.myLedgerDetail,
                leading: const _BookTile(),
                trailing: Icon(Icons.check_rounded, color: colors.accent),
                onTap: () => Navigator.of(context).pop(),
              ),
              for (final group in active) row(group),
            ],
          ),
          if (archived.isNotEmpty && _showArchived) ...[
            const SizedBox(height: AppSpacing.md),
            InsetGroup(
              header: AppStrings.archivedSection(archived.length),
              onHeaderTap: () => setState(() => _showArchived = false),
              children: [for (final group in archived) row(group)],
            ),
          ] else if (archived.isNotEmpty)
            // Folded: the header alone, without an empty card under it.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showArchived = true),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md + AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  children: [
                    Text(
                      AppStrings.archivedSection(archived.length),
                      style: AppTextStyles.caption1.copyWith(
                        color: colors.sectionLabel,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: AppSizes.labelIcon,
                      color: colors.sectionLabel,
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              0,
            ),
            child: FilledButton(
              onPressed: _newGroup,
              child: const Text(AppStrings.newGroup),
            ),
          ),
        ],
      ),
    );
  }
}

/// The receipt picture on a quiet tile: a book with no category yet.
class _BookTile extends StatelessWidget {
  const _BookTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.smallAvatar,
      height: AppSizes.smallAvatar,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.colors.fill,
        borderRadius: BorderRadius.circular(
          AppSizes.smallAvatar * AppSizes.avatarRadiusFactor,
        ),
      ),
      child: const UiIcon(
        UiIcons.receipt,
        size: AppSizes.smallAvatar * AppSizes.avatarIconFactor,
      ),
    );
  }
}
