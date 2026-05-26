import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get authApiUrl => dotenv.env['AUTH_API_URL'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get mongodbUrl => dotenv.env['MONGODB_URL'] ?? '';
  
  static String get backendUrl => authApiUrl.isNotEmpty ? authApiUrl : apiBaseUrl;
  static bool get hasConfiguredBackendUrl => backendUrl.isNotEmpty && !backendUrl.contains('example.com');
  static bool get usesMongoConnectionString => mongodbUrl.isNotEmpty;
}
