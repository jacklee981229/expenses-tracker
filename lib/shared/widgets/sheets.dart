import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'pill_chip.dart';

/// A Cupertino date (or month/year) wheel in a bottom popup with Cancel and
/// Done. Each of [shortcuts] is a `(label, date)` chip above the wheel that
/// picks its date in one tap. Returns null when cancelled.
Future<DateTime?> showDatePickerSheet(
  BuildContext context, {
  required DateTime initial,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  DateTime? minimum,
  DateTime? maximum,
  List<(String, DateTime)> shortcuts = const [],
}) {
  var value = initial;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (context) => _PickerPopup(
      onDone: () => Navigator.of(context).pop(value),
      shortcuts: [
        for (final (label, date) in shortcuts)
          PillChip(
            label: label,
            selected: date == initial,
            color: context.colors.surface,
            onTap: () => Navigator.of(context).pop(date),
          ),
      ],
      child: CupertinoDatePicker(
        mode: mode,
        initialDateTime: initial,
        minimumDate: minimum,
        maximumDate: maximum,
        onDateTimeChanged: (selected) => value = selected,
      ),
    ),
  );
}

/// A Cupertino wheel over [items]. Returns the chosen index, or null.
Future<int?> showItemPickerSheet(
  BuildContext context, {
  required List<String> items,
  required int initialIndex,
}) {
  var index = initialIndex;
  return showCupertinoModalPopup<int>(
    context: context,
    builder: (context) => _PickerPopup(
      onDone: () => Navigator.of(context).pop(index),
      child: CupertinoPicker(
        itemExtent: AppSizes.pickerItemExtent,
        scrollController: FixedExtentScrollController(
          initialItem: initialIndex,
        ),
        onSelectedItemChanged: (selected) => index = selected,
        children: [for (final item in items) Center(child: Text(item))],
      ),
    ),
  );
}

class _PickerPopup extends StatelessWidget {
  const _PickerPopup({
    required this.onDone,
    required this.child,
    this.shortcuts = const [],
  });

  /// Pops the popup with the wheel's current value.
  final VoidCallback onDone;
  final Widget child;
  final List<Widget> shortcuts;

  @override
  Widget build(BuildContext context) {
    // A Material, not a plain box: Cupertino popups provide no default text
    // style, which the shortcut chips need.
    return Material(
      color: context.colors.surfaceElevated,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: onDone,
                  child: const Text(
                    AppStrings.done,
                    style: AppTextStyles.headline,
                  ),
                ),
              ],
            ),
            if (shortcuts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    for (final shortcut in shortcuts)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: shortcut,
                      ),
                  ],
                ),
              ),
            SizedBox(height: AppSizes.pickerHeight, child: child),
          ],
        ),
      ),
    );
  }
}

/// A one-button alert: Cupertino on iOS, Material elsewhere.
Future<void> showAlert(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showAdaptiveDialog<void>(
    context: context,
    builder: (context) {
      void close() => Navigator.of(context).pop();
      final isApple = switch (Theme.of(context).platform) {
        TargetPlatform.iOS || TargetPlatform.macOS => true,
        _ => false,
      };
      return AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [
          if (isApple)
            CupertinoDialogAction(
              onPressed: close,
              child: const Text(AppStrings.ok),
            )
          else
            TextButton(onPressed: close, child: const Text(AppStrings.ok)),
        ],
      );
    },
  );
}

/// iOS action sheet asking to confirm a destructive action.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
}) async {
  final confirmed = await showOptionsSheet<bool>(
    context,
    title: title,
    message: message,
    options: [SheetOption(confirmLabel, true, destructive: true)],
  );
  return confirmed ?? false;
}

class SheetOption<T> {
  const SheetOption(
    this.label,
    this.value, {
    this.destructive = false,
    this.selected = false,
  });

  final String label;
  final T value;
  final bool destructive;

  /// Shown in bold, e.g. the current setting.
  final bool selected;
}

/// iOS action sheet with a list of options and Cancel. Returns the chosen
/// option's value, or null when cancelled.
Future<T?> showOptionsSheet<T>(
  BuildContext context, {
  required List<SheetOption<T>> options,
  String? title,
  String? message,
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: title == null ? null : Text(title),
      message: message == null ? null : Text(message),
      actions: [
        for (final option in options)
          CupertinoActionSheetAction(
            isDestructiveAction: option.destructive,
            isDefaultAction: option.selected,
            onPressed: () => Navigator.of(context).pop(option.value),
            child: Text(option.label),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppStrings.cancel),
      ),
    ),
  );
}
