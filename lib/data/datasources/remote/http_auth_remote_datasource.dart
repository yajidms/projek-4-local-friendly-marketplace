import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/env.dart';
import '../../models/auth_model.dart';
import '../../models/role_model.dart';
import '../../models/user_model.dart';
import '../../services/token_manager.dart';
import 'auth_remote_datasource.dart';

class HttpAuthRemoteDataSource implements AuthRemoteDataSource {
  HttpAuthRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final baseUrl = Env.backendUrl;
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Map<String, dynamic> _readBody(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{'data': decoded};
  }

  AuthModel _buildAuth(Map<String, dynamic> data) {
    final userValue = data['user'];
    final token = data['token'] as String;

    UserModel user;
    if (userValue is Map<String, dynamic>) {
      user = UserModel.fromJson(userValue);
    } else if (userValue is String) {
      // Login API returned user as string ID instead of full object
      user = UserModel(
        id: userValue,
        name: '',
        email: '',
        roles: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      throw Exception('Unexpected user format in login response');
    }

    TokenManager.instance.setToken(token);

    final now = DateTime.now();
    final expiresAt = _decodeJwtExp(token) ?? now.add(const Duration(hours: 24));

    return AuthModel(
      accessToken: token,
      user: user,
      issuedAt: now,
      expiresAt: expiresAt,
      tokenType: 'Bearer',
    );
  }

  DateTime? _decodeJwtExp(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final exp = json['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthModel> login(String email, String password) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _readBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return _buildAuth(data);
      }
      // Flat response: {user: {...}, token: "..."}
      if (body.containsKey('user') && body.containsKey('token')) {
        return _buildAuth(body);
      }
      throw Exception('Unexpected login response format');
    }

    throw Exception('Login failed: ${response.statusCode} ${response.body}');
  }

  @override
  Future<AuthModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/auth/register'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _readBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return _buildAuth(data);
      }
      if (body.containsKey('user') && body.containsKey('token')) {
        return _buildAuth(body);
      }
      throw Exception('Unexpected register response format');
    }

    throw Exception(
        'Register failed: ${response.statusCode} ${response.body}');
  }

  @override
  Future<AuthModel> refreshToken(String refreshToken) async {
    final response = await _client.post(
      _uri('/auth/refresh'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _readBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return _buildAuth(data);
      }
      if (body.containsKey('user') && body.containsKey('token')) {
        return _buildAuth(body);
      }
      throw Exception('Unexpected refresh response format');
    }

    throw Exception(
        'Refresh token failed: ${response.statusCode} ${response.body}');
  }

  @override
  Future<void> logout() async {
    TokenManager.instance.clearToken();
    await _client.post(
      _uri('/auth/logout'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }
}
