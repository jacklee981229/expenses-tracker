import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ledger/ledger_providers.dart';
import 'colour_field.dart';

/// A pushed page over the ledger month's colour field, with a clear app bar
/// so the colour runs up behind it.
class GlowScaffold extends ConsumerWidget {
  const GlowScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColourField(
      spots: ref.watch(ledgerFieldProvider),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
