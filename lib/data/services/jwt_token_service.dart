import 'dart:convert';

/// JWT Token service for handling token operations
class JwtTokenService {
  /// Check if JWT token is expired
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = _decodeBase64(parts[1]);
      final decodedJson = _parseJson(payload);

      if (decodedJson['exp'] == null) return true;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
        decodedJson['exp'] * 1000,
      );

      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      return true;
    }
  }

  /// Get token expiration time
  static DateTime? getTokenExpirationTime(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = _decodeBase64(parts[1]);
      final decodedJson = _parseJson(payload);

      if (decodedJson['exp'] == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(
        decodedJson['exp'] * 1000,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get time remaining until token expires
  static Duration? getTokenTimeRemaining(String token) {
    final expirationTime = getTokenExpirationTime(token);
    if (expirationTime == null) return null;

    final remaining = expirationTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if token should be refreshed (less than 5 minutes remaining)
  static bool shouldRefreshToken(String token) {
    final remaining = getTokenTimeRemaining(token);
    if (remaining == null) return true;
    return remaining.inMinutes < 5 && remaining.inSeconds > 0;
  }

  /// Extract claims from JWT token
  static Map<String, dynamic>? getTokenClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = _decodeBase64(parts[1]);
      return _parseJson(payload);
    } catch (e) {
      return null;
    }
  }

  /// Get user ID from token
  static String? getUserIdFromToken(String token) {
    final claims = getTokenClaims(token);
    return claims?['sub'] as String? ?? claims?['userId'] as String?;
  }

  /// Get user email from token
  static String? getUserEmailFromToken(String token) {
    final claims = getTokenClaims(token);
    return claims?['email'] as String?;
  }

  /// Decode base64url string (JWT uses this format)
  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64Url.decode(output));
  }

  /// Parse JSON from decoded payload
  static Map<String, dynamic> _parseJson(String str) {
    final jsonMap = jsonDecode(str);
    if (jsonMap is Map<String, dynamic>) {
      return jsonMap;
    }
    throw Exception('Invalid JSON payload');
  }
}
