import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/role_model.dart';
import '../../models/user_model.dart';
import '../../services/token_manager.dart';
import 'user_remote_datasource.dart';

class HttpUserRemoteDataSource implements UserRemoteDataSource {
  HttpUserRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final _token = TokenManager.instance;

  Map<String, dynamic> _readBody(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{'data': decoded};
  }

  UserModel _parseUser(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      if (data.containsKey('user')) {
        return _parseUserValue(data['user']);
      }
      return UserModel.fromJson(data);
    }
    throw Exception('Unexpected response format');
  }

  UserModel _parseUserValue(Object? userValue) {
    if (userValue is Map<String, dynamic>) {
      return UserModel.fromJson(userValue);
    }
    if (userValue is String) {
      return UserModel(
        id: userValue,
        name: '',
        email: '',
        roles: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    throw Exception('Unexpected user format in response');
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final response = await _client.get(
      _token.uri('/users/$id'),
      headers: _token.authHeaders,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseUser(_readBody(response));
    }
    throw Exception('Failed to get user: ${response.statusCode}');
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    final response = await _client.put(
      _token.uri('/users/${user.id}'),
      headers: _token.authHeaders,
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseUser(_readBody(response));
    }
    throw Exception('Failed to update user: ${response.statusCode}');
  }

  @override
  Future<UserModel> addRoleToUser(String userId, String role) async {
    final user = await getUserById(userId);
    final currentRoles =
        user.roles.map((r) => r.value).toList();
    if (!currentRoles.contains(role)) {
      currentRoles.add(role);
    }
    final updated = user.copyWith(
      roles: currentRoles.map((r) => RoleModel(value: r)).toList(),
    );
    return updateUser(updated);
  }

  @override
  Future<UserModel> removeRoleFromUser(String userId, String role) async {
    final user = await getUserById(userId);
    final updatedRoles = user.roles.where((r) => r.value != role).toList();
    final updated = user.copyWith(roles: updatedRoles);
    return updateUser(updated);
  }

  @override
  Future<UserModel> authenticate(String email, String password) async {
    final response = await _client.post(
      _token.uri('/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _readBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic> && data.containsKey('user')) {
        final user = _parseUserValue(data['user']);
        if (data['token'] != null) {
          _token.setToken(data['token'] as String);
        }
        return user;
      }
      return _parseUser(body);
    }
    throw Exception('Authentication failed: ${response.statusCode}');
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _token.uri('/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _readBody(response);
      final data = body['data'];
      if (data is Map<String, dynamic> && data.containsKey('user')) {
        final user = _parseUserValue(data['user']);
        if (data['token'] != null) {
          _token.setToken(data['token'] as String);
        }
        return user;
      }
      return _parseUser(body);
    }
    throw Exception('Registration failed: ${response.statusCode}');
  }

  @override
  Future<void> logout() async {
    _token.clearToken();
  }

  @override
  Future<void> refreshSession() async {
    // Token refresh not supported by backend
  }
}
