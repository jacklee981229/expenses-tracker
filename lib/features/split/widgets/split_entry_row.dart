import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../shared/widgets/category_avatar.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/swipe_action_row.dart';
import '../split_providers.dart';

/// One line of a group's receipt, as the ledger's rows: the category icon,
/// the note (the category when there is none), who paid and who shares it
/// underneath, and the amount. Tap to edit; swipe left to delete, which
/// tears the row away for the Undo bar that takes its place.
class SplitEntryRow extends StatefulWidget {
  const SplitEntryRow({
    super.key,
    required this.item,
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  final SplitItem item;
  final SplitSummary summary;
  final VoidCallback onTap;

  /// Called once the row has torn away.
  final VoidCallback onDelete;

  @override
  State<SplitEntryRow> createState() => _SplitEntryRowState();
}

class _SplitEntryRowState extends State<SplitEntryRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tear = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  );

  @override
  void dispose() {
    _tear.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    await _tear.forward();
    if (mounted) widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _tear,
      child: SwipeActionRow(
        actions: [
          SwipeAction(
            label: AppStrings.delete,
            icon: Icons.delete_outline_rounded,
            color: colors.destructive,
            onPressed: _delete,
          ),
        ],
        child: Pressable(
          color: Colors.transparent,
          pressedScale: 0.97,
          onTap: widget.onTap,
          child: SplitRowContent(item: widget.item, summary: widget.summary),
        ),
      ),
      builder: (context, child) {
        final torn = AppMotion.exit.transform(_tear.value);
        return Opacity(
          opacity: 1 - torn,
          child: Transform.translate(
            offset: Offset(60 * torn, 0),
            child: Transform.rotate(
              angle: 4 * torn * math.pi / 180,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// The row's icon, title, detail line and amount.
class SplitRowContent extends StatelessWidget {
  const SplitRowContent({super.key, required this.item, required this.summary});

  final SplitItem item;
  final SplitSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entry = item.entry;
    // The people stream can trail the entries' by a frame.
    final payer = summary.people
        .where((p) => p.id == entry.payerId)
        .firstOrNull;
    final sharers = item.saved.shares.length;
    final detail = AppStrings.entryDetail(
      payer == null
          ? ''
          : payer.isMe
          ? AppStrings.you
          : payer.name,
      sharers == summary.people.length
          ? AppStrings.everyone
          : AppStrings.sharerCount(sharers),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 2,
        vertical: AppSpacing.sm - 2,
      ),
      child: Row(
        children: [
          CategoryAvatar.of(item.category),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.note ?? item.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle.copyWith(color: colors.label),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.footnote.copyWith(
                    color: colors.labelSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            formatWithSymbol(entry.amountMinor),
            style: AppTextStyles.amount.copyWith(color: colors.label),
          ),
        ],
      ),
    );
  }
}

/// A deleted entry for a few seconds: the ledger's dark Undo bar, the
/// row's height. It folds away after [kUndoDuration] unless tapped.
class DeletedSplitRow extends StatefulWidget {
  const DeletedSplitRow({
    super.key,
    required this.item,
    required this.summary,
    required this.onUndo,
    required this.onGone,
  });

  final SplitItem item;
  final SplitSummary summary;
  final VoidCallback onUndo;

  /// Called once the row has folded away.
  final VoidCallback onGone;

  @override
  State<DeletedSplitRow> createState() => _DeletedSplitRowState();
}

class _DeletedSplitRowState extends State<DeletedSplitRow>
    with TickerProviderStateMixin {
  late final AnimationController _show = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );
  late final AnimationController _fold = AnimationController(
    vsync: this,
    duration: AppMotion.normal,
  );
  late final Timer _timer;
  bool _undone = false;

  @override
  void initState() {
    super.initState();
    _show.forward();
    _timer = Timer(kUndoDuration, _foldAway);
  }

  @override
  void dispose() {
    _timer.cancel();
    _show.dispose();
    _fold.dispose();
    super.dispose();
  }

  Future<void> _foldAway() async {
    await _fold.forward();
    if (mounted) widget.onGone();
  }

  void _undo() {
    if (_undone) return;
    _timer.cancel();
    setState(() => _undone = true);
    widget.onUndo();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: Listenable.merge([_show, _fold]),
      builder: (context, child) {
        final shown = _undone ? 0.0 : AppMotion.pop.transform(_show.value);
        final folded = AppMotion.exit.transform(_fold.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1 - folded,
            child: Stack(
              children: [
                // Invisible, only to keep the deleted row's height.
                Visibility.maintain(
                  visible: false,
                  child: SplitRowContent(
                    item: widget.item,
                    summary: widget.summary,
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: (shown * (1 - folded)).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * shown,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxs),
                        child: Semantics(
                          button: true,
                          label: AppStrings.undo,
                          child: Pressable(
                            color: colors.label,
                            borderRadius: BorderRadius.circular(AppRadius.tile),
                            onTap: _undo,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppStrings.deleted,
                                      style: AppTextStyles.subheadline.copyWith(
                                        color: colors.background,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    AppStrings.undo,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: colors.background,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
