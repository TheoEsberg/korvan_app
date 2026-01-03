import 'dart:convert';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:korvan_app/data/services/auth_service.dart';
import '../models/template_model.dart';

class TemplateService {
  static Future<List<TemplateListModel>> getTemplates() async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final res = await ApiService.get("/api/templates", token);
    if (res.statusCode != 200) {
      throw Exception(
        "Failed to load templates: ${res.statusCode} ${res.body}",
      );
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => TemplateListModel.fromJson(e)).toList();
  }

  static Future<TemplateListModel> createTemplate({
    required String name,
    required List<Map<String, String>>
    slots, // [{startTime:"08:00", endTime:"16:00"}]
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final res = await ApiService.post("/api/templates", {
      "name": name,
      "slots": slots,
    }, token: token);

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        "Failed to create template: ${res.statusCode} ${res.body}",
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return TemplateListModel.fromJson(json);
  }
}
