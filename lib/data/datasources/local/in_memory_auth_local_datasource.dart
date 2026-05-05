import '../../models/auth_model.dart';
import 'auth_local_datasource.dart';

class InMemoryAuthLocalDataSource implements AuthLocalDataSource {
  static AuthModel? _session;
  static String? _accessToken;
  static String? _refreshToken;

  @override
  Future<void> clearAuthSession() async {
    _session = null;
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<AuthModel?> getAuthSession() async => _session;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<bool> hasAuthSession() async => _session != null;

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }

  @override
  Future<void> saveAuthSession(AuthModel auth) async {
    _session = auth;
    _accessToken = auth.accessToken;
    _refreshToken = auth.refreshToken;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
  }
}
