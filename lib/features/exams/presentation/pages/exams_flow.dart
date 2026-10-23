import 'package:flutter/material.dart';

import 'exams_page.dart';

/// Own navigator for the Exams section, so the side menu stays visible.
class ExamsFlow extends StatelessWidget {
  const ExamsFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const ExamsPage()),
    );
  }
}
