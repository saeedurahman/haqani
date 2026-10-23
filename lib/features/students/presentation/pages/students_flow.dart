import 'package:flutter/material.dart';

import 'students_page.dart';

/// Own navigator for the Students section, so the side menu stays visible
/// while opening a student or the form.
class StudentsFlow extends StatelessWidget {
  const StudentsFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const StudentsPage()),
    );
  }
}
