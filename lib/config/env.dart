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

  /// API base URL used by remote datasources
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';

  /// Other env helpers
  static String? get someSecret => dotenv.env['SOME_SECRET'];
}
