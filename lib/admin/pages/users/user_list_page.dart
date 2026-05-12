import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../../domain/entities/role.dart';
import '../../../domain/entities/user.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _ds = AdminMockDatasource();
  String _roleFilter = 'all';
  String _search = '';

  List<User> get _filteredUsers {
    List<User> list = _ds.users.toList();
    if (_roleFilter != 'all') {
      final roleEnum = RoleExtension.fromString(_roleFilter);
      list = list.where((u) => u.primaryRole == roleEnum).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((u) =>
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return AdminScaffold(
      currentRoute: AdminRoutes.users,
      title: 'Manajemen Pengguna',
      subtitle: '${_ds.users.length} pengguna terdaftar',
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Row(
              children: [
                _chip('Semua', 'all'),
                const SizedBox(width: 8),
                _chip('Buyer', 'buyer'),
                const SizedBox(width: 8),
                _chip('Seller', 'seller'),
                const SizedBox(width: 8),
                _chip('Admin', 'admin'),
                const Spacer(),
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Cari pengguna...',
                      prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: ListView(
                  children: [
                    _tableHeader(),
                    const Divider(height: 1, color: AdminTheme.border),
                    ...users.map(_buildRow),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final sel = _roleFilter == value;
    return FilterChip(
      selected: sel,
      label: Text(label),
      onSelected: (_) => setState(() => _roleFilter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(
        color: sel ? AdminTheme.primaryLight : AdminTheme.textSecondary,
        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: AdminTheme.bgSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AdminTheme.radiusMd),
          topRight: Radius.circular(AdminTheme.radiusMd),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Nama', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 3, child: Text('Email', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Telepon', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Role', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Terdaftar', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildRow(User u) {
    Color roleColor;
    final roleName = u.primaryRole.name;
    switch (roleName) {
      case 'admin':
        roleColor = AdminTheme.danger;
        break;
      case 'seller':
        roleColor = AdminTheme.primaryLight;
        break;
      default:
        roleColor = AdminTheme.info;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AdminRoutes.userDetail, arguments: u.id),
        hoverColor: AdminTheme.bgHover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: roleColor.withValues(alpha: 0.15),
                      child: Text(u.name[0], style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(u.name, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              Expanded(flex: 3, child: Text(u.email, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis)),
              Expanded(flex: 2, child: Text(u.phone ?? '-', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
              Expanded(flex: 1, child: StatusBadge(label: roleName, color: roleColor)),
              Expanded(flex: 2, child: Text('${u.createdAt.day}/${u.createdAt.month}/${u.createdAt.year}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
              SizedBox(
                width: 60,
                child: IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: AdminTheme.textMuted, size: 18), onPressed: () => Navigator.of(context).pushNamed(AdminRoutes.userDetail, arguments: u.id)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
