import 'package:flutter/material.dart';

import '../../../domain/entities/seller.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class SellerListPage extends StatefulWidget {
  const SellerListPage({super.key});

  @override
  State<SellerListPage> createState() => _SellerListPageState();
}

class _SellerListPageState extends State<SellerListPage> {
  late final AdminRepository _repo;
  List<Seller> _allSellers = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all';
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
      final sellers = await _repo.getSellers();
      if (mounted) setState(() { _allSellers = sellers; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Seller> get _filteredSellers {
    List<Seller> list = _allSellers.toList();
    switch (_filter) {
      case 'verified': list = list.where((s) => s.isVerified).toList(); break;
      case 'unverified': list = list.where((s) => !s.isVerified).toList(); break;
      case 'active': list = list.where((s) => s.isActive).toList(); break;
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((s) => s.shopName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sellers = _filteredSellers;

    return AdminScaffold(
      currentRoute: AdminRoutes.sellers,
      title: 'Penjual',
      subtitle: 'Manajemen toko penjual',
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
        child: Column(children: [
          Row(children: [
            _chip('Semua (${_allSellers.length})', 'all'),
            const SizedBox(width: 8),
            _chip('Terverifikasi', 'verified'),
            const SizedBox(width: 8),
            _chip('Belum Verifikasi', 'unverified'),
            const SizedBox(width: 8),
            _chip('Aktif', 'active'),
            const Spacer(),
            SizedBox(
              width: 260,
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Cari toko...', prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted), isDense: true),
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
              child: sellers.isEmpty
                  ? const Center(child: Text('Tidak ada data.', style: TextStyle(color: AdminTheme.textMuted)))
                  : ListView(children: [
                      _header(),
                      const Divider(height: 1, color: AdminTheme.border),
                      ...sellers.map(_row),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(color: selected ? AdminTheme.primaryLight : AdminTheme.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    color: AdminTheme.bgSurface,
    child: const Row(children: [
      Expanded(flex: 3, child: Text('Nama Toko', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 2, child: Text('Kategori', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Rating', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Produk', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      SizedBox(width: 60),
    ]),
  );

  Widget _row(Seller seller) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => Navigator.of(context).pushNamed(AdminRoutes.sellerDetail, arguments: seller.id),
      hoverColor: AdminTheme.bgHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
        child: Row(children: [
          Expanded(flex: 3, child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AdminTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.storefront_rounded, color: AdminTheme.primaryLight, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(seller.shopName, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          ])),
          Expanded(flex: 2, child: Text(seller.categories.join(', '), style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 1, child: Row(children: [
            const Icon(Icons.star_rounded, color: AdminTheme.warning, size: 16),
            const SizedBox(width: 4),
            Text(seller.rating.toStringAsFixed(1), style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14)),
          ])),
          Expanded(flex: 1, child: Text('${seller.totalProducts}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
          Expanded(flex: 1, child: seller.isVerified ? StatusBadge.verified() : StatusBadge.pending()),
          SizedBox(width: 60, child: IconButton(icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AdminTheme.textSecondary), onPressed: () => Navigator.of(context).pushNamed(AdminRoutes.sellerDetail, arguments: seller.id))),
        ]),
      ),
    ),
  );
}
