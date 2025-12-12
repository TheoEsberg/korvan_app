import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  static const storage = FlutterSecureStorage();

  static Future<bool> login(String username, String password) async {
    final response = await ApiService.post("/api/auth/login", {
      "username": username,
      "password": password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "accessToken", value: data["accessToken"]);
      await storage.write(key: "refreshToken", value: data["refreshToken"]);
      return true;
    }

    return false;
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: "accessToken");
  }
}
