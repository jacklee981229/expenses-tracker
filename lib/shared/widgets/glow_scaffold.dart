import 'package:flutter/material.dart';

import 'glow_background.dart';

/// A pushed page over the same drifting glow background as the tabs, with
/// a clear app bar so the glow runs up behind it.
class GlowScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
