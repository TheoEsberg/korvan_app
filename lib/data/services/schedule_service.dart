import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:korvan_app/data/models/shift_model.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:korvan_app/data/services/auth_service.dart';

class ScheduleService {
  static Future<ShiftModel?> getTodayShift() async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    final token = await AuthService.getAccessToken();
    if (token == null) {
      throw Exception("Not authenticated");
    }

    final uri = '/api/shifts/me?from=$dateStr&to=$dateStr';
    final response = await ApiService.get(uri, token);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) return null;

      // Assume first shift of the day is what we show
      return ShiftModel.fromJson(jsonList.first as Map<String, dynamic>);
    } else {
      throw Exception(
        'Failed to load today\'s shift: ${response.statusCode} ${response.body}',
      );
    }
  }
}
