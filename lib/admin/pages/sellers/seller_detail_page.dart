import 'package:flutter/material.dart';

import '../../../domain/entities/seller.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class SellerDetailPage extends StatefulWidget {
  const SellerDetailPage({super.key, required this.id});
  final String id;

  @override
  State<SellerDetailPage> createState() => _SellerDetailPageState();
}

class _SellerDetailPageState extends State<SellerDetailPage> {
  late final AdminRepository _repo;
  Seller? _seller;
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
      final seller = await _repo.getSellerDetail(widget.id);
      if (mounted) setState(() { _seller = seller; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.sellers,
      title: 'Detail Penjual',
      subtitle: _seller?.shopName ?? '',
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.sellers),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Kembali ke daftar'),
          ),
          const SizedBox(height: 20),

          // Shop Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminTheme.bgCard,
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AdminTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.storefront_rounded, color: AdminTheme.primaryLight, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_seller!.shopName, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(_seller!.shopDescription ?? '-', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
              ])),
              _seller!.isVerified ? StatusBadge.verified() : StatusBadge.pending(),
            ]),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(children: [
            _statCard(Icons.star_rounded, 'Rating', _seller!.rating.toStringAsFixed(1), AdminTheme.warning),
            const SizedBox(width: 16),
            _statCard(Icons.inventory_2_rounded, 'Produk', '${_seller!.totalProducts}', AdminTheme.info),
            const SizedBox(width: 16),
            _statCard(Icons.reviews_rounded, 'Review', '${_seller!.totalReviews}', AdminTheme.accent),
            const SizedBox(width: 16),
            _statCard(Icons.circle, _seller!.isOnline ? 'Online' : 'Offline', _seller!.isOnline ? 'Ya' : 'Tidak', _seller!.isOnline ? AdminTheme.success : AdminTheme.textMuted),
          ]),
          const SizedBox(height: 20),

          // Detail Info
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _card('Informasi Toko', [
              _infoRow('Alamat', _seller!.shopAddress ?? '-'),
              _infoRow('Telepon', _seller!.shopPhone ?? '-'),
              _infoRow('Kategori', _seller!.categories.join(', ')),
              _infoRow('Terdaftar', '${_seller!.createdAt.day}/${_seller!.createdAt.month}/${_seller!.createdAt.year}'),
            ])),
            const SizedBox(width: 16),
            Expanded(child: _card('Lokasi', [
              _infoRow('Latitude', _seller!.location?.latitude.toStringAsFixed(6) ?? '-'),
              _infoRow('Longitude', _seller!.location?.longitude.toStringAsFixed(6) ?? '-'),
            ])),
          ]),
        ]),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12)),
      ]),
    ),
  );

  Widget _card(String title, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AdminTheme.bgCard,
      borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
      border: Border.all(color: AdminTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      const Divider(height: 1, color: AdminTheme.border),
      const SizedBox(height: 12),
      ...rows,
    ]),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13))),
    ]),
  );
}
