import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env.dart';

/// HTTP Client service for API calls with JWT token support
class HttpClientService {
  final http.Client _client = http.Client();

  static const String _authHeader = 'Authorization';
  String? _accessToken;

  /// Set access token for authenticated requests
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear access token (on logout)
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Get base URL from environment
  String get baseUrl => Env.apiBaseUrl;

  /// Build full URL
  String _buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Build headers with JWT token if available
  Map<String, String> _buildHeaders({
    Map<String, String>? additionalHeaders,
  }) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null) {
      headers[_authHeader] = 'Bearer $_accessToken';
    }

    headers.addAll(additionalHeaders ?? {});
    return headers;
  }

  /// Perform GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(additionalHeaders: headers),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Perform POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Perform PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Perform PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Perform DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(additionalHeaders: headers),
          )
          .timeout(const Duration(seconds: 30));

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
