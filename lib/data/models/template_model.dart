class TemplateListModel {
  final String id;
  final String name;

  TemplateListModel({required this.id, required this.name});

  factory TemplateListModel.fromJson(Map<String, dynamic> json) {
    return TemplateListModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
    );
  }
}
