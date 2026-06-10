import 'package:flutter/material.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final AdminRepository _repo;
  List<Product> _allProducts = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String _categoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _repo = AdminProvider.read(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final products = await _repo.getAllProducts();
      if (mounted) setState(() { _allProducts = products; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<String> get _categories {
    final cats = _allProducts.map((p) => p.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<Product> get _filteredProducts {
    List<Product> list = _allProducts.toList();
    if (_categoryFilter != 'all') {
      list = list.where((p) => p.category == _categoryFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return 'Rp ${(price / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return AdminScaffold(
      currentRoute: AdminRoutes.products,
      title: 'Produk',
      subtitle: 'Semua produk di marketplace',
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
            _chip('Semua (${_allProducts.length})', 'all'),
            const SizedBox(width: 8),
            ..._categories.take(5).map((c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(c, c),
            )),
            const Spacer(),
            SizedBox(
              width: 260,
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Cari produk...', prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted), isDense: true),
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
              child: products.isEmpty
                  ? const Center(child: Text('Tidak ada data.', style: TextStyle(color: AdminTheme.textMuted)))
                  : ListView(children: [
                      _header(),
                      const Divider(height: 1, color: AdminTheme.border),
                      ...products.map(_row),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _categoryFilter == value;
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _categoryFilter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(color: selected ? AdminTheme.primaryLight : AdminTheme.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    color: AdminTheme.bgSurface,
    child: const Row(children: [
      Expanded(flex: 3, child: Text('Nama Produk', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 2, child: Text('Kategori', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Harga', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Stok', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
    ]),
  );

  Widget _row(Product p) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
    child: Row(children: [
      Expanded(flex: 3, child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AdminTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            image: (p.images != null && p.images!.isNotEmpty)
                ? DecorationImage(image: NetworkImage(p.images!.first), fit: BoxFit.cover)
                : null,
          ),
          child: (p.images == null || p.images!.isEmpty)
              ? const Icon(Icons.inventory_2_rounded, color: AdminTheme.primaryLight, size: 18)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(p.name, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ])),
      Expanded(flex: 2, child: Text(p.category, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
      Expanded(flex: 1, child: Text(_formatPrice(p.price), style: const TextStyle(color: AdminTheme.primaryLight, fontSize: 14, fontWeight: FontWeight.w500))),
      Expanded(flex: 1, child: Text('${p.quantity}', style: TextStyle(color: p.quantity > 0 ? AdminTheme.textPrimary : AdminTheme.danger, fontSize: 14))),
      Expanded(flex: 1, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: (p.isAvailable ? AdminTheme.success : AdminTheme.textMuted).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(p.isAvailable ? 'Tersedia' : 'Tidak', style: TextStyle(color: p.isAvailable ? AdminTheme.success : AdminTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
      )),
    ]),
  );
}
