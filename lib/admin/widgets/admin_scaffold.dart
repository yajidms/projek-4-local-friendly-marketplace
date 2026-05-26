import 'package:flutter/material.dart';
import '../routes/admin_router.dart';
import '../theme/admin_theme.dart';
import 'admin_header.dart';
import 'sidebar/admin_sidebar.dart';

/// Main layout shell for all admin dashboard pages.
/// Wraps content with sidebar navigation and header bar.
class AdminScaffold extends StatefulWidget {
  const AdminScaffold({
    super.key,
    required this.currentRoute,
    required this.title,
    this.subtitle,
    this.headerActions,
    required this.body,
  });

  final String currentRoute;
  final String title;
  final String? subtitle;
  final List<Widget>? headerActions;
  final Widget body;

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _isCollapsed = false;

  void _handleNavigate(String route) {
    if (route != widget.currentRoute) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 768;

    return Scaffold(
      backgroundColor: AdminTheme.bgPrimary,
      drawer: isSmall
          ? Drawer(
              backgroundColor: AdminTheme.sidebarBg,
              child: AdminSidebar(
                currentRoute: widget.currentRoute,
                onNavigate: (route) {
                  Navigator.of(context).pop(); // close drawer
                  _handleNavigate(route);
                },
                pendingVerifications: 3,
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar — hidden on small screens (use drawer instead)
          if (!isSmall)
            AdminSidebar(
              currentRoute: widget.currentRoute,
              onNavigate: _handleNavigate,
              pendingVerifications: 3,
              isCollapsed: _isCollapsed,
              onToggleCollapse: () {
                setState(() => _isCollapsed = !_isCollapsed);
              },
            ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                AdminHeader(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  actions: [
                    if (isSmall)
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: AdminTheme.textSecondary),
                        onPressed: () =>
                            Scaffold.of(context).openDrawer(),
                      ),
                    ...?widget.headerActions,
                  ],
                ),
                Expanded(
                  child: widget.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
