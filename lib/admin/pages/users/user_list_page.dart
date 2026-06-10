import 'package:flutter/material.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late final AdminRepository _repo;
  List<User> _allUsers = [];
  bool _loading = true;
  String? _error;
  String _roleFilter = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _repo = AdminProvider.read(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final users = await _repo.getUsers();
      if (mounted) setState(() { _allUsers = users; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<User> get _filteredUsers {
    List<User> list = _allUsers.toList();
    if (_roleFilter != 'all') {
      list = list.where((u) => u.primaryRole.name == _roleFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return AdminScaffold(
      currentRoute: AdminRoutes.users,
      title: 'Pengguna',
      subtitle: 'Manajemen akun pengguna',
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AdminTheme.primaryLight))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, color: AdminTheme.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
                ]))
              : Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Row(children: [
              _chip('Semua (${_allUsers.length})', 'all'),
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
                  decoration: const InputDecoration(hintText: 'Cari pengguna...', prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted), isDense: true),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: users.isEmpty
                    ? const Center(child: Text('Tidak ada data.', style: TextStyle(color: AdminTheme.textMuted)))
                    : ListView(children: [
                        _tableHeader(),
                        const Divider(height: 1, color: AdminTheme.border),
                        ...users.map(_tableRow),
                      ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _roleFilter == value;
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _roleFilter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(color: selected ? AdminTheme.primaryLight : AdminTheme.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
    );
  }

  Widget _tableHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    color: AdminTheme.bgSurface,
    child: const Row(children: [
      Expanded(flex: 3, child: Text('Nama', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 3, child: Text('Email', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 2, child: Text('Role', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 2, child: Text('Terdaftar', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      SizedBox(width: 60),
    ]),
  );

  Widget _tableRow(User user) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => Navigator.of(context).pushNamed(AdminRoutes.userDetail, arguments: user.id),
      hoverColor: AdminTheme.bgHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
        child: Row(children: [
          Expanded(flex: 3, child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: AdminTheme.primary.withValues(alpha: 0.15), child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w600, fontSize: 13))),
            const SizedBox(width: 10),
            Expanded(child: Text(user.name, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          ])),
          Expanded(flex: 3, child: Text(user.email, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
          Expanded(flex: 2, child: _roleBadge(user.primaryRole.name)),
          Expanded(flex: 2, child: Text('${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
          SizedBox(width: 60, child: IconButton(icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AdminTheme.textSecondary), onPressed: () => Navigator.of(context).pushNamed(AdminRoutes.userDetail, arguments: user.id))),
        ]),
      ),
    ),
  );

  Widget _roleBadge(String role) {
    Color color;
    switch (role) {
      case 'admin': color = AdminTheme.danger; break;
      case 'seller': color = AdminTheme.warning; break;
      default: color = AdminTheme.info;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(role.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
