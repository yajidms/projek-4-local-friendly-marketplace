import 'package:flutter/material.dart';

import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/verification/verification_list_page.dart';
import '../pages/verification/verification_detail_page.dart';
import '../pages/users/user_list_page.dart';
import '../pages/users/user_detail_page.dart';
import '../pages/sellers/seller_list_page.dart';
import '../pages/sellers/seller_detail_page.dart';
import '../pages/products/product_list_page.dart';
import '../pages/orders/order_list_page.dart';
import '../pages/orders/order_detail_page.dart';
import '../pages/categories/category_page.dart';
import '../pages/settings/settings_page.dart';

class AdminRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String verification = '/verification';
  static const String verificationDetail = '/verification/detail';
  static const String users = '/users';
  static const String userDetail = '/users/detail';
  static const String sellers = '/sellers';
  static const String sellerDetail = '/sellers/detail';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/detail';
  static const String categories = '/categories';
  static const String settings = '/settings';
}

class AdminRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case AdminRoutes.dashboard:
        return _fade(const DashboardPage(), routeSettings);
      case AdminRoutes.verification:
        return _fade(const VerificationListPage(), routeSettings);
      case AdminRoutes.verificationDetail:
        final id = routeSettings.arguments as String;
        return _fade(VerificationDetailPage(id: id), routeSettings);
      case AdminRoutes.users:
        return _fade(const UserListPage(), routeSettings);
      case AdminRoutes.userDetail:
        final id = routeSettings.arguments as String;
        return _fade(UserDetailPage(id: id), routeSettings);
      case AdminRoutes.sellers:
        return _fade(const SellerListPage(), routeSettings);
      case AdminRoutes.sellerDetail:
        final id = routeSettings.arguments as String;
        return _fade(SellerDetailPage(id: id), routeSettings);
      case AdminRoutes.products:
        return _fade(const ProductListPage(), routeSettings);
      case AdminRoutes.orders:
        return _fade(const OrderListPage(), routeSettings);
      case AdminRoutes.orderDetail:
        final id = routeSettings.arguments as String;
        return _fade(OrderDetailPage(id: id), routeSettings);
      case AdminRoutes.categories:
        return _fade(const CategoryPage(), routeSettings);
      case AdminRoutes.settings:
        return _fade(const SettingsPage(), routeSettings);
      case AdminRoutes.login:
      default:
        return _fade(const AdminLoginPage(), routeSettings);
    }
  }

  static PageRouteBuilder<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
