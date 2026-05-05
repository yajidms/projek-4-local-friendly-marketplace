import 'role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final List<Role> roles; // A user can have multiple roles
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt; // For offline sync tracking
  final bool isSynced; // Indicates if changes are synced to MongoDB

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isSynced = true,
  });

  /// Check if user has a specific role
  bool hasRole(Role role) => roles.contains(role);

  /// Check if user is a seller
  bool get isSeller => hasRole(Role.seller);

  /// Check if user is an admin
  bool get isAdmin => hasRole(Role.admin);

  /// Check if user is a buyer (default role)
  bool get isBuyer => hasRole(Role.buyer);

  /// Get primary role (for display purposes)
  Role get primaryRole => roles.isNotEmpty ? roles.first : Role.buyer;

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    List<Role>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isSynced,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
