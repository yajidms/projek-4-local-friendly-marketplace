import 'package:flutter/material.dart';

import '../pages/auth_placeholder_page.dart';
import '../../presentation/pages/home_page.dart'; 
import '../../presentation/pages/profile_page.dart'; 
import '../../presentation/pages/catalog_page.dart';
import '../../presentation/pages/checkout_page.dart';
import '../../presentation/pages/product_detail_page.dart';
import '../../presentation/pages/transaction_history_page.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String home = '/home'; 
  static const String profile = '/profile';
  static const String catalog = '/catalog';
  static const String checkout = '/checkout';
  static const String product = '/product';
  static const String transaction = '/transaction';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 1. Arahkan ke HomePage() yang sesuai Figma
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      
      // 2. Tambahkan case untuk ProfilePage()
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
      case AppRoutes.auth:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthPlaceholderPage(),
          settings: settings,
        );
    }
  }
}