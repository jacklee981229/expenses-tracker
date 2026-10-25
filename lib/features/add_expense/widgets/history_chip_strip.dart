import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/pill_chip.dart';
import '../add_expense_controller.dart';

/// Notes used before in the selected category, most recent first, as
/// frosted chips at the bottom of the amount box, under the note field they
/// fill. A chip is a description picker only: it fills the note and never
/// touches or shows an amount. Tapping the selected chip clears the note.
/// The chips slide in one after another when the category changes, and the
/// strip folds away, taking no space, when the category has no notes.
class HistoryChipStrip extends ConsumerWidget {
  const HistoryChipStrip({
    super.key,
    required this.categoryId,
    required this.note,
    required this.onSelected,
  });

  final String? categoryId;

  /// The current note; the chip with exactly this text shows as selected.
  final String note;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = this.categoryId;
    final notes = categoryId == null
        ? const <String>[]
        : ref.watch(noteHistoryProvider(categoryId)).valueOrNull ??
              const <String>[];
    final colors = context.colors;
    final onHero = colors.onAccent;

    return AnimatedSize(
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      alignment: Alignment.topCenter,
      child: notes.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm - 2),
              child: SizedBox(
                height: AppSizes.chipHeight,
                // Lazy, so a category with hundreds of notes still scrolls
                // smoothly.
                child: ListView.builder(
                  key: ValueKey(categoryId),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final text = notes[index];
                    final selected = text == note;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: Entrance(
                        delay: staggerDelay(index, cap: 6),
                        offset: const Offset(24, 0),
                        fromTilt: 0,
                        duration: AppMotion.slow,
                        child: PillChip(
                          label: text,
                          selected: selected,
                          color: onHero.withValues(alpha: 0.18),
                          labelColor: onHero,
                          selectedColor: onHero,
                          selectedLabelColor: colors.accentDeep,
                          onTap: () => onSelected(selected ? '' : text),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
