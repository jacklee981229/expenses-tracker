import 'package:flutter/widgets.dart';

/// Spacing scale: 4, 8, 12, 16, 20, 24, 32.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// The only five durations in the app: the smaller the thing, the quicker
/// it moves, and closing is a step quicker than opening.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration quick = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration page = Duration(milliseconds: 460);

  /// One slow pass of the light over the amount box while a screenshot is
  /// read. A looping motion, so it stays out of the five above.
  static const Duration sweep = Duration(milliseconds: 1200);

  /// The colour field taking on another month's colours, or one blob
  /// swelling after a save: slow enough to read as the page breathing.
  static const Duration flow = Duration(milliseconds: 1200);

  /// One way of the colour field's drift; it then drifts back. Slow on
  /// purpose: alive, never busy.
  static const Duration drift = Duration(seconds: 20);

  /// Gap between items that enter one after another.
  static const Duration stagger = Duration(milliseconds: 50);

  static const Curve enter = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve exit = Cubic(0.4, 0, 0.6, 1);

  /// Overshoots a little, then settles: pops, wobbles, sheets.
  static const Curve pop = Cubic(0.3, 1.35, 0.5, 1);

  /// The tab and segment pills sliding across.
  static const Curve glide = Cubic(0.3, 1.25, 0.5, 1);
}

/// One spring per kind of thing (mass 1), so each has its own feel and an
/// interrupted animation turns around with its current speed.
abstract final class AppSprings {
  /// A button going down under the finger.
  static const SpringDescription press = SpringDescription(
    mass: 1,
    stiffness: 900,
    damping: 40,
  );

  /// The button coming back: about 0.25 s, one small bounce.
  static const SpringDescription release = SpringDescription(
    mass: 1,
    stiffness: 900,
    damping: 30,
  );

  /// A picked tile or tag: bounces once or twice.
  static const SpringDescription check = SpringDescription(
    mass: 1,
    stiffness: 520,
    damping: 12,
  );

  /// Cards opening: settles in about 0.3 s without overshooting.
  static const SpringDescription card = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 32,
  );
}

abstract final class AppRadius {
  /// Cards, the total card and grouped lists.
  static const double card = 24;

  /// The top corners of a receipt.
  static const double receipt = 22;

  /// The add sheet's amount box.
  static const double panel = 26;

  /// Category tiles, keypad keys and small cards.
  static const double tile = 18;

  /// Controls inside a card: stat tiles, inputs.
  static const double control = 12;
  static const double sheet = 32;
  static const double chip = 12;

  /// Header buttons and the + button.
  static const double button = 14;
  static const double fab = 22;
}

/// Fixed component dimensions, so widgets never carry magic numbers.
abstract final class AppSizes {
  /// A category icon tile in lists: a rounded square tinted with the
  /// category colour, the 3D icon inside.
  static const double avatar = 44;
  static const double smallAvatar = 32;
  static const double previewAvatar = 80;

  /// The icon's share of its tile.
  static const double avatarIconFactor = 0.62;

  /// The tile's corner radius as a share of its size.
  static const double avatarRadiusFactor = 0.34;

  /// The add sheet's category grid.
  static const double gridIcon = 32;
  static const double gridCellHeight = 84;
  static const int categoryGridColumns = 4;

  static const double rowMinHeight = 48;
  static const double tapTarget = 44;
  static const double chipHeight = 34;

  /// Long notes in a chip end in an ellipsis past this width.
  static const double chipLabelMaxWidth = 200;

  /// The date pill inside the add sheet's amount box.
  static const double inlineChipHeight = 30;
  static const double keypadKeyHeight = 54;

  /// How much accent washes the scan key's face.
  static const double keyTint = 0.22;

  /// How far a key travels when pressed: its hard shadow's height.
  static const double keyTravel = 3;
  static const double swipeActionWidth = 76;
  static const double swipeIcon = 24;

  static const double sheetHeaderHeight = 52;
  static const double sheetGrabWidth = 42;
  static const double sheetGrabHeight = 5;

  /// Header buttons: month arrows, settings, filter.
  static const double navButton = 40;
  static const double navIcon = 18;

  /// The period arrows in Analysis.
  static const double periodArrow = 34;

  /// The total card: big figure, sticker, and the last-seven-days bars.
  static const double heroTilt = -1.4;
  static const double heroBarsHeight = 92;
  static const double heroBarWidthFactor = 0.7;
  static const double heroBarMinFactor = 0.06;
  static const double sticker = 56;
  static const double stickerIcon = 32;
  static const double stickerTilt = 14;

