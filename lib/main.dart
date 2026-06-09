// lib/main.dart
//
// ⚠️ MODE TESTING — Main diubah sementara untuk test Seller Module.
// Untuk restore ke versi asli, uncomment bagian "ORIGINAL" dan hapus
// bagian "TESTING" di bawah ini.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:hive_flutter/hive_flutter.dart';

// 1. Correct BLoC Imports
import 'package:pade_localfriendly_marketplace/app/presentation/features/seller/bloc/product_bloc.dart';
import 'package:pade_localfriendly_marketplace/app/presentation/features/seller/bloc/transaction_bloc.dart';

// 2. Correct Datasource Imports
import 'package:pade_localfriendly_marketplace/data/datasources/remote/http_product_remote_datasource.dart';
import 'package:pade_localfriendly_marketplace/data/datasources/remote/http_order_remote_datasource.dart';

// 3. Correct Repository Imports
import 'package:pade_localfriendly_marketplace/data/repositories/product_repository_impl.dart';
import 'package:pade_localfriendly_marketplace/data/repositories/order_repository_impl.dart';

import 'package:pade_localfriendly_marketplace/data/datasources/local/in_memory_local_datasources.dart';
import 'package:pade_localfriendly_marketplace/data/datasources/local/hive_order_local_datasource.dart';
import 'config/env.dart';
import 'app/pages/auth_placeholder_page.dart';
import 'app/routes/app_router.dart';

/// ════════════════════════════════════════════════════════
/// 🛠️ MOCK LOCAL DATASOURCES FOR TESTING
/// ════════════════════════════════════════════════════════
// These lightweight mocks satisfy the required `localDataSource` parameters
// without forcing you to instantiate heavy cache logic inside main.dart.
class MockProductLocalDataSource {
  const MockProductLocalDataSource();
}

class MockOrderLocalDataSource {
  const MockOrderLocalDataSource();
}

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  // Hive — used for offline cache by repositories (see app_dependencies.dart)
  await Hive.initFlutter();
  await Hive.openBox<String>('users');
  await Hive.openBox<String>('orders');

  runApp(const MyApp());
}

/// ════════════════════════════════════════════════════════
/// APP TESTING — wraps BLoC providers + navigator
/// ════════════════════════════════════════════════════════
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(
            productRepository: ProductRepositoryImpl(
              remoteDataSource: HttpProductRemoteDataSource(),
              // FIXED: Sourced from in_memory_local_datasources.dart
              localDataSource: InMemoryProductLocalDataSource(), 
            ),
          ),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            orderRepository: OrderRepositoryImpl(
              remoteDataSource: HttpOrderRemoteDataSource(),
              // FIXED: Sourced from hive_order_local_datasource.dart
              localDataSource: HiveOrderLocalDataSource(), 
            ),
          ),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Local Friendly Marketplace',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
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
                seedColor: Colors.green,
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
      ),
    );
  }
}