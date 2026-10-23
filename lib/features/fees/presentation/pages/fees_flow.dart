import 'package:flutter/material.dart';

import 'fees_page.dart';

/// Own navigator for the Fees section, so the side menu stays visible
/// while a receipt is open.
class FeesFlow extends StatelessWidget {
  const FeesFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const FeesPage()),
    );
  }
}
