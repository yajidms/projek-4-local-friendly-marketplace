import 'package:flutter/material.dart';

import 'routes/admin_router.dart';
import 'theme/admin_theme.dart';

/// Root widget for the PaDe Admin Dashboard (web only).
/// Uses a dark theme with PaDe green branding.
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaDe Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.darkTheme,
      initialRoute: AdminRoutes.login,
      onGenerateRoute: AdminRouter.onGenerateRoute,
    );
  }
}
