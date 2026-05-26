import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../../domain/entities/product.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _ds = AdminMockDatasource();
  String _catFilter = 'all';
  String _search = '';

  List<Product> get _filtered {
    List<Product> list = _ds.products.toList();
    if (_catFilter != 'all') {
      list = list.where((Product p) => p.category == _catFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((Product p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products = _filtered;
    final catNames = _ds.categories.map((c) => c.name).toList().cast<String>();

    return AdminScaffold(
      currentRoute: AdminRoutes.products,
      title: 'Monitoring Produk',
      subtitle: '${_ds.products.length} produk terdaftar',
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AdminTheme.bgSurface,
                    borderRadius: BorderRadius.circular(AdminTheme.radiusSm),
                    border: Border.all(color: AdminTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _catFilter,
                      dropdownColor: AdminTheme.bgCard,
                      style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                      items: [
                        const DropdownMenuItem<String>(value: 'all', child: Text('Semua Kategori')),
                        ...catNames.map((String c) => DropdownMenuItem<String>(value: c, child: Text(c))),
                      ],
                      onChanged: (String? v) => setState(() => _catFilter = v ?? 'all'),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Cari produk...',
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
                    ...products.map(_row),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(color: AdminTheme.bgSurface, borderRadius: BorderRadius.only(topLeft: Radius.circular(AdminTheme.radiusMd), topRight: Radius.circular(AdminTheme.radiusMd))),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Nama Produk', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Kategori', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Harga', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Stok', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Sync', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _row(Product p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(p.name, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(p.category, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
          Expanded(flex: 2, child: Text('Rp ${p.price.toStringAsFixed(0)}', style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w600, fontSize: 14))),
          Expanded(flex: 1, child: Text('${p.quantity}', style: TextStyle(color: p.quantity > 0 ? AdminTheme.textPrimary : AdminTheme.danger, fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(flex: 1, child: StatusBadge(label: p.isAvailable ? 'Tersedia' : 'Habis', color: p.isAvailable ? AdminTheme.success : AdminTheme.danger)),
          Expanded(flex: 1, child: Icon(p.isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, size: 18, color: p.isSynced ? AdminTheme.success : AdminTheme.warning)),
        ],
      ),
    );
  }
}
