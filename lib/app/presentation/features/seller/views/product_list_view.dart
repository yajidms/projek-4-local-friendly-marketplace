// File: lib/app/presentation/features/seller/views/product_list_view.dart
//
// Menampilkan daftar produk milik penjual dengan:
// - Search bar (real-time filter)
// - Filter kategori (chip)
// - Card produk + badge stok & sinkronisasi
// - Swipe-to-delete dengan konfirmasi
// - Tombol edit → ProductFormView

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/seller_theme.dart';
import '../../../../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import 'product_form_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  String _query = '';
  String? _filterCategory;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductMemuat || state is ProductSedangSinkron) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductGagal) {
          return _ErrorView(message: state.pesan);
        }
        if (state is ProductTertampil) {
          return _buildList(context, state.products);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildList(BuildContext context, List<Product> allProducts) {
    // Kumpulkan semua kategori unik
    final categories = allProducts.map((p) => p.category).toSet().toList()
      ..sort();

    // Filter berdasarkan query & kategori
    final filtered = allProducts.where((p) {
      final matchQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase());
      final matchCat = _filterCategory == null || p.category == _filterCategory;
      return matchQuery && matchCat;
    }).toList();

    return Column(
      children: [
        // ── Search & Filter Bar ───────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari nama atau kategori produk...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF9E9E9E)),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _query = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SellerTheme.borderRadiusSmall),
                    borderSide: const BorderSide(color: SellerTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SellerTheme.borderRadiusSmall),
                    borderSide: const BorderSide(color: SellerTheme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(SellerTheme.borderRadiusSmall),
                    borderSide: const BorderSide(
                        color: SellerTheme.primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 10),
              // Chip filter kategori
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'Semua',
                      selected: _filterCategory == null,
                      onTap: () => setState(() => _filterCategory = null),
                    ),
                    ...categories.map((cat) => _CategoryChip(
                          label: cat,
                          selected: _filterCategory == cat,
                          onTap: () =>
                              setState(() => _filterCategory = cat),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── List Produk ───────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(query: _query)
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) =>
                      _ProductCard(product: filtered[i]),
                ),
        ),

        // ── FAB: Tambah Produk ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToForm(context, null),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Produk Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SellerTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SellerTheme.borderRadius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToForm(BuildContext context, Product? product) {
    final bloc = context.read<ProductBloc>();
    Navigator.of(context).push(PageRouteBuilder<void>(
      pageBuilder: (_, a, __) => BlocProvider.value(
        value: bloc,
        child: ProductFormView(existingProduct: product),
      ),
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
        child: child,
      ),
      transitionDuration: SellerTheme.pageTransitionDuration,
    ));
  }
}

// ─── Product Card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: SellerTheme.errorRed,
          borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => _konfirmasiHapus(context),
      onDismissed: (_) {
        context.read<ProductBloc>().add(
              HapusProduk(
                  productId: product.id, sellerId: product.sellerId),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} dihapus'),
            backgroundColor: SellerTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
          onTap: () => _navigateToForm(context, product),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Ikon kategori
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: SellerTheme.primaryGreen.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(SellerTheme.borderRadiusSmall),
                  ),
                  child: Icon(
                    _categoryIcon(product.category),
                    color: SellerTheme.primaryGreen,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: SellerTheme.subHeadingStyle
                              .copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${_formatHarga(product.price)}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: SellerTheme.primaryGreen,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StokBadge(product: product),
                          const SizedBox(width: 6),
                          _SyncBadge(product: product),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: Color(0xFF9E9E9E), size: 20),
                  onPressed: () => _navigateToForm(context, product),
                  tooltip: 'Edit produk',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _konfirmasiHapus(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Produk?'),
          content: Text(
              'Produk "${product.name}" akan dihapus secara permanen dari katalog.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal')),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                  foregroundColor: SellerTheme.errorRed),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );

  void _navigateToForm(BuildContext context, Product product) {
    final bloc = context.read<ProductBloc>();
    Navigator.of(context).push(PageRouteBuilder<void>(
      pageBuilder: (_, a, __) => BlocProvider.value(
        value: bloc,
        child: ProductFormView(existingProduct: product),
      ),
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
        child: child,
      ),
      transitionDuration: SellerTheme.pageTransitionDuration,
    ));
  }

  static IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.fastfood_rounded;
      case 'minuman':
        return Icons.local_drink_rounded;
      case 'sembako':
        return Icons.shopping_basket_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  static String _formatHarga(double harga) {
    final s = harga.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StokBadge extends StatelessWidget {
  final Product product;
  const _StokBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    if (!product.isAvailable || product.quantity == 0) {
      color = SellerTheme.errorRed;
      label = 'Habis';
    } else if (product.quantity < 5) {
      color = SellerTheme.syncPending;
      label = 'Stok: ${product.quantity}';
    } else {
      color = SellerTheme.primaryGreen;
      label = 'Stok: ${product.quantity}';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final Product product;
  const _SyncBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.isSynced) return const SizedBox.shrink();
    final color = product.isLocalOnly
        ? SellerTheme.syncPending
        : const Color(0xFF9E9E9E);
    final label = product.isLocalOnly ? 'Lokal' : 'Belum Sinkron';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SellerTheme.animationDuration,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? SellerTheme.primaryGreen
                : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF757575),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.inventory_2_outlined : Icons.search_off_rounded,
            size: 64,
            color: const Color(0xFFBDBDBD),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'Belum ada produk di katalog'
                : 'Produk "$query" tidak ditemukan',
            style: SellerTheme.subHeadingStyle
                .copyWith(color: const Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 56, color: SellerTheme.errorRed),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
