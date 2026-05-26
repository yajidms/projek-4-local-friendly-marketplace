import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../../domain/entities/seller.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class SellerListPage extends StatefulWidget {
  const SellerListPage({super.key});

  @override
  State<SellerListPage> createState() => _SellerListPageState();
}

class _SellerListPageState extends State<SellerListPage> {
  final _ds = AdminMockDatasource();
  String _filter = 'all';
  String _search = '';

  List<Seller> get _filtered {
    List<Seller> list = _ds.sellers.toList();
    if (_filter == 'verified') list = list.where((Seller s) => s.isVerified).toList();
    if (_filter == 'unverified') list = list.where((Seller s) => !s.isVerified).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((Seller s) => s.shopName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sellers = _filtered;

    return AdminScaffold(
      currentRoute: AdminRoutes.sellers,
      title: 'Manajemen Toko',
      subtitle: '${_ds.sellers.length} toko terdaftar',
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Row(
              children: [
                _chip('Semua', 'all'),
                const SizedBox(width: 8),
                _chip('Terverifikasi', 'verified'),
                const SizedBox(width: 8),
                _chip('Belum Verifikasi', 'unverified'),
                const Spacer(),
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Cari toko...',
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
                    _header(),
                    const Divider(height: 1, color: AdminTheme.border),
                    ...sellers.map(_row),
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
    final sel = _filter == value;
    return FilterChip(
      selected: sel, label: Text(label),
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(color: sel ? AdminTheme.primaryLight : AdminTheme.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(color: AdminTheme.bgSurface, borderRadius: BorderRadius.only(topLeft: Radius.circular(AdminTheme.radiusMd), topRight: Radius.circular(AdminTheme.radiusMd))),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Nama Toko', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Alamat', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Rating', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Produk', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _row(Seller s) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AdminRoutes.sellerDetail, arguments: s.id),
        hoverColor: AdminTheme.bgHover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
          child: Row(
            children: [
              Expanded(flex: 3, child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: AdminTheme.primaryLight.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.storefront_rounded, color: AdminTheme.primaryLight, size: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(s.shopName, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis)),
              ])),
              Expanded(flex: 2, child: Text(s.shopAddress ?? '-', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13), overflow: TextOverflow.ellipsis)),
              Expanded(flex: 1, child: Row(children: [
                const Icon(Icons.star_rounded, color: AdminTheme.accent, size: 16),
                const SizedBox(width: 4),
                Text(s.ratingString, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13)),
              ])),
              Expanded(flex: 1, child: Text('${s.totalProducts}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
              Expanded(flex: 1, child: s.isVerified ? StatusBadge.verified() : StatusBadge.pending()),
              SizedBox(width: 60, child: IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: AdminTheme.textMuted, size: 18), onPressed: () => Navigator.of(context).pushNamed(AdminRoutes.sellerDetail, arguments: s.id))),
            ],
          ),
        ),
      ),
    );
  }
}
