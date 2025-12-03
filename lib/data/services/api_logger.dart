import 'dart:convert';

class ApiLogger {
  static void logRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    print('════════════════ API REQUEST ════════════════');
    print('METHOD: $method');
    print('URL: $url');

    if (headers != null && headers.isNotEmpty) {
      print('HEADERS: ${jsonEncode(headers)}');
    }

    if (body != null) {
      print('BODY: ${body is String ? body : jsonEncode(body)}');
    }

    print('═════════════════════════════════════════════');
  }

  static void logResponse(String url, int statusCode, String responseBody) {
    print('════════════════ API RESPONSE ════════════════');
    print('URL: $url');
    print('STATUS CODE: $statusCode');
    print('BODY: $responseBody');
    print('═════════════════════════════════════════════');
  }

  static void logError(String url, Object error) {
    print('════════════════ API ERROR ════════════════');
    print('URL: $url');
    print('ERROR: $error');
    print('═════════════════════════════════════════════');
  }
}
