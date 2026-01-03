import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:korvan_app/data/models/user_list_model.dart';
import 'package:korvan_app/data/models/user_model.dart';
import 'package:korvan_app/data/models/user_profile_model.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:korvan_app/data/services/auth_service.dart';

class UserService {
  static Future<List<UserListModel>> getEmployees() async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final res = await ApiService.get("/api/users", token);
    if (res.statusCode != 200) throw Exception("Failed: ${res.statusCode}");

    final list = jsonDecode(res.body) as List;
    return list.map((e) => UserListModel.fromJson(e)).toList();
  }

  static Future<UserProfileModel> getMe() async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final response = await ApiService.get("/api/users/me", token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfileModel.fromJson(data);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  static Future<void> updatePreferences({String? profileColorHex}) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final body = {"profileColorHex": profileColorHex};

    final response = await ApiService.put(
      "/api/users/me/preferences",
      body,
      token: token,
    );

    if (response.statusCode != 204) {
      throw Exception(
        "Failed to update preferences: ${response.statusCode} ${response.body}",
      );
    }
  }

  static Future<void> uploadMyAvatar(File file) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final uri = Uri.parse('${ApiService.baseUrl}/api/users/me/avatar');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 204) {
      throw Exception(
        "Avatar upload failed: ${response.statusCode} ${response.body}",
      );
    }
  }
}
