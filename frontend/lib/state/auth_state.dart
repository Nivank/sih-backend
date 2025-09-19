import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../utils/config.dart';

class AuthState extends ChangeNotifier {
  static const _tokenKey = 'jwt_token';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> loadToken() async {
    _token = await _secureStorage.read(key: _tokenKey);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      if (token != null) {
        _token = token;
        await _secureStorage.write(key: _tokenKey, value: token);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    await _secureStorage.delete(key: _tokenKey);
    notifyListeners();
  }

  Map<String, String> authHeaders() {
    if (!isAuthenticated) return {};
    return {'Authorization': 'Bearer $_token'};
  }
}
