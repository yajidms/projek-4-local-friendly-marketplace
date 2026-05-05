import 'dart:convert';

import '../../models/auth_model.dart';
import '../../models/role_model.dart';
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';

class DemoAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<AuthModel> login(String email, String password) async {
    return _buildSession(
      email: email,
      name: _deriveName(email),
      password: password,
      role: 'seller',
    );
  }

  @override
  Future<AuthModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _buildSession(
      email: email,
      name: name,
      password: password,
      role: 'buyer',
    );
  }

  @override
  Future<AuthModel> refreshToken(String refreshToken) async {
    final expiresAt = DateTime.now().add(const Duration(hours: 1));
    final user = UserModel(
      id: 'user_demo',
      name: 'Demo Seller',
      email: 'demo@marketplace.local',
      roles: [RoleModel(value: 'seller')],
      marketplaceId: 'marketplace_001',
      sellerId: 'seller_demo',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    return AuthModel(
      accessToken: _fakeJwt(
        subject: user.id,
        email: user.email,
        expiresAt: expiresAt,
      ),
      refreshToken: refreshToken,
      user: user,
      issuedAt: DateTime.now(),
      expiresAt: expiresAt,
      tokenType: 'Bearer',
    );
  }

  @override
  Future<void> logout() async {
    return;
  }

  AuthModel _buildSession({
    required String email,
    required String name,
    required String password,
    required String role,
  }) {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password are required');
    }

    final userId = 'user_${email.hashCode.abs()}';
    final sellerId = role == 'seller' ? 'seller_${email.hashCode.abs()}' : null;
    final marketplaceId = 'marketplace_001';
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 1));

    final user = UserModel(
      id: userId,
      name: name,
      email: email,
      roles: [
        RoleModel(value: role),
      ],
      marketplaceId: marketplaceId,
      sellerId: sellerId,
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now,
    );

    return AuthModel(
      accessToken:
          _fakeJwt(subject: userId, email: email, expiresAt: expiresAt),
      refreshToken: _fakeJwt(
        subject: userId,
        email: email,
        expiresAt: now.add(const Duration(days: 30)),
      ),
      user: user,
      issuedAt: now,
      expiresAt: expiresAt,
      tokenType: 'Bearer',
    );
  }

  String _deriveName(String email) {
    final localPart = email.split('@').first;
    return localPart
        .replaceAll('.', ' ')
        .split(' ')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _fakeJwt({
    required String subject,
    required String email,
    required DateTime expiresAt,
  }) {
    final header = base64Url
        .encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
    final payload = base64Url.encode(
      utf8.encode(
        jsonEncode({
          'sub': subject,
          'email': email,
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
        }),
      ),
    );
    return '$header.$payload.demo-signature';
  }
}
