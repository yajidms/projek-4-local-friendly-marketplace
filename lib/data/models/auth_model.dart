import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';
import 'user_model.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class AuthModel {
  @JsonKey(name: 'accessToken')
  final String accessToken;

  @JsonKey(name: 'refreshToken')
  final String? refreshToken;

  final UserModel user;

  @JsonKey(name: 'issuedAt')
  final DateTime issuedAt;

  @JsonKey(name: 'expiresAt')
  final DateTime expiresAt;

  @JsonKey(name: 'tokenType')
  final String tokenType; // Usually "Bearer"

  AuthModel({
    required this.accessToken,
    this.refreshToken,
    required this.user,
    required this.issuedAt,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// Check if token is expired
  bool get isTokenExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token is still valid
  bool get isTokenValid => !isTokenExpired;

  /// Get remaining time until token expires
  Duration get timeUntilExpiration => expiresAt.difference(DateTime.now());

  /// Check if token will expire soon (within 5 minutes)
  bool get shouldRefreshToken =>
      timeUntilExpiration.inMinutes < 5 && timeUntilExpiration.inSeconds > 0;

  AuthModel copyWith({
    String? accessToken,
    String? refreshToken,
    UserModel? user,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return AuthModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  /// Convert model to domain entity
  Auth toEntity() {
    return Auth(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toEntity(),
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      tokenType: tokenType,
    );
  }

  /// Create model from domain entity
  factory AuthModel.fromEntity(Auth auth) {
    return AuthModel(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      user: UserModel.fromEntity(auth.user),
      issuedAt: auth.issuedAt,
      expiresAt: auth.expiresAt,
      tokenType: auth.tokenType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthModel &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken;

  @override
  int get hashCode => accessToken.hashCode;

  /// Convert model to JSON (called automatically by json_serializable)
  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);
}
