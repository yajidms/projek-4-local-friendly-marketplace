import 'package:flutter/material.dart';

import '../../admin/pages/dashboard_page.dart' as admin;
import '../../admin/pages/verification/verification_list_page.dart' as admin;
import '../../admin/pages/verification/verification_detail_page.dart' as admin;
import '../../admin/pages/users/user_list_page.dart' as admin;
import '../../admin/pages/users/user_detail_page.dart' as admin;
import '../../admin/pages/sellers/seller_list_page.dart' as admin;
import '../../admin/pages/sellers/seller_detail_page.dart' as admin;
import '../../admin/pages/products/product_list_page.dart' as admin;
import '../../admin/pages/orders/order_list_page.dart' as admin;
import '../../admin/pages/orders/order_detail_page.dart' as admin;
import '../../admin/pages/categories/category_page.dart' as admin;
import '../../admin/pages/settings/settings_page.dart' as admin;
import '../pages/auth_placeholder_page.dart';
import '../../presentation/pages/home_page.dart'; 
import '../../presentation/pages/profile_page.dart'; 
import '../../presentation/pages/catalog_page.dart';
import '../../presentation/pages/checkout_page.dart';
import '../../presentation/pages/product_detail_page.dart';
import '../../presentation/pages/transaction_history_page.dart';
import '../../presentation/pages/cart_page.dart';
import '../../presentation/pages/register_page.dart';
import 'package:pade_localfriendly_marketplace/data/models/product_model.dart';
import '../presentation/features/seller/views/seller_registration_view.dart';
import '../presentation/features/seller/views/seller_dashboard_view.dart';

/// Named route constants used throughout the app.
class AppRoutes {
  // ── Master branch routes ──────────────────────────────────────
  static const String auth = '/auth';
  static const String home = '/home'; 
  static const String profile = '/profile';
  static const String catalog = '/catalog';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String product = '/product';
  static const String transaction = '/transaction';
  static const String register = '/register';
  static const String sellerRegistration = '/seller/register';
  static const String sellerDashboard = '/seller/dashboard';

  // ── Admin routes (matching AdminRoutes from admin_router.dart) ──
  static const String adminDashboard = '/dashboard';
  static const String adminVerification = '/verification';
  static const String adminVerificationDetail = '/verification/detail';
  static const String adminUsers = '/users';
  static const String adminUserDetail = '/users/detail';
  static const String adminSellers = '/sellers';
  static const String adminSellerDetail = '/sellers/detail';
  static const String adminProducts = '/products';
  static const String adminOrders = '/orders';
  static const String adminOrderDetail = '/orders/detail';
  static const String adminCategories = '/categories';
  static const String adminSettings = '/settings';
}

/// Centralized route generator.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      
      case AppRoutes.profile:
        return MaterialPageRoute<void>(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case AppRoutes.catalog:
        return MaterialPageRoute<void>(
          builder: (_) => const CatalogPage(),
          settings: settings,
        );
        
      case AppRoutes.cart:
        return MaterialPageRoute<void>(
          builder: (_) => const CartPage(),
          settings: settings,
        );

      case AppRoutes.checkout:
        return MaterialPageRoute<void>(
          builder: (_) => const CheckoutPage(),
          settings: settings,
        );
      case AppRoutes.product:
        return MaterialPageRoute<void>(
          builder: (_) => const ProductDetailPage(),
          settings: settings,
        );
      case AppRoutes.transaction:
        return MaterialPageRoute<void>(
          builder: (_) => const TransactionHistoryPage(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      // ── Admin routes ──────────────────────────────────────────
      case AppRoutes.adminDashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.DashboardPage(),
          settings: settings,
        );
      case AppRoutes.adminVerification:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.VerificationListPage(),
          settings: settings,
        );
      case AppRoutes.adminVerificationDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute<void>(
          builder: (_) => admin.VerificationDetailPage(id: id),
          settings: settings,
        );
      case AppRoutes.adminUsers:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.UserListPage(),
          settings: settings,
        );
      case AppRoutes.adminUserDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute<void>(
          builder: (_) => admin.UserDetailPage(id: id),
          settings: settings,
        );
      case AppRoutes.adminSellers:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.SellerListPage(),
          settings: settings,
        );
      case AppRoutes.adminSellerDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute<void>(
          builder: (_) => admin.SellerDetailPage(id: id),
          settings: settings,
        );
      case AppRoutes.adminProducts:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.ProductListPage(),
          settings: settings,
        );
      case AppRoutes.adminOrders:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.OrderListPage(),
          settings: settings,
        );
      case AppRoutes.adminOrderDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute<void>(
          builder: (_) => admin.OrderDetailPage(id: id),
          settings: settings,
        );
      case AppRoutes.adminCategories:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.CategoryPage(),
          settings: settings,
        );
      case AppRoutes.adminSettings:
        return MaterialPageRoute<void>(
          builder: (_) => const admin.SettingsPage(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      // ── Seller routes ─────────────────────────────────────────
      case AppRoutes.sellerRegistration:
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (_, a, __) => const SellerRegistrationView(),
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
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (_, a, __) => const SellerDashboardView(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeInOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        );

      // ── Default: auth ─────────────────────────────────────────
      case AppRoutes.auth:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthPlaceholderPage(),
          settings: settings,
        );
    }
  }
}

// TODO: storeName/storeLat/storeLng should come from backend API product response
// or from joining Seller data via sellerId
extension ProductModelUIExtension on ProductModel {
  String get storeName => 'Toko';
  double get storeLat => 0.0;
  double get storeLng => 0.0;
}
