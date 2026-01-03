class ShiftModel {
  final String id;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String notes;
  final String status;
  final String? employeeId;
  final String? employeeName;
  final String? employeeColorHex;
  final String? employeeAvatarUrl;
  final bool employeeHasAvatar;

  ShiftModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.notes,
    required this.status,
    this.employeeId,
    this.employeeName,
    this.employeeColorHex,
    this.employeeAvatarUrl,
    required this.employeeHasAvatar,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['shiftDate']);
    final start = _parseTimeOnDate(date, json['startTime']);
    final end = _parseTimeOnDate(date, json['endTime']);

    return ShiftModel(
      id: json['id'].toString(),
      date: date,
      startTime: start,
      endTime: end,
      notes: (json['notes'] ?? '').toString(),
      status: json['status'].toString(),
      employeeId: json['employeeId']?.toString(),
      employeeName: json['employeeName']?.toString(),
      employeeColorHex: json['employeeColorHex']?.toString(),
      employeeAvatarUrl: json['employeeAvatarUrl']?.toString(),
      employeeHasAvatar: json['employeeHasAvatar'] ?? false,
    );
  }

  static DateTime _parseTimeOnDate(DateTime base, String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  String formatTimeRange() {
    String fmt(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${fmt(startTime)} – ${fmt(endTime)}';
  }
}
