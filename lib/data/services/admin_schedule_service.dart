import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:korvan_app/data/services/auth_service.dart';

class AdminScheduleService {
  static Future<void> createShift({
    required String userId,
    required DateTime date,
    required TimeOfDay start,
    required TimeOfDay end,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final body = {
      "shiftDate": DateFormat('yyyy-MM-dd').format(date),
      "startTime": _formatTime(start),
      "endTime": _formatTime(end),
      "employeeId": userId,
      "notes": "",
    };

    final response = await ApiService.post('/api/shifts', body, token: token);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Failed to create shift");
    }
  }

  static String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
}
