// lib/main.dart
//
// ⚠️ MODE TESTING — Main diubah sementara untuk test Seller Module.
// Untuk restore ke versi asli, uncomment bagian "ORIGINAL" dan hapus
// bagian "TESTING" di bawah ini.

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/env.dart';
import 'app/pages/auth_placeholder_page.dart';
import 'app/routes/app_router.dart';
import 'app/data/sample_data.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  // Init Hive
  await Hive.initFlutter();
  final box = await Hive.openBox('products');
  await Hive.openBox('reviews');

  // 🔴 FIX: Paksa hapus semua memori data lama yang bikin error type 'Null'
  await box.clear();

  // Seed sample data (Pasti akan tereksekusi karena box baru saja dikosongkan)
  if (box.isEmpty) {
    for (final product in sampleProducts) {
      await box.put(product.id, product.toJson());
    }
  }

  runApp(const MyApp());
}

/// ════════════════════════════════════════════════════════
/// APP TESTING — wraps BLoC providers + navigator
/// ════════════════════════════════════════════════════════
class PaDeTestApp extends StatelessWidget {
  /// Repository produk yang sudah disiapkan (Hive)
  final ProductRepository productRepository;

  const PaDeTestApp({super.key, required this.productRepository});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Local Friendly Marketplace',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F6FEB),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FB),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F6FEB),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
          ),
          initialRoute: AppRoutes.auth,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const AuthPlaceholderPage(),
        );
      },
    );
  }
}