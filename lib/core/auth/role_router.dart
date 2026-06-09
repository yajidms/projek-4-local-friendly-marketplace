import 'package:flutter/material.dart';

import '../../domain/entities/index.dart';
import '../../app/routes/app_router.dart';

/// Determines navigation destination based on user roles.
/// Priority: admin > buyer > seller
class RoleRouter {
  /// Navigate to the appropriate page after login, replacing the stack.
  static void navigateAfterLogin(BuildContext context, User user) {
    final route = _routeFor(user);
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  static String _routeFor(User user) {
    if (user.isAdmin) return AppRoutes.adminDashboard;
    if (user.isBuyer) return AppRoutes.home;
    if (user.isSeller) return AppRoutes.sellerDashboard;
    return AppRoutes.home;
  }

  /// Returns true if user can access seller features.
  static bool canAccessSeller(User user) => user.isSeller;

  /// Returns true if user can access admin features.
  static bool canAccessAdmin(User user) => user.isAdmin;
}
