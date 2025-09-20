import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/config.dart';

class ApiClient {
  final Map<String, String> Function() _authHeaders;

  ApiClient(this._authHeaders);

  Uri _u(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<http.Response> postJson(String path, Map<String, dynamic> body) async {
    final headers = {
      'Content-Type': 'application/json',
      ..._authHeaders(),
    };
    try {
      return await http.post(_u(path), headers: headers, body: jsonEncode(body));
    } catch (e) {
      print('API Error in postJson: $e');
      rethrow;
    }
  }

  Future<http.Response> get(String path) async {
    final headers = _authHeaders();
    try {
      return await http.get(_u(path), headers: headers);
    } catch (e) {
      print('API Error in get: $e');
      rethrow;
    }
  }

  Future<http.StreamedResponse> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final req = http.MultipartRequest('POST', _u(path));
      req.fields.addAll(fields);
      req.files.add(http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName));
      req.headers.addAll(_authHeaders());
      return await req.send();
    } catch (e) {
      print('API Error in postMultipart: $e');
      rethrow;
    }
  }

  Future<http.Response> responseFromStream(http.StreamedResponse streamResponse) async {
    try {
      return await http.Response.fromStream(streamResponse);
    } catch (e) {
      print('API Error converting stream response: $e');
      rethrow;
    }
  }
}
