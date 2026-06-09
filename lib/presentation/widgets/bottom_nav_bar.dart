import 'package:flutter/material.dart';
import '../../app/routes/app_router.dart';
import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      backgroundColor: theme.colorScheme.surface,
      onTap: (i) {
        if (i == currentIndex) return;
        switch (i) {
          case 0: Navigator.pushReplacementNamed(context, AppRoutes.home);
          case 1: Navigator.pushReplacementNamed(context, AppRoutes.catalog);
          case 2: Navigator.pushReplacementNamed(context, AppRoutes.transaction);
          case 3: Navigator.pushReplacementNamed(context, AppRoutes.profile);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
      ],
    );
  }
}