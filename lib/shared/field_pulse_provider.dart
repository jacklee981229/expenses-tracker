import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The category of the expense just added, with a count so adding to the
/// same category twice swells its colour twice. Null until the first add.
final fieldPulseProvider = NotifierProvider<FieldPulseNotifier, FieldPulse?>(
  FieldPulseNotifier.new,
);

typedef FieldPulse = ({String categoryId, int count});

class FieldPulseNotifier extends Notifier<FieldPulse?> {
  @override
  FieldPulse? build() => null;

  void pulse(String categoryId) {
    state = (categoryId: categoryId, count: (state?.count ?? 0) + 1);
  }
}
