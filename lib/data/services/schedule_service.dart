import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:korvan_app/data/models/shift_model.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:korvan_app/data/services/auth_service.dart';

class ScheduleService {
  /// Get the current user's shift for today (or null if none)
  static Future<ShiftModel?> getTodayShift() async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    // Uses GET: api/shifts/me?from=yyyy-MM-dd&to=yyyy-MM-dd
    final response = await ApiService.get(
      '/api/shifts/me?from=$dateStr&to=$dateStr',
      token,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) return null;
      return ShiftModel.fromJson(data.first as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      // no shifts
      return null;
    } else {
      throw Exception(
        'Failed to load today shift: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Get shifts in a date range.
  /// If [onlyMine] is true, uses /api/shifts/me, otherwise /api/shifts.
  static Future<List<ShiftModel>> getShiftsForRange(
    DateTime from,
    DateTime to, {
    bool onlyMine = false,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final fmt = DateFormat('yyyy-MM-dd');
    final fromStr = fmt.format(from);
    final toStr = fmt.format(to);

    final endpoint = onlyMine
        ? '/api/shifts/me?from=$fromStr&to=$toStr'
        : '/api/shifts?from=$fromStr&to=$toStr';

    final response = await ApiService.get(endpoint, token);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ShiftModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Failed to load shifts: ${response.statusCode} ${response.body}',
      );
    }
  }
}
