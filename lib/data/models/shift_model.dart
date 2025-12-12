class ShiftModel {
  final String id;
  final DateTime shiftDate;
  final DateTime startTime;
  final DateTime endTime;

  ShiftModel({
    required this.id,
    required this.shiftDate,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    // Might need to change so that backend returns
    // "shiftDate": "2025-12-03",
    // "startTime": "07:00:00",
    // "endTime": "16:00:00"

    final date = DateTime.parse(json['shiftDate']);
    final start = _parseDateTime(date, json['startTime']);
    final end = _parseDateTime(date, json['endTime']);

    return ShiftModel(
      id: json['id'],
      shiftDate: date,
      startTime: start,
      endTime: end,
    );
  }

  static DateTime _parseDateTime(DateTime baseDate, String time) {
    // Time like "07:00:00" or "07:00"
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }
}

extension ShiftTimeFormat on DateTime {
  String formatHHmm() {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }
}
