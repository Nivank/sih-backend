import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/config.dart';

class ApiClient {
  final Map<String, String> Function() _authHeaders;

  ApiClient(this._authHeaders);

  Uri _u(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<http.Response> postJson(String path, Map<String, dynamic> body) {
    final headers = {
      'Content-Type': 'application/json',
      ..._authHeaders(),
    };
    return http.post(_u(path), headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> get(String path) {
    final headers = _authHeaders();
    return http.get(_u(path), headers: headers);
  }

  Future<http.StreamedResponse> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final req = http.MultipartRequest('POST', _u(path));
    req.fields.addAll(fields);
    req.files.add(http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName));
    req.headers.addAll(_authHeaders());
    return req.send();
  }
}
