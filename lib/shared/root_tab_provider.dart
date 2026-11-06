import 'package:flutter_riverpod/flutter_riverpod.dart';

final rootTabProvider = NotifierProvider<RootTabNotifier, int>(
  RootTabNotifier.new,
);

/// The root shell's tab, so a page inside a tab (the backup banner) can
/// switch to another.
class RootTabNotifier extends Notifier<int> {
  static const int ledger = 0;
  static const int analysis = 1;
  static const int settings = 2;

  @override
  int build() => ledger;

  void select(int tab) => state = tab;
}
