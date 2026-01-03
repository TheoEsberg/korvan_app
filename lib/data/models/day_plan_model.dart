class DayPlanModel {
  final String id;
  final String shiftDate; // "YYYY-MM-DD"
  final String templateId;
  final String templateName;
  final bool isPublished;
  final List<DayPlanSlotModel> slots;

  DayPlanModel({
    required this.id,
    required this.shiftDate,
    required this.templateId,
    required this.templateName,
    required this.isPublished,
    required this.slots,
  });

  factory DayPlanModel.fromJson(Map<String, dynamic> json) {
    return DayPlanModel(
      id: json['id'].toString(),
      shiftDate: json['shiftDate'].toString(),
      templateId: json['templateId'].toString(),
      templateName: json['templateName']?.toString() ?? '',
      isPublished: json['isPublished'] ?? false,
      slots: (json['slots'] as List<dynamic>? ?? [])
          .map((e) => DayPlanSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DayPlanSlotModel {
  final String slotId;
  final String startTime; // "HH:mm:ss" or "HH:mm"
  final String endTime;
  final String? employeeId;
  final String? employeeName;
  final String? employeeColorHex;
  final bool employeeHasAvatar;

  DayPlanSlotModel({
    required this.slotId,
    required this.startTime,
    required this.endTime,
    this.employeeId,
    this.employeeName,
    this.employeeColorHex,
    required this.employeeHasAvatar,
  });

  factory DayPlanSlotModel.fromJson(Map<String, dynamic> json) {
    return DayPlanSlotModel(
      slotId: json['slotId'].toString(),
      startTime: json['startTime'].toString(),
      endTime: json['endTime'].toString(),
      employeeId: json['employeeId']?.toString(),
      employeeName: json['employeeName']?.toString(),
      employeeColorHex: json['employeeColorHex']?.toString(),
      employeeHasAvatar: json['employeeHasAvatar'] ?? false,
    );
  }
}
