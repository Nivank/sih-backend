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
    print('Loaded token: ${_token != null ? 'Token exists (${_token!.length} chars)' : 'No token found'}');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');
    print('Attempting login to: $url');
    
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );
      
      print('Login response: ${resp.statusCode}');
      print('Login response body: ${resp.body}');
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final token = data['access_token'] as String?;
        if (token != null) {
          _token = token;
          await _secureStorage.write(key: _tokenKey, value: token);
          print('Token saved successfully');
          notifyListeners();
          return true;
        } else {
          print('No access_token in response');
        }
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    await _secureStorage.delete(key: _tokenKey);
    notifyListeners();
  }

  Map<String, String> authHeaders() {
    if (!isAuthenticated) {
      print('No token available for auth headers');
      return {};
    }
    print('Using auth token: ${_token!.substring(0, 20)}...');
    return {'Authorization': 'Bearer $_token'};
  }
}
