import 'package:flutter/material.dart';

import 'reports_page.dart';

/// Own navigator for the Reports section, so the side menu stays visible.
class ReportsFlow extends StatelessWidget {
  const ReportsFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const ReportsPage()),
    );
  }
}
