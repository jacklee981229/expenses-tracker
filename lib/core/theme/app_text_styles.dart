import 'package:flutter/painting.dart';

/// Bricolage Grotesque throughout. Colours come from the theme, so these
/// styles inherit the ambient label colour unless a widget overrides it.
///
/// The bundled font is variable, and Flutter does not pick a variable
/// font's weight from `fontWeight` alone, so every style sets its weight and
/// optical size axes. `fontWeight` stays set for the fallback fonts (Chinese
/// notes, for one).
abstract final class AppTextStyles {
  static const String family = 'Bricolage Grotesque';
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const TextStyle largeTitle = TextStyle(
    fontFamily: family,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.1,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 36)],
  );

  /// The small grey line above a large title: "My ledger", "Insights".
  static const TextStyle kicker = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600), FontVariation('opsz', 13)],
  );
  static const TextStyle title2 = TextStyle(
    fontFamily: family,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 22)],
  );
  static const TextStyle title3 = TextStyle(
    fontFamily: family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700), FontVariation('opsz', 20)],
  );
  static const TextStyle headline = TextStyle(
    fontFamily: family,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 17)],
  );
  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500), FontVariation('opsz', 16)],
  );
  static const TextStyle callout = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600), FontVariation('opsz', 15)],
  );
  static const TextStyle subheadline = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600), FontVariation('opsz', 14)],
  );
  static const TextStyle footnote = TextStyle(
    fontFamily: family,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500), FontVariation('opsz', 12.5)],
  );
  static const TextStyle caption1 = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600), FontVariation('opsz', 12)],
  );
  static const TextStyle caption2 = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700), FontVariation('opsz', 12)],
  );

  /// A card's small heading.
  static const TextStyle cardTitle = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 15)],
  );

  /// The title of an expense or category row.
  static const TextStyle rowTitle = TextStyle(
    fontFamily: family,
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700), FontVariation('opsz', 15.5)],
  );

  /// The stamp on top of a receipt: `SUN · 25 OCT`, and `TOTAL`.
  static const TextStyle stamp = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.8,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 12)],
  );

  /// Money in lists: tabular figures so columns of numbers line up.
  static const TextStyle amount = TextStyle(
    fontFamily: family,
    fontSize: 16.5,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 16.5)],
  );

  /// A figure inside a chip, e.g. today's spend on the total card.
  static const TextStyle chipFigure = TextStyle(
    fontFamily: family,
    fontSize: 13.5,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 13.5)],
  );

  /// A receipt's total.
  static const TextStyle receiptTotal = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 18)],
  );

  /// Values in the analysis stat tiles.
  static const TextStyle tileValue = TextStyle(
    fontFamily: family,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 26)],
  );

  /// The big figure on the total card.
  static const TextStyle hero = TextStyle(
    fontFamily: family,
    fontSize: 52,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.8,
    height: 1,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 52)],
  );

  /// Kept for totals shown outside the total card.
  static const TextStyle total = tileValue;

  /// The live amount on the add expense sheet.
  static const TextStyle amountEntry = TextStyle(
    fontFamily: family,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.4,
    height: 1.1,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 48)],
  );

  /// The period total inside the donut's hole.
  static const TextStyle chartCentre = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 16)],
  );

  /// Percent beside each donut slice. A fixed line height keeps each
  /// two-line label compact, so neighbouring labels read apart.
  static const TextStyle chartLabel = TextStyle(
    fontFamily: family,
    fontSize: 12.5,
    height: 1.2,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 12.5)],
  );

  /// The category name under a donut percent.
  static const TextStyle chartName = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600), FontVariation('opsz', 11)],
  );

  static const TextStyle keypadKey = TextStyle(
    fontFamily: family,
    fontSize: 23,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600), FontVariation('opsz', 23)],
  );

  /// Word keys on the keypad: Save & Add, Save.
  static const TextStyle keypadAction = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800), FontVariation('opsz', 14)],
  );
}
