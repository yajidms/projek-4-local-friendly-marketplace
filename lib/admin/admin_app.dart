import 'package:flutter/material.dart';

import '../data/repositories/admin_repository_impl.dart';
import 'routes/admin_router.dart';
import 'theme/admin_theme.dart';
import 'widgets/admin_provider.dart';

/// Root widget for the PaDe Admin Dashboard (web only).
/// Uses a dark theme with PaDe green branding.
/// Provides [AdminRepository] to all admin pages via [AdminProvider].
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminProvider(
      repository: AdminRepositoryImpl(),
      child: MaterialApp(
        title: 'PaDe Admin Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AdminTheme.darkTheme,
        initialRoute: AdminRoutes.login,
        onGenerateRoute: AdminRouter.onGenerateRoute,
      ),
    );
  }
}
