import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Assembles Material [ThemeData] for the light and dark themes from the
/// same token layer.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  /// Status bar icons that read on the page colour.
  static SystemUiOverlayStyle overlayStyle(Brightness brightness) =>
      (brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      error: c.destructive,
      onError: c.onAccent,
      surface: c.surface,
      onSurface: c.label,
    );
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: AppTextStyles.family,
    );
    final chipLabel = AppTextStyles.subheadline.copyWith(color: c.label);

    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: base.textTheme.apply(
        fontFamily: AppTextStyles.family,
        bodyColor: c.label,
        displayColor: c.label,
      ),
      iconTheme: IconThemeData(color: c.accent),
      dividerTheme: DividerThemeData(color: c.separator, space: 0),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: c.label,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: overlayStyle(brightness),
        titleTextStyle: AppTextStyles.headline.copyWith(color: c.label),
        iconTheme: IconThemeData(color: c.label),
        actionsIconTheme: IconThemeData(color: c.accent),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.sheetBackground,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.labelTertiary,
        modalBarrierColor: c.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: AppTextStyles.callout,
          overlayColor: Colors.transparent,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          textStyle: AppTextStyles.headline,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.tile),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.fill,
        selectedColor: c.accent,
        labelStyle: chipLabel,
        secondaryLabelStyle: chipLabel.copyWith(color: c.onAccent),
        side: BorderSide.none,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: AppTextStyles.body.copyWith(color: c.labelTertiary),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.accent),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.label,
        contentTextStyle: AppTextStyles.subheadline.copyWith(
          color: c.background,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.tile),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.accent : c.fill,
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: c.accent,
        scaffoldBackgroundColor: c.background,
        barBackgroundColor: c.surface,
        textTheme: CupertinoTextThemeData(
          textStyle: AppTextStyles.body.copyWith(color: c.label),
          dateTimePickerTextStyle: AppTextStyles.title3.copyWith(
            color: c.label,
          ),
          pickerTextStyle: AppTextStyles.title3.copyWith(color: c.label),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
