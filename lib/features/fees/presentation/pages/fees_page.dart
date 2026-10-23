import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import 'collect_fee_tab.dart';
import 'fee_structure_tab.dart';
import 'vouchers_tab.dart';

class FeesPage extends StatelessWidget {
  const FeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(title: 'Fees', subtitle: 'Collect fee, make vouchers and set class fees'),
                  SizedBox(height: 16),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: AppColors.border,
                    labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    tabs: [
                      Tab(text: 'Collect Fee'),
                      Tab(text: 'Vouchers'),
                      Tab(text: 'Fee Structure'),
                    ],
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: TabBarView(
                      children: [CollectFeeTab(), VouchersTab(), FeeStructureTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
