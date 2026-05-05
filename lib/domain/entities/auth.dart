import 'user.dart';

class Auth {
  final String accessToken;
  final String? refreshToken;
  final User user;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String tokenType; // Usually "Bearer"

  Auth({
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

  /// Create a copy with modified fields
  Auth copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return Auth(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Auth &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken;

  @override
  int get hashCode => accessToken.hashCode;
}
