// File: lib/app/routes/app_router.dart

import 'package:flutter/material.dart';

import '../presentation/features/seller/views/seller_dashboard_view.dart';
import '../presentation/features/seller/views/seller_registration_view.dart';

/// Named route constants used throughout the app.
class AppRoutes {
  static const String sellerRegistration = '/seller/registrasi';
  static const String sellerDashboard = '/seller/dashboard';
}

/// Centralized route generator.
/// BLoC provision is handled via MultiBlocProvider at the MaterialApp level
/// in main.dart for production; here we wrap per-route for standalone use.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.sellerRegistration:
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (_, a, __) => const SellerRegistrationView(),
          // NFR-ATR-03: Slide-up ≤ 300ms
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: a,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        );

      case AppRoutes.sellerDashboard:
      default:
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (_, a, __) => const SellerDashboardView(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        );
    }
  }
}
