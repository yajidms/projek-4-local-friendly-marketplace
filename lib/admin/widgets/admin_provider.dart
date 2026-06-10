import 'package:flutter/material.dart';
import '../../domain/repositories/admin_repository.dart';

/// InheritedWidget that provides [AdminRepository] to the admin widget tree.
class AdminProvider extends InheritedWidget {
  const AdminProvider({
    super.key,
    required this.repository,
    required super.child,
  });

  final AdminRepository repository;

  static AdminRepository of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AdminProvider>();
    assert(provider != null, 'AdminProvider not found in widget tree');
    return provider!.repository;
  }

  /// Convenience method that doesn't register dependency (for initState usage).
  static AdminRepository read(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<AdminProvider>();
    assert(provider != null, 'AdminProvider not found in widget tree');
    return provider!.repository;
  }

  @override
  bool updateShouldNotify(AdminProvider oldWidget) =>
      repository != oldWidget.repository;
}
