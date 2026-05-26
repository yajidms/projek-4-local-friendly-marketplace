// File: lib/app/routes/app_router.dart

import 'package:flutter/material.dart';

import '../pages/auth_placeholder_page.dart';
import '../../presentation/pages/home_page.dart'; 
import '../../presentation/pages/profile_page.dart'; 
import '../../presentation/pages/catalog_page.dart';
import '../../presentation/pages/checkout_page.dart';
import '../../presentation/pages/product_detail_page.dart';
import '../../presentation/pages/transaction_history_page.dart';
import '../../presentation/pages/cart_page.dart';
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
  static const String sellerRegistration = '/seller/register';
  static const String sellerDashboard = '/seller/dashboard';
}

/// Centralized route generator.
/// BLoC provision is handled via MultiBlocProvider at the MaterialApp level
/// in main.dart for production; here we wrap per-route for standalone use.
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

      // ── Seller routes ─────────────────────────────────────────
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
// 🛠️ UBAH EXTENSION INI DI app_router.dart
extension ProductModelUIExtension on ProductModel {
  String get storeName {
    switch (sellerId) {
      case 'seller_2': return 'Warung Bu Siti';
      case 'seller_3': return 'Toko Elektronik Maju';
      case 'seller_4': return 'Pasar Segar Bu Dewi';
      case 'seller_5': return 'Toko Kelontong Aman';
      default: return 'Toko Sembako Pak Budi'; 
    }
  }

  double get storeLat {
    switch (sellerId) {
      case 'seller_2': return -6.8358;
      case 'seller_3': return -6.8401;
      case 'seller_4': return -6.8445;
      case 'seller_5': return -6.8489;
      default: return -6.8329; 
    }
  }

  double get storeLng {
    switch (sellerId) {
      case 'seller_2': return 107.5471;
      case 'seller_3': return 107.5512;
      case 'seller_4': return 107.5489;
      case 'seller_5': return 107.5398;
      default: return 107.5446; 
    }
  }
  
}