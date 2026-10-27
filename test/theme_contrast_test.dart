import 'package:expense_tracker/core/constants/category_colors.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Text must stay readable with any category colour right behind it at full
/// strength, two blobs overlapping: the worst the colour field can do.
void main() {
  const smallText = 4.5;

  for (final (name, c) in [
    ('light', AppColors.light),
    ('dark', AppColors.dark),
  ]) {
    group('$name theme', () {
      final blobs = [...kCategoryColorHexes.map(colorFromHex), ...c.fieldGaps];

      // The field at its strongest: two uncapped blobs of one colour stacked.
      Color field(Color blob) => c.field(blob, c.fieldAlpha);

      void check(
        String where,
        Color Function(Color blob) background,
        Map<String, Color> texts,
      ) {
        test(where, () {
          for (final blob in blobs) {
            final bg = background(blob);
            for (final MapEntry(key: text, value: fg) in texts.entries) {
              final ratio = contrastRatio(Color.alphaBlend(fg, bg), bg);
              expect(
                ratio,
                greaterThanOrEqualTo(smallText),
                reason:
                    '$text on $where over ${blob.toARGB32().toRadixString(16)}',
              );
            }
          }
        });
      }

      final panelTexts = {
        'label': c.label,
        'labelSecondary': c.labelSecondary,
        'sectionLabel': c.sectionLabel,
      };
      check(
        'text glass',
        (b) => Color.alphaBlend(c.surface, field(b)),
        panelTexts,
      );
      check(
        'text glass top',
        (b) => Color.alphaBlend(c.surfaceTop, field(b)),
        panelTexts,
      );
      check('tab bar', (b) => Color.alphaBlend(c.tabBar, field(b)), {
        'label': c.label,
        'labelSecondary': c.labelSecondary,
      });
      check(
        'sheet',
        (b) => Color.alphaBlend(c.sheetBackground, field(b)),
        panelTexts,
      );

      // Text straight on the page, over one blob's centre at its capped
      // strength: titles 4.5:1, the small grey section labels 3:1.
      test('page text over a blob', () {
        for (final blob in blobs) {
          final page = Color.alphaBlend(
            blob.withValues(alpha: c.blobAlpha(blob)),
            c.background,
          );
          final where = 'page over ${blob.toARGB32().toRadixString(16)}';
          expect(
            contrastRatio(Color.alphaBlend(c.label, page), page),
            greaterThanOrEqualTo(smallText),
            reason: 'label on $where',
          );
          expect(
            contrastRatio(Color.alphaBlend(c.sectionLabel, page), page),
            greaterThanOrEqualTo(3),
            reason: 'sectionLabel on $where',
          );
        }
      });

      final heroTexts = {
        'onHero': c.onHero,
        'onHeroSecondary': c.onHeroSecondary,
      };
      Color hero(Color b) => Color.alphaBlend(c.heroGlass, field(b));
      check('total card', hero, heroTexts);
      check(
        'total card chip',
        (b) => Color.alphaBlend(c.heroChip, hero(b)),
        heroTexts,
      );
      check('amount box', c.box, heroTexts);
      check(
        'amount box chip',
        (b) => Color.alphaBlend(c.heroChip, c.box(b)),
        heroTexts,
      );
    });
  }
}
