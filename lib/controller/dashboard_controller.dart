import 'dart:convert';
import 'package:get/get.dart';
import '../models/verifier_models.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';
import 'base_controller.dart';
import 'session_controller.dart';

class DashboardController extends BaseController {
  final summary = Rx<DashboardSummary>(DashboardSummary());
  final pendingSyncCount = 0.obs;

  Future<void> loadDashboard() async {
    try {
      final res = await ApiService.to.get(ApiService.urlDashboard);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body is Map ? body['data'] : null;
        if (data is Map<String, dynamic>) {
          summary.value = DashboardSummary.fromJson(data);
        }
      } else {
        showError('Dashboard load failed (${res.statusCode})');
      }
    } catch (e) {
      showError('Dashboard error: $e');
    } finally {
      pendingSyncCount.value = SyncService.to.pendingCount;
    }
  }

  Future<void> refreshAll() async {
    await SessionController.to.loadMe();
    await loadDashboard();
  }

  void refreshSyncCount() {
    pendingSyncCount.value = SyncService.to.pendingCount;
  }
}
