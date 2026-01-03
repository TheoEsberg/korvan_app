import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:korvan_app/data/models/day_plan_model.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'auth_service.dart';

class DayPlanService {
  static String _dateOnly(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  static Future<DayPlanModel> getOrCreateDayPlan({
    required DateTime date,
    required String templateId,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final dateStr = _dateOnly(date);
    final res = await ApiService.get(
      "/api/admin/day-plans?date=$dateStr&templateId=$templateId",
      token,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load day plan: ${res.statusCode} ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return DayPlanModel.fromJson(json);
  }

  static Future<void> assignEmployee({
    required String dayPlanId,
    required String slotId,
    required String? employeeId,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final res = await ApiService.put(
      "/api/admin/day-plans/$dayPlanId/slots/$slotId",
      {"employeeId": employeeId},
      token: token,
    );

    if (res.statusCode != 204) {
      throw Exception("Assign failed: ${res.statusCode} ${res.body}");
    }
  }

  static Future<Map<String, dynamic>> publish(String dayPlanId) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final res = await ApiService.post(
      "/api/admin/day-plans/$dayPlanId/publish",
      {},
      token: token,
    );

    if (res.statusCode != 200) {
      throw Exception("Publish failed: ${res.statusCode} ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
