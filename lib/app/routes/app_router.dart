import 'package:flutter/material.dart';

import '../pages/auth_placeholder_page.dart';
import '../pages/main_placeholder_page.dart';
import '../../presentation/pages/catalog_page.dart';
import '../../presentation/pages/checkout_page.dart';
import '../../presentation/pages/product_detail_page.dart';
import '../../presentation/pages/transaction_history_page.dart';

class AppRoutes {
  static const String auth = '/auth';
  static const String main = '/main';
  static const String catalog = '/catalog';
  static const String checkout = '/checkout';
  static const String product = '/product';
  static const String transaction = '/transaction';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.main:
        return MaterialPageRoute<void>(
          builder: (_) => const MainPlaceholderPage(),
          settings: settings,
        );
      // Tambahkan case untuk Catalog
      case AppRoutes.catalog:
        return MaterialPageRoute<void>(
          builder: (_) => const CatalogPage(),
          settings: settings,
        );
      // Tambahkan case untuk Checkout
      case AppRoutes.checkout:
        return MaterialPageRoute<void>(
          builder: (_) => const CheckoutPage(),
          settings: settings,
        );
      // Tambahkan case untuk Detail Produk
      case AppRoutes.product:
        return MaterialPageRoute<void>(
          builder: (_) => const ProductDetailPage(),
          settings: settings,
        );
      // Tambahkan case untuk Riwayat Transaksi
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