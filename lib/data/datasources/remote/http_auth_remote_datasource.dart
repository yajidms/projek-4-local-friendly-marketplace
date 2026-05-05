import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/env.dart';
import '../../models/auth_model.dart';
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

  Map<String, dynamic> _extractAuthJson(Map<String, dynamic> body) {
    final candidate = body['data'];
    if (candidate is Map<String, dynamic>) {
      return candidate;
    }
    return body;
  }

  @override
  Future<AuthModel> login(String email, String password) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthModel.fromJson(_extractAuthJson(_readBody(response)));
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
        'Accept': 'application/json'
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthModel.fromJson(_extractAuthJson(_readBody(response)));
    }

    throw Exception('Register failed: ${response.statusCode} ${response.body}');
  }

  @override
  Future<AuthModel> refreshToken(String refreshToken) async {
    final response = await _client.post(
      _uri('/auth/refresh'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthModel.fromJson(_extractAuthJson(_readBody(response)));
    }

    throw Exception(
        'Refresh token failed: ${response.statusCode} ${response.body}');
  }

  @override
  Future<void> logout() async {
    await _client.post(
      _uri('/auth/logout'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );
  }
}
