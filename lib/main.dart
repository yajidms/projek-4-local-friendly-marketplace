import 'package:flutter/material.dart';

import 'config/env.dart';
import 'app/pages/auth_placeholder_page.dart';
import 'app/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F6FEB),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Local Friendly Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
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
  }
}
