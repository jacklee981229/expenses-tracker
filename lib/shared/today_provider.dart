import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';

final todayProvider = NotifierProvider<TodayNotifier, DateTime>(
  TodayNotifier.new,
);

/// Local midnight today. Refreshed when the app resumes, because the date can
/// change while the app sits in the background.
class TodayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => dateOnly(DateTime.now());

  void refresh() {
    final today = dateOnly(DateTime.now());
    if (today != state) state = today;
  }
}
