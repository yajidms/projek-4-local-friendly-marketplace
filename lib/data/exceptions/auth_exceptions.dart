/// Authentication exceptions
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' ($code)' : ''}';
}

/// Invalid credentials exception
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
      : super(
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS',
        );
}

/// Token expired exception
class TokenExpiredException extends AuthException {
  TokenExpiredException()
      : super(
          message: 'Access token has expired',
          code: 'TOKEN_EXPIRED',
        );
}

/// Token not found exception
class TokenNotFoundException extends AuthException {
  TokenNotFoundException()
      : super(
          message: 'No valid token found',
          code: 'TOKEN_NOT_FOUND',
        );
}

/// Refresh token failed exception
class RefreshTokenFailedException extends AuthException {
  RefreshTokenFailedException()
      : super(
          message: 'Failed to refresh token. Please login again.',
          code: 'REFRESH_TOKEN_FAILED',
        );
}

/// User not authenticated exception
class UserNotAuthenticatedException extends AuthException {
  UserNotAuthenticatedException()
      : super(
          message: 'User is not authenticated',
          code: 'USER_NOT_AUTHENTICATED',
        );
}

/// User already exists exception
class UserAlreadyExistsException extends AuthException {
  UserAlreadyExistsException()
      : super(
          message: 'User with this email already exists',
          code: 'USER_ALREADY_EXISTS',
        );
}

/// Network error exception
class NetworkException extends AuthException {
  NetworkException({String? message})
      : super(
          message: message ?? 'Network error occurred',
          code: 'NETWORK_ERROR',
        );
}

/// Server error exception
class ServerException extends AuthException {
  ServerException({String? message})
      : super(
          message: message ?? 'Server error occurred',
          code: 'SERVER_ERROR',
        );
}
