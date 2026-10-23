import 'package:flutter/material.dart';

import 'staff_page.dart';

/// Own navigator for the Staff section, so the side menu stays visible.
class StaffFlow extends StatelessWidget {
  const StaffFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const StaffPage()),
    );
  }
}
