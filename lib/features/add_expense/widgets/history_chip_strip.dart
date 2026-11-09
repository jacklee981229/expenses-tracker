import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/note_utils.dart';
import '../../../shared/widgets/entrance.dart';
import '../../../shared/widgets/pill_chip.dart';
import '../add_expense_controller.dart';

/// Notes used before in the selected category, most recent first, as
/// frosted chips at the bottom of the amount box, under the note field they
/// fill. A chip is a description picker only: it fills the note and never
/// touches or shows an amount. Tapping the selected chip clears the note;
/// a long press offers to take the chip away.
/// The chips slide in one after another when the category changes, and the
/// strip folds away, taking no space, when the category has no notes.
class HistoryChipStrip extends ConsumerWidget {
  const HistoryChipStrip({
    super.key,
    required this.categoryId,
    required this.note,
    required this.typed,
    required this.onSelected,
    required this.onHide,
  });

  final String? categoryId;

  /// The current note; the chip with exactly this text shows as selected.
  final String note;

  /// Whether [note] was typed by hand: then only chips with a word starting
  /// with it show, and the strip folds away when none does.
  final bool typed;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onHide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = this.categoryId;
    final history = categoryId == null
        ? const <String>[]
        : ref.watch(noteHistoryProvider(categoryId)).valueOrNull ??
              const <String>[];
    final notes = typed ? notesStartingWith(history, note) : history;
    final colors = context.colors;
    final onHero = colors.onHero;

    return AnimatedSize(
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      alignment: Alignment.topCenter,
      // Lets the chips' soft shadow show below the strip.
      clipBehavior: Clip.none,
      child: notes.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSizes.noteChipGap),
              child: SizedBox(
                height: AppSizes.noteChipHeight,
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
                          small: true,
                          color: colors.noteChip,
                          labelColor: colors.onHeroSecondary,
                          selectedColor: onHero,
                          selectedLabelColor: colors.boxBase,
                          onTap: () => onSelected(selected ? '' : text),
                          onLongPress: () => onHide(text),
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