  /// The little receipt that prints out of the amount box while a
  /// screenshot is read, and the slot it comes out of.
  static const double scanSlotWidth = 74;
  static const double scanSlotHeight = 7;
  static const double scanPaperWidth = 62;
  static const double scanPaperLength = 78;
  static const double scanPaperRow = 9;
  static const double scanPaperTooth = 5;

  static const int scanPaperTeeth = 6;
  static const double scanPaperMargin = 8;
  static const double scanPaperLine = 3;
  static const double scanPaperBoldLine = 4;
  static const double scanPaperDash = 3;

  /// The bold total line's length, as a share of the paper.
  static const double scanPaperBoldWidth = 0.6;
  static const double scanPaperElevation = 4;

  /// How the receipt leaves once read: torn off to the right.
  static const double scanTearTravel = 60;
  static const double scanTearLift = 4;
  static const double scanTearTilt = 10;

  /// The scan light: brightest in the middle of its band.
  static const double scanLightPeak = 0.38;
  static const double scanLightEdge = 0.26;
  static const List<double> scanLightStops = [0, 0.42, 0.5, 0.58, 1];
  static const double scanSweepHeight = 64;

  /// How blurred the amount is while it is read.
  static const double scanBlur = 4;

  /// Receipts lean a little, alternating left and right.
  static const double receiptTilt = 0.6;
  static const double receiptTooth = 14;
  static const double dashLength = 5;
  static const double dashGap = 4;
  static const double dashThickness = 1.5;

  /// Category tags in the ledger's drawer.
  static const double tagHeight = 40;
  static const double tagIcon = 30;
  static const double tagTilt = 2.5;
  static const double tagNameMaxWidth = 130;

  /// The selected add-sheet tile leans and grows a touch.
  static const double tileTilt = -3;
  static const double tileScale = 1.05;
  static const double pressScale = 0.95;

  static const double labelIcon = 16;

  /// The total card's legend chips: the category's colour dot, and how
  /// wide its name may run before it is cut.
  static const double legendDot = 8;

  /// Rows of chips (Today and the legend) the total card shows at most.
  static const int heroChipLines = 2;
  static const double legendNameMaxWidth = 110;
  static const double inlineIcon = 18;
  static const double repeatGlyph = 14;
  static const double bannerIcon = 20;
  static const double emptyStateIcon = 64;

  /// The + button.
  static const double fab = 62;
  static const double fabIcon = 28;

  /// The floating tab bar.
  static const double tabBarWidth = 250;
  static const double tabBarHeight = 62;
  static const double tabBarInset = 6;
  static const double tabBarBottom = 22;
  static const double tabIcon = 20;

  /// Room under scrolling lists for the floating tab bar and + button.
  static const double fabClearance = 150;

  static const double pickerHeight = 216;
  static const double pickerItemExtent = 32;

  static const int iconPickerColumns = 5;
  static const int colourPickerColumns = 8;
  static const double swatchCheck = 18;
  static const double dragElevation = 6;

  /// Leading slot wide enough for a "Cancel" text button in an app bar.
  static const double navTextButtonWidth = 88;
  static const double swatch = 36;
  static const double iconPickerCell = 56;
  static const double iconPickerIcon = 34;

  static const double segmentHeight = 40;
  static const double segmentInset = 5;

  /// Donut: ring from [pieCenterRadius] out by [pieRadius], labels outside.
  /// Leader lines bend [pieLabelReach] beyond a tapped slice's edge, then run
  /// at least [pieLabelElbow] across to the text. The chart is as tall as
  /// the ring and its labels need. [pieShadeWidth] of the ring's inner edge
  /// is shaded.
  static const double pieRadius = 30;
  static const double pieTouchedRadius = 38;
  static const double pieCenterRadius = 52;
  static const double pieShadeWidth = 6;
  static const double pieSectionSpace = 2;
  static const double pieStartAngle = -90;
  static const double pieLabelReach = 6;
  static const double pieLabelElbow = 10;
  static const double pieLabelGap = 36;
  static const double pieLabelWidth = 92;
  static const double pieLineWidth = 1.4;

  /// The donut's soft shadow, dropped below it.
  static const double pieShadowOffset = 10;
  static const double pieShadowBlur = 14;

  static const double shareBarHeight = 8;

  static const double disabledOpacity = 0.35;
  static const double dimOpacity = 0.4;
  static const double pausedOpacity = 0.45;

  /// One physical pixel, the iOS hairline.
  static double hairline(BuildContext context) =>
      1 / MediaQuery.devicePixelRatioOf(context);
}
