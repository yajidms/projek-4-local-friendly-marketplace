import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Simple environment loader for Flutter using flutter_dotenv.
///
/// Usage:
///   await Env.load();
///   final base = Env.apiBaseUrl;
class Env {
  /// Load .env file (call from main before runApp)
  static Future<void> load({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  /// Preferred backend URL for auth/network calls.
  ///
  /// Supports `AUTH_API_URL`, `API_BASE_URL`, and `MONGODB_URL` as aliases.
  /// If `MONGODB_URL` is a raw MongoDB connection string, it cannot be called
  /// directly from Flutter; use an HTTP API in front of it.
  static String get backendUrl =>
      dotenv.env['AUTH_API_URL'] ??
      dotenv.env['API_BASE_URL'] ??
      dotenv.env['MONGODB_URL'] ??
      'https://api.example.com';

  /// Backwards-compatible API base URL accessor.
  static String get apiBaseUrl => backendUrl;

  /// Whether the app has a non-default backend URL configured.
  static bool get hasConfiguredBackendUrl =>
      backendUrl.isNotEmpty && backendUrl != 'https://api.example.com';

  /// Whether the configured backend URL looks like a raw MongoDB connection.
  static bool get usesMongoConnectionString =>
      backendUrl.startsWith('mongodb://') ||
      backendUrl.startsWith('mongodb+srv://');

  /// Other env helpers
  static String? get someSecret => dotenv.env['SOME_SECRET'];
}
