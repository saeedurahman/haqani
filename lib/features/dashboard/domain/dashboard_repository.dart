import 'dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> loadSummary(DateTime today);
}
