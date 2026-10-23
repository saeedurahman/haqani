import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../cubit/students_cubit.dart';
import '../cubit/students_state.dart';

class StudentsFilterBar extends StatelessWidget {
  const StudentsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StudentsCubit>();
    return BlocBuilder<StudentsCubit, StudentsState>(
      buildWhen: (a, b) =>
          a.classes != b.classes || a.classFilter != b.classFilter || a.includeLeft != b.includeLeft,
      builder: (context, state) {
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppSearchField(
              width: 420,
              hint: 'Search by name, father name or ID',
              onChanged: cubit.search,
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<int?>(
                key: ValueKey(state.classFilter),
                initialValue: state.classFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.class_rounded, size: 20, color: AppColors.textMuted),
                ),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All classes')),
                  for (final c in state.classes)
                    DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                ],
                onChanged: cubit.filterByClass,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(value: state.includeLeft, onChanged: cubit.showLeft),
                const SizedBox(width: 6),
                const Text('Show students who left'),
              ],
            ),
          ],
        );
      },
    );
  }
}
