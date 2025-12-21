import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

      final accessToken = data["accessToken"];
      final refreshToken = data["refreshToken"];

      await storage.write(key: "accessToken", value: accessToken);
      await storage.write(key: "refreshToken", value: refreshToken);

      // Decode JWT
      final decoded = JwtDecoder.decode(accessToken);

      // role might be:
      // "role" OR "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
      final role =
          decoded["role"] ??
          decoded["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];

      if (role != null && role.toString().isNotEmpty) {
        print("Your role is: $role");
      }

      if (role != null) {
        await storage.write(key: "userRole", value: role.toString());
      }
      return true;
    }

    return false;
  }

  static Future<String?> getUserRole() async {
    return await storage.read(key: "userRole");
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: "accessToken");
  }

  static Future<void> clearTokens() async {
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");
  }
}
