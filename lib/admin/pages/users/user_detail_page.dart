import 'package:flutter/material.dart';

import '../../../data/datasources/remote/admin_api_datasource.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/user.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, required this.id});
  final String id;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  User? _user;
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final ds = AdminApiDatasource();
      final user = await ds.getUserById(widget.id);
      final orders = await ds.getOrders();
      final userOrders = orders.where((o) => o.userId == widget.id).toList();
      
      if (mounted) {
        setState(() {
          _user = user;
          _orders = userOrders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AdminScaffold(
        currentRoute: AdminRoutes.users,
        title: 'Loading',
        subtitle: 'Mengambil data pengguna...',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _user == null) {
      return AdminScaffold(
        currentRoute: AdminRoutes.users,
        title: 'Error',
        subtitle: 'Gagal memuat pengguna',
        body: Center(child: Text('Error: ${_error ?? "Not found"}', style: const TextStyle(color: AdminTheme.danger))),
      );
    }

    final user = _user!;
    final orders = _orders;

    return AdminScaffold(
      currentRoute: AdminRoutes.users,
      title: user.name,
      subtitle: user.email,
      headerActions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.users),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Kembali'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            SizedBox(
              width: 320,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AdminTheme.primary.withValues(alpha: 0.15),
                      child: Text(user.name[0], style: const TextStyle(color: AdminTheme.primaryLight, fontSize: 28, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 16),
                    Text(user.name, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 12),
                    StatusBadge(label: user.primaryRole.name, color: user.isAdmin ? AdminTheme.danger : user.isSeller ? AdminTheme.primaryLight : AdminTheme.info),
                    const SizedBox(height: 20),
                    const Divider(color: AdminTheme.border),
                    const SizedBox(height: 12),
                    _info('Telepon', user.phone ?? '-'),
                    _info('ID', user.id),
                    _info('Terdaftar', '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
                    if (user.sellerId != null) _info('Seller ID', user.sellerId!),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Orders
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Riwayat Pesanan (${orders.length})', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    if (orders.isEmpty)
                      const Text('Belum ada pesanan.', style: TextStyle(color: AdminTheme.textMuted))
                    else
                      ...orders.take(10).map((Order o) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AdminTheme.bgSurface,
                          borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                          border: Border.all(color: AdminTheme.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(o.id, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                            StatusBadge(label: o.status.name, color: o.status == OrderStatus.delivered ? AdminTheme.success : o.status == OrderStatus.cancelled ? AdminTheme.danger : AdminTheme.warning),
                            const SizedBox(width: 12),
                            Text('Rp ${o.total.toStringAsFixed(0)}', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}
