import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_logger.dart';

class ApiService {
  static const baseUrl = "http://192.168.0.43:5000";

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = '$baseUrl$endpoint';
    final headers = {"Content-Type": "application/json"};

    ApiLogger.logRequest("POST", url, headers: headers, body: body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      ApiLogger.logResponse(url, response.statusCode, response.body);
      return response;
    } catch (e) {
      ApiLogger.logError(url, e);
      rethrow;
    }
  }

  static Future<http.Response> get(String endpoint, String token) async {
    final url = '$baseUrl$endpoint';
    final headers = {"Authorization": "Bearer $token"};

    ApiLogger.logRequest("GET", url, headers: headers);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      ApiLogger.logResponse(url, response.statusCode, response.body);
      return response;
    } catch (e) {
      ApiLogger.logError(url, e);
      rethrow;
    }
  }
}
