import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../cubit/admissions_cubit.dart';
import '../cubit/admissions_state.dart';

class AdmissionsFilterBar extends StatelessWidget {
  const AdmissionsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdmissionsCubit>();
    return BlocBuilder<AdmissionsCubit, AdmissionsState>(
      buildWhen: (a, b) => a.from != b.from || a.to != b.to,
      builder: (context, state) {
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            AppSearchField(
              width: 380,
              hint: 'Search by name, father name or number',
              onChanged: cubit.search,
            ),
            SizedBox(
              width: 220,
              child: AppDateField(
                label: 'Admitted from',
                value: state.from,
                onChanged: (d) => cubit.setRange(from: d, to: state.to),
              ),
            ),
            SizedBox(
              width: 220,
              child: AppDateField(
                label: 'Admitted to',
                value: state.to,
                onChanged: (d) => cubit.setRange(from: state.from, to: d),
              ),
            ),
          ],
        );
      },
    );
  }
}
