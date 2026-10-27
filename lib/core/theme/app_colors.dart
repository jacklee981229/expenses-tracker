import 'package:flutter/material.dart';

/// Colour tokens for the theme "this month's colours", in a light and a dark
/// version: a plain ground with four soft colour blobs (the month's top
/// categories) behind glass panels.
///
/// The glass is a translucent tint, so the blobs show through it. Text
/// panels are tinted thicker than the total card; `theme_contrast_test`
/// checks every text colour against any category colour behind it.
///
/// Widgets read these through `context.colors`; they never hardcode colours.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceTop,
    required this.glassEdge,
    required this.surfaceElevated,
    required this.sheetBackground,
    required this.separator,
    required this.label,
    required this.labelSecondary,
    required this.labelTertiary,
    required this.sectionLabel,
    required this.accent,
    required this.accentDeep,
    required this.onAccent,
    required this.primary,
    required this.onPrimary,
    required this.destructive,
    required this.swipeNeutral,
    required this.heroGlass,
    required this.onHero,
    required this.onHeroSecondary,
    required this.heroChip,
    required this.heroUp,
    required this.heroDown,
    required this.boxBase,
    required this.boxMix,
    required this.fill,
    required this.chartOther,
    required this.chartShade,
    required this.expense,
    required this.cardEdge,
    required this.shadow,
    required this.fieldAlpha,
    required this.fieldGaps,
    required this.navButton,
    required this.tabBar,
    required this.tabIndicator,
    required this.tabIndicatorEnd,
    required this.tile,
    required this.tileBorder,
    required this.keyFace,
    required this.keyShadow,
    required this.tint,
  });

  /// The plain ground under the colour blobs.
  final Color background;

  /// Glass under text: cards, receipts and grouped lists.
  final Color surface;

  /// The lighter top of that glass, fading into [surface].
  final Color surfaceTop;

  /// The 1px edge around glass.
  final Color glassEdge;

  /// Controls on a card: inputs, inner tiles.
  final Color surfaceElevated;

  /// The add sheet and other modal sheets: nearly solid, so the page's text
  /// never shows through.
  final Color sheetBackground;

  /// Hairlines and the dashes on a receipt.
  final Color separator;
  final Color label;
  final Color labelSecondary;
  final Color labelTertiary;

  /// Day stamps above or on top of the receipts.
  final Color sectionLabel;
  final Color accent;

  /// The dark end of the accent (pills, the scan light's glow).
  final Color accentDeep;
  final Color onAccent;

  /// The + button and Save.
  final Color primary;
  final Color onPrimary;
  final Color destructive;

  /// Non-destructive swipe actions (Archive).
  final Color swipeNeutral;

  /// The total card's thinner glass, where the colour shows most.
  final Color heroGlass;

  /// Text on the total card and the amount box.
  final Color onHero;
  final Color onHeroSecondary;

  /// Chips on the total card and the amount box (Today, legend, history).
  final Color heroChip;

  /// The big total's flash: up when spending grows, down when it shrinks.
  final Color heroUp;
  final Color heroDown;

  /// The amount box while recording: [boxMix] of the category's colour over
  /// [boxBase].
  final Color boxBase;
  final double boxMix;

  /// Unselected chips, empty share bars and other filled controls.
  final Color fill;

  /// The merged "Other" slice of the analysis donut.
  final Color chartOther;

  /// The translucent band that shades the inner edge of the donut.
  final Color chartShade;

  /// Expense red, for warnings about money.
  final Color expense;

  /// The edge of small floating controls (round buttons, tab bar).
  final Color cardEdge;

  /// The soft shadow under cards and floating controls.
  final Color shadow;

  /// How strong each colour blob is at its centre.
  final double fieldAlpha;

  /// The theme's own colours for blobs without a category (a quiet month).
  /// All four are category swatches, so the contrast test covers them.
  final List<Color> fieldGaps;

  /// Small round header buttons.
  final Color navButton;

  /// The floating tab bar and its sliding pill.
  final Color tabBar;
  final Color tabIndicator;
  final Color tabIndicatorEnd;

  /// Category tiles on the add sheet.
  final Color tile;
  final Color tileBorder;

  /// Keypad keys and the hard shadow that lets them press down.
  final Color keyFace;
  final Color keyShadow;

  /// How much category colour goes into an icon tile's background.
  final double tint;

  // Violet, sky, pink and indigo from the category swatches.
  static const List<Color> _gaps = [
    Color(0xFFA16AEA),
    Color(0xFF4FB3E8),
    Color(0xFFE47CC0),
    Color(0xFF7B80E8),
  ];

  static const AppColors light = AppColors(
    background: Color(0xFFF6F4FB),
    surface: Color(0xC7FFFFFF),
    surfaceTop: Color(0xEBFFFFFF),
    glassEdge: Color(0x1217172B),
    surfaceElevated: Color(0x0D17172B),
    sheetBackground: Color(0xFAFAF9FD),
    separator: Color(0x2617172B),
    label: Color(0xFF17172B),
    labelSecondary: Color(0xFF5A5A74),
    labelTertiary: Color(0xFF8A8AA2),
    sectionLabel: Color(0xFF5A5A74),
    accent: Color(0xFF5A4BE8),
    accentDeep: Color(0xFF4A3AD8),
    onAccent: Color(0xFFFFFFFF),
    primary: Color(0xFF17172B),
    onPrimary: Color(0xFFFFFFFF),
    destructive: Color(0xFFD6335A),
    swipeNeutral: Color(0xFF8A84BE),
    heroGlass: Color(0x73FFFFFF),
    onHero: Color(0xFF17172B),
    onHeroSecondary: Color(0xFF45455E),
    heroChip: Color(0xB3FFFFFF),
    heroUp: Color(0xFFC92A50),
    heroDown: Color(0xFF12855A),
    boxBase: Color(0xFFFFFFFF),
    boxMix: 0.32,
    fill: Color(0x1417172B),
    chartOther: Color(0xFFC9C8DA),
    chartShade: Color(0x14000000),
    expense: Color(0xFFD6335A),
    cardEdge: Color(0x1417172B),
    shadow: Color(0x24463A8C),
    fieldAlpha: 0.6,
    fieldGaps: _gaps,
    navButton: Color(0x8CFFFFFF),
    tabBar: Color(0xC7FFFFFF),
    tabIndicator: Color(0x1417172B),
    tabIndicatorEnd: Color(0x0A17172B),
    tile: Color(0xFFFFFFFF),
    tileBorder: Color(0x0F17172B),
    keyFace: Color(0xFFFFFFFF),
    keyShadow: Color(0xFFE4E2EE),
    tint: 0.24,
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF16132E),
    surface: Color(0xB315132E),
    surfaceTop: Color(0xBD221F45),
    glassEdge: Color(0x1AFFFFFF),
    surfaceElevated: Color(0x14FFFFFF),
    sheetBackground: Color(0xF7100E22),
    separator: Color(0x29FFFFFF),
    label: Color(0xFFFFFFFF),
    labelSecondary: Color(0xA8FFFFFF),
    labelTertiary: Color(0x80FFFFFF),
    sectionLabel: Color(0xA8FFFFFF),
    accent: Color(0xFF9D90FF),
    accentDeep: Color(0xFF5B4BE0),
    onAccent: Color(0xFFFFFFFF),
    primary: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF15132E),
    destructive: Color(0xFFE0365C),
    swipeNeutral: Color(0xFF4A4670),
    heroGlass: Color(0x6B100E24),
    onHero: Color(0xFFFFFFFF),
    onHeroSecondary: Color(0xFFFFFFFF),
    // Dark, not white: a lighter chip would cost the text on amber.
    heroChip: Color(0x40100E24),
    heroUp: Color(0xFFFF8FA3),
    heroDown: Color(0xFF7CF2B0),
    boxBase: Color(0xFF14162C),
    boxMix: 0.45,
    fill: Color(0x1FFFFFFF),
    chartOther: Color(0xFF5A5878),
    chartShade: Color(0x40000000),
    expense: Color(0xFFFF6B86),
    cardEdge: Color(0x1AFFFFFF),
    shadow: Color(0x73000000),
    fieldAlpha: 0.72,
    fieldGaps: _gaps,
    navButton: Color(0x6B100E24),
    tabBar: Color(0xB315132E),
    tabIndicator: Color(0x29FFFFFF),
    tabIndicatorEnd: Color(0x14FFFFFF),
    tile: Color(0x0FFFFFFF),
    tileBorder: Color(0x14FFFFFF),
    keyFace: Color(0x12FFFFFF),
    keyShadow: Color(0x59000000),
    tint: 0.3,
  );

  bool get isDark => background.computeLuminance() < 0.5;

  /// An icon tile's background: [color] mixed into [onto] (the card behind).
  Color tinted(Color color, {Color? onto}) =>
      Color.lerp(onto ?? surface, color, tint)!;

  /// The amount box's colour for a category [color].
  Color box(Color color) => Color.lerp(boxBase, color, boxMix)!;

  /// The page at its strongest where blobs of [color] overlap: two of them,
  /// each at [alpha], over [background].
  Color field(Color color, double alpha) {
    final blob = color.withValues(alpha: alpha);
    return Color.alphaBlend(blob, Color.alphaBlend(blob, background));
  }

  /// How strong a blob of [color] may be: [fieldAlpha], or less for a
  /// bright colour on the dark ground, so that at a blob's centre the text
  /// set straight on the page keeps its contrast: titles and other [label]
  /// text 4.5:1, the small grey [sectionLabel] 3:1.
  ///
  /// shortcut: one blob's centre only; where two bright blobs overlap the
  /// labels can dip below that. Upgrade if a page puts small text there.
  double blobAlpha(Color color) {
    const step = 0.02;
    for (var alpha = fieldAlpha; alpha > 0; alpha -= step) {
      final page = Color.alphaBlend(color.withValues(alpha: alpha), background);
      if (contrastRatio(Color.alphaBlend(label, page), page) >= 4.5 &&
          contrastRatio(Color.alphaBlend(sectionLabel, page), page) >= 3) {
        return alpha;
      }
    }
    return 0;
  }

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceTop,
    Color? glassEdge,
    Color? surfaceElevated,
    Color? sheetBackground,
    Color? separator,
    Color? label,
    Color? labelSecondary,
    Color? labelTertiary,
    Color? sectionLabel,
    Color? accent,
    Color? accentDeep,
    Color? onAccent,
    Color? primary,
    Color? onPrimary,
    Color? destructive,
    Color? swipeNeutral,
    Color? heroGlass,
    Color? onHero,
    Color? onHeroSecondary,
    Color? heroChip,
    Color? heroUp,
    Color? heroDown,
    Color? boxBase,
    double? boxMix,
    Color? fill,
    Color? chartOther,
    Color? chartShade,
    Color? expense,
    Color? cardEdge,
    Color? shadow,
    double? fieldAlpha,
    List<Color>? fieldGaps,
    Color? navButton,
    Color? tabBar,
    Color? tabIndicator,
    Color? tabIndicatorEnd,
    Color? tile,
    Color? tileBorder,
    Color? keyFace,
    Color? keyShadow,
    double? tint,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceTop: surfaceTop ?? this.surfaceTop,
      glassEdge: glassEdge ?? this.glassEdge,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      sheetBackground: sheetBackground ?? this.sheetBackground,
      separator: separator ?? this.separator,
      label: label ?? this.label,
      labelSecondary: labelSecondary ?? this.labelSecondary,
      labelTertiary: labelTertiary ?? this.labelTertiary,
      sectionLabel: sectionLabel ?? this.sectionLabel,
      accent: accent ?? this.accent,
      accentDeep: accentDeep ?? this.accentDeep,
      onAccent: onAccent ?? this.onAccent,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      destructive: destructive ?? this.destructive,
      swipeNeutral: swipeNeutral ?? this.swipeNeutral,
      heroGlass: heroGlass ?? this.heroGlass,
      onHero: onHero ?? this.onHero,
      onHeroSecondary: onHeroSecondary ?? this.onHeroSecondary,
      heroChip: heroChip ?? this.heroChip,
      heroUp: heroUp ?? this.heroUp,
      heroDown: heroDown ?? this.heroDown,
      boxBase: boxBase ?? this.boxBase,
      boxMix: boxMix ?? this.boxMix,
      fill: fill ?? this.fill,
      chartOther: chartOther ?? this.chartOther,
      chartShade: chartShade ?? this.chartShade,
      expense: expense ?? this.expense,
      cardEdge: cardEdge ?? this.cardEdge,
      shadow: shadow ?? this.shadow,
      fieldAlpha: fieldAlpha ?? this.fieldAlpha,
      fieldGaps: fieldGaps ?? this.fieldGaps,
      navButton: navButton ?? this.navButton,
      tabBar: tabBar ?? this.tabBar,
      tabIndicator: tabIndicator ?? this.tabIndicator,
      tabIndicatorEnd: tabIndicatorEnd ?? this.tabIndicatorEnd,
      tile: tile ?? this.tile,
      tileBorder: tileBorder ?? this.tileBorder,
      keyFace: keyFace ?? this.keyFace,
      keyShadow: keyShadow ?? this.keyShadow,
      tint: tint ?? this.tint,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    double mixD(double a, double b) => a + (b - a) * t;
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceTop: mix(surfaceTop, other.surfaceTop),
      glassEdge: mix(glassEdge, other.glassEdge),
      surfaceElevated: mix(surfaceElevated, other.surfaceElevated),
      sheetBackground: mix(sheetBackground, other.sheetBackground),
      separator: mix(separator, other.separator),
      label: mix(label, other.label),
      labelSecondary: mix(labelSecondary, other.labelSecondary),
      labelTertiary: mix(labelTertiary, other.labelTertiary),
      sectionLabel: mix(sectionLabel, other.sectionLabel),
      accent: mix(accent, other.accent),
      accentDeep: mix(accentDeep, other.accentDeep),
      onAccent: mix(onAccent, other.onAccent),
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      destructive: mix(destructive, other.destructive),
      swipeNeutral: mix(swipeNeutral, other.swipeNeutral),
      heroGlass: mix(heroGlass, other.heroGlass),
      onHero: mix(onHero, other.onHero),
      onHeroSecondary: mix(onHeroSecondary, other.onHeroSecondary),
      heroChip: mix(heroChip, other.heroChip),
      heroUp: mix(heroUp, other.heroUp),
      heroDown: mix(heroDown, other.heroDown),
      boxBase: mix(boxBase, other.boxBase),
      boxMix: mixD(boxMix, other.boxMix),
      fill: mix(fill, other.fill),
      chartOther: mix(chartOther, other.chartOther),
      chartShade: mix(chartShade, other.chartShade),
      expense: mix(expense, other.expense),
      cardEdge: mix(cardEdge, other.cardEdge),
      shadow: mix(shadow, other.shadow),
      fieldAlpha: mixD(fieldAlpha, other.fieldAlpha),
      fieldGaps: [
        for (var i = 0; i < fieldGaps.length; i++)
          mix(fieldGaps[i], other.fieldGaps[i]),
      ],
      navButton: mix(navButton, other.navButton),
      tabBar: mix(tabBar, other.tabBar),
      tabIndicator: mix(tabIndicator, other.tabIndicator),
      tabIndicatorEnd: mix(tabIndicatorEnd, other.tabIndicatorEnd),
      tile: mix(tile, other.tile),
      tileBorder: mix(tileBorder, other.tileBorder),
      keyFace: mix(keyFace, other.keyFace),
      keyShadow: mix(keyShadow, other.keyShadow),
      tint: mixD(tint, other.tint),
    );
  }
}

/// The WCAG contrast ratio between two opaque colours, 1 to 21.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05);
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
