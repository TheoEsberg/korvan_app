import 'dart:convert';

import 'package:korvan_app/data/models/user_model.dart';
import 'package:korvan_app/data/models/user_profile_model.dart';
import 'package:korvan_app/data/services/api_service.dart';
import 'package:korvan_app/data/services/auth_service.dart';

class UserService {
  static Future<List<UserModel>> getEmployees() async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not Authenticated");

    final response = await ApiService.get("/api/users", token);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load users");
    }
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

  static Future<void> updatePreferences({
    String? profileColorHex,
    String? avatarUrl,
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception("Not authenticated");

    final body = {"profileColorHex": profileColorHex, "avatarUrl": avatarUrl};

    final response = await ApiService.put(
      "/api/users/me/preferences",
      body,
      token: token,
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to update preferences");
    }
  }
}
