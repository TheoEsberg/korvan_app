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
    final date = DateTime.parse(json['shiftDate']);
  }
}
