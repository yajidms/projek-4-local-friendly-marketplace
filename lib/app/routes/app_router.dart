import 'package:flutter/material.dart';

import '../pages/auth_placeholder_page.dart';
import '../pages/main_placeholder_page.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String main = '/main';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.main:
        return MaterialPageRoute<void>(
          builder: (_) => const MainPlaceholderPage(),
          settings: settings,
        );
      case AppRoutes.auth:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthPlaceholderPage(),
          settings: settings,
        );
    }
  }
}
