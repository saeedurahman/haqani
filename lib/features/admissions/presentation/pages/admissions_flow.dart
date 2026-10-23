import 'package:flutter/material.dart';

import 'admissions_page.dart';

/// Own navigator for the Admissions section, so the side menu stays visible.
class AdmissionsFlow extends StatelessWidget {
  const AdmissionsFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const AdmissionsPage()),
    );
  }
}
