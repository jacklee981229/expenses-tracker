import 'package:flutter/material.dart';

/// Colour tokens for the two themes: light (soft lilac ground with drifting
/// colour glows) and dark (a night ground with the same glows, deeper).
///
/// Widgets read these through `context.colors`; they never hardcode colours.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
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
    required this.destructive,
    required this.swipeNeutral,
    required this.heroUp,
    required this.heroDown,
    required this.fill,
    required this.chartOther,
    required this.chartShade,
    required this.expense,
    required this.heroBase,
    required this.heroGlowA,
    required this.heroGlowB,
    required this.cardEdge,
    required this.shadow,
    required this.glowA,
    required this.glowB,
    required this.glowC,
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

  /// The page behind the cards.
  final Color background;

  /// Cards, receipts and grouped lists.
  final Color surface;

  /// Controls on a card: inputs, inner tiles.
  final Color surfaceElevated;

  /// The add sheet and other modal sheets.
  final Color sheetBackground;

  /// Hairlines and the dashes on a receipt.
  final Color separator;
  final Color label;
  final Color labelSecondary;
  final Color labelTertiary;

  /// Day stamps above or on top of the receipts.
  final Color sectionLabel;
  final Color accent;

  /// The dark end of the accent gradient (the + button, Save, pills).
  final Color accentDeep;
  final Color onAccent;
  final Color destructive;

  /// Non-destructive swipe actions (Archive).
  final Color swipeNeutral;

  /// The big total's flash on the violet card: up when spending grows,
  /// down when it shrinks. Light enough to read on the violet.
  final Color heroUp;
  final Color heroDown;

  /// Unselected chips, empty share bars and other filled controls.
  final Color fill;

  /// The merged "Other" slice of the analysis donut.
  final Color chartOther;

  /// The translucent band that shades the inner edge of the donut.
  final Color chartShade;

  /// Expense red, for warnings about money.
  final Color expense;

  /// The total card and amount box: a violet base lit by two soft glows.
  final Color heroBase;
  final Color heroGlowA;
  final Color heroGlowB;

  /// The thin hard edge under a card, before its soft shadow.
  final Color cardEdge;

  /// The soft shadow under cards and floating controls.
  final Color shadow;

  /// The three colour glows drifting behind the pages.
  final Color glowA;
  final Color glowB;
  final Color glowC;

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

  static const AppColors light = AppColors(
    background: Color(0xFFEEF0F7),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF3F2FA),
    sheetBackground: Color(0xFFF6F5FD),
    separator: Color(0xFFE6E5F1),
    label: Color(0xFF17172B),
    labelSecondary: Color(0xFF63637E),
    labelTertiary: Color(0xFF8E8EA6),
    sectionLabel: Color(0xFF66667F),
    accent: Color(0xFF5A4BE8),
    accentDeep: Color(0xFF4A3AD8),
    onAccent: Color(0xFFFFFFFF),
    destructive: Color(0xFFD6335A),
    swipeNeutral: Color(0xFF8A84BE),
    heroUp: Color(0xFFFF6F86),
    heroDown: Color(0xFF6CF2A8),
    fill: Color(0xFFECEBF6),
    chartOther: Color(0xFFC9C8DA),
    chartShade: Color(0x14000000),
    expense: Color(0xFFE8506C),
    heroBase: Color(0xFF5A4BE8),
    heroGlowA: Color(0xFF9B8CFF),
    heroGlowB: Color(0xFFFF8DCB),
    cardEdge: Color(0xFFE3E2EE),
    shadow: Color(0x296E5FC8),
    glowA: Color(0xCCC9C1FF),
    glowB: Color(0xCCFFC7E6),
    glowC: Color(0x8CBEE6FF),
    navButton: Color(0xCCFFFFFF),
    tabBar: Color(0xB8FFFFFF),
    tabIndicator: Color(0xFF17172B),
    tabIndicatorEnd: Color(0xFF17172B),
    tile: Color(0xFFFFFFFF),
    tileBorder: Color(0xFFECEBF6),
    keyFace: Color(0xFFFFFFFF),
    keyShadow: Color(0xFFE2E0F0),
    tint: 0.2,
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF0A0C18),
    surface: Color(0xFF151829),
    surfaceElevated: Color(0xFF1E2238),
    sheetBackground: Color(0xFF12152A),
    separator: Color(0xFF2A2E48),
    label: Color(0xFFEEF0FF),
    labelSecondary: Color(0xFF8C90B2),
    labelTertiary: Color(0xFF5E6283),
    sectionLabel: Color(0xFF8287AB),
    accent: Color(0xFF7B6DFF),
    accentDeep: Color(0xFF4A3AD8),
    onAccent: Color(0xFFFFFFFF),
    destructive: Color(0xFFE0365C),
    swipeNeutral: Color(0xFF3A3F60),
    heroUp: Color(0xFFFF6F86),
    heroDown: Color(0xFF6CF2A8),
    fill: Color(0xFF232741),
    chartOther: Color(0xFF4A4E6A),
    chartShade: Color(0x40000000),
    expense: Color(0xFFFF6B86),
    heroBase: Color(0xFF5A4BE8),
    heroGlowA: Color(0xFF9B8CFF),
    heroGlowB: Color(0xFFFF8DCB),
    cardEdge: Color(0x0DFFFFFF),
    shadow: Color(0x99000000),
    glowA: Color(0x8C5B3FD9),
    glowB: Color(0x590EA5B7),
    glowC: Color(0x33C026D3),
    navButton: Color(0x14FFFFFF),
    tabBar: Color(0xB816192C),
    tabIndicator: Color(0x8C7C6DFF),
    tabIndicatorEnd: Color(0x59FF8DCB),
    tile: Color(0xFF191C30),
    tileBorder: Color(0xFF23263A),
    keyFace: Color(0xFF1F2236),
    keyShadow: Color(0x73000000),
    tint: 0.24,
  );

  bool get isDark => background.computeLuminance() < 0.5;

  /// An icon tile's background: [color] mixed into [onto] (the card behind).
  Color tinted(Color color, {Color? onto}) =>
      Color.lerp(onto ?? surface, color, tint)!;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
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
    Color? destructive,
    Color? swipeNeutral,
    Color? heroUp,
    Color? heroDown,
    Color? fill,
    Color? chartOther,
    Color? chartShade,
    Color? expense,
    Color? heroBase,
    Color? heroGlowA,
    Color? heroGlowB,
    Color? cardEdge,
    Color? shadow,
    Color? glowA,
    Color? glowB,
    Color? glowC,
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
      destructive: destructive ?? this.destructive,
      swipeNeutral: swipeNeutral ?? this.swipeNeutral,
      heroUp: heroUp ?? this.heroUp,
      heroDown: heroDown ?? this.heroDown,
      fill: fill ?? this.fill,
      chartOther: chartOther ?? this.chartOther,
      chartShade: chartShade ?? this.chartShade,
      expense: expense ?? this.expense,
      heroBase: heroBase ?? this.heroBase,
      heroGlowA: heroGlowA ?? this.heroGlowA,
      heroGlowB: heroGlowB ?? this.heroGlowB,
      cardEdge: cardEdge ?? this.cardEdge,
      shadow: shadow ?? this.shadow,
      glowA: glowA ?? this.glowA,
      glowB: glowB ?? this.glowB,
      glowC: glowC ?? this.glowC,
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
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
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
      destructive: mix(destructive, other.destructive),
      swipeNeutral: mix(swipeNeutral, other.swipeNeutral),
      heroUp: mix(heroUp, other.heroUp),
      heroDown: mix(heroDown, other.heroDown),
      fill: mix(fill, other.fill),
      chartOther: mix(chartOther, other.chartOther),
      chartShade: mix(chartShade, other.chartShade),
      expense: mix(expense, other.expense),
      heroBase: mix(heroBase, other.heroBase),
      heroGlowA: mix(heroGlowA, other.heroGlowA),
      heroGlowB: mix(heroGlowB, other.heroGlowB),
      cardEdge: mix(cardEdge, other.cardEdge),
      shadow: mix(shadow, other.shadow),
      glowA: mix(glowA, other.glowA),
      glowB: mix(glowB, other.glowB),
      glowC: mix(glowC, other.glowC),
      navButton: mix(navButton, other.navButton),
      tabBar: mix(tabBar, other.tabBar),
      tabIndicator: mix(tabIndicator, other.tabIndicator),
      tabIndicatorEnd: mix(tabIndicatorEnd, other.tabIndicatorEnd),
      tile: mix(tile, other.tile),
      tileBorder: mix(tileBorder, other.tileBorder),
      keyFace: mix(keyFace, other.keyFace),
      keyShadow: mix(keyShadow, other.keyShadow),
      tint: tint + (other.tint - tint) * t,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
