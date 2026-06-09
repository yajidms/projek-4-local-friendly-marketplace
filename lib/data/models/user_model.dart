import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';
import 'role_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final List<RoleModel> roles;
  final String? marketplaceId;
  final String? sellerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isSynced;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.roles,
    this.marketplaceId,
    this.sellerId,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isSynced = true,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    List<RoleModel>? roles,
    String? marketplaceId,
    String? sellerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isSynced,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      roles: roles ?? this.roles,
      marketplaceId: marketplaceId ?? this.marketplaceId,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Convert model to domain entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      roles: roles.map((r) => r.toEntity()).toList(),
      marketplaceId: marketplaceId,
      sellerId: sellerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: lastSyncedAt,
      isSynced: isSynced,
    );
  }

  /// Create model from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      profileImageUrl: user.profileImageUrl,
      roles: user.roles.map((r) => RoleModel.fromEntity(r)).toList(),
      marketplaceId: user.marketplaceId,
      sellerId: user.sellerId,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastSyncedAt: user.lastSyncedAt,
      isSynced: user.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(_normalizeJson(json));

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    final rawRoles = normalized['roles'];
    if (rawRoles is List) {
      normalized['roles'] = rawRoles
          .map((role) {
            if (role is Map<String, dynamic>) return role;
            if (role is String) return <String, dynamic>{'value': role};
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    } else {
      normalized['roles'] = <Map<String, dynamic>>[];
    }

    normalized['id'] = (normalized['id'] ?? '').toString();
    normalized['name'] = (normalized['name'] ?? '').toString();
    normalized['email'] = (normalized['email'] ?? '').toString();

    final createdAt = normalized['createdAt'];
    if (createdAt is! String) {
      normalized['createdAt'] = DateTime.now().toIso8601String();
    }

    final updatedAt = normalized['updatedAt'];
    if (updatedAt is! String) {
      normalized['updatedAt'] = DateTime.now().toIso8601String();
    }

    return normalized;
  }
}
