import 'package:flutter/material.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, required this.id});
  final String id;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late final AdminRepository _repo;
  User? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = AdminProvider.read(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await _repo.getUserDetail(widget.id);
      if (mounted) setState(() { _user = user; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.users,
      title: 'Detail Pengguna',
      subtitle: _user?.name ?? '',
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
              : SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.users),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Kembali ke daftar'),
            ),
            const SizedBox(height: 20),

            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AdminTheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_user!.name, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(_user!.email, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _user!.roles.map((r) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AdminTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(r.name.toUpperCase(), style: const TextStyle(color: AdminTheme.primaryLight, fontSize: 11, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Informasi', style: TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AdminTheme.border),
                const SizedBox(height: 12),
                _infoRow('ID', _user!.id),
                _infoRow('Telepon', _user!.phone ?? '-'),
                _infoRow('Terdaftar', '${_user!.createdAt.day}/${_user!.createdAt.month}/${_user!.createdAt.year}'),
                _infoRow('Diperbarui', '${_user!.updatedAt.day}/${_user!.updatedAt.month}/${_user!.updatedAt.year}'),
                if (_user!.sellerId != null) _infoRow('Seller ID', _user!.sellerId!),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 130, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13))),
    ]),
  );
}
