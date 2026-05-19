// File: lib/app/presentation/features/seller/views/product_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../theme/seller_theme.dart';
import '../../../../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import 'product_form_view.dart';

class ProductDetailView extends StatelessWidget {
  final Product product;
  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SellerTheme.sellerThemeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: CustomScrollView(
          slivers: [
            _ProdukHeader(product: product),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _InfoDasarCard(product: product),
                  const SizedBox(height: 12),
                  if (product.description.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Deskripsi Produk',
                      icon: Icons.description_rounded,
                      child: Text(product.description,
                          style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF424242))),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (product.specifications != null && product.specifications!.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Spesifikasi / Bahan',
                      icon: Icons.science_rounded,
                      child: Text(product.specifications!,
                          style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF424242))),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _UlasanSection(),
                  const SizedBox(height: 88),
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: _EditFab(product: product),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _ProdukHeader extends StatelessWidget {
  final Product product;
  const _ProdukHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [SellerTheme.primaryGreenDark, SellerTheme.primaryGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(width: 48, height: 48,
              child: Center(child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20))),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(product.category,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Text(product.name,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Rp ${_fmt(product.price)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(children: [
            _StokChip(product: product),
            if (product.sku != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('SKU: ${product.sku}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
        ]),
      ),
    );
  }

  static String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StokChip extends StatelessWidget {
  final Product product;
  const _StokChip({required this.product});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    if (product.quantity == 0) { label = 'Stok Habis'; bg = Colors.red.withValues(alpha: 0.35); }
    else if (!product.isAvailable) { label = 'Tidak Tersedia'; bg = Colors.grey.withValues(alpha: 0.35); }
    else if (product.quantity < 5) { label = 'Stok Rendah: ${product.quantity}'; bg = Colors.orange.withValues(alpha: 0.35); }
    else { label = 'Stok: ${product.quantity}'; bg = Colors.white.withValues(alpha: 0.25); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Info Dasar ────────────────────────────────────────────────────────────────
class _InfoDasarCard extends StatelessWidget {
  final Product product;
  const _InfoDasarCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: SellerTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Informasi Produk', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _Row(icon: Icons.attach_money_rounded, label: 'Harga Jual', value: 'Rp ${_fmt(product.price)}'),
          _Row(icon: Icons.inventory_2_rounded, label: 'Stok', value: '${product.quantity} ${product.unit ?? 'pcs'}'),
          _Row(icon: Icons.category_rounded, label: 'Kategori', value: product.category),
          if (product.weight != null)
            _Row(icon: Icons.scale_rounded, label: 'Berat', value: '${product.weight!.toStringAsFixed(0)} gram'),
          if (product.sku != null)
            _Row(icon: Icons.qr_code_rounded, label: 'SKU', value: product.sku!),
          _Row(icon: Icons.access_time_rounded, label: 'Ditambahkan', value: _fmtDate(product.createdAt)),
          _Row(icon: Icons.update_rounded, label: 'Diperbarui', value: _fmtDate(product.updatedAt), isLast: true),
        ]),
      ),
    );
  }

  static String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String _fmtDate(DateTime dt) => DateFormat('dd MMM yyyy', 'id').format(dt);
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _Row({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 10),
        SizedBox(width: 110, child: Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121)))),
      ]),
    );
  }
}

// ── Generic Section Card ───────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: SellerTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(title, style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

// ── Ulasan Placeholder ─────────────────────────────────────────────────────────
class _UlasanSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF57F17)),
            const SizedBox(width: 8),
            Text('Ulasan Pembeli', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF57F17).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('—', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF57F17))),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Center(child: Column(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF57F17).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rate_review_outlined, size: 28, color: Color(0xFFF57F17)),
            ),
            const SizedBox(height: 12),
            Text('Belum Ada Ulasan',
                style: SellerTheme.subHeadingStyle.copyWith(color: const Color(0xFF9E9E9E), fontSize: 14)),
            const SizedBox(height: 4),
            Text('Ulasan dari pembeli akan tampil di sini setelah produk terjual.',
                style: const TextStyle(fontSize: 12, color: Color(0xFFBDBDBD)),
                textAlign: TextAlign.center),
          ])),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ── Edit FAB ───────────────────────────────────────────────────────────────────
class _EditFab extends StatelessWidget {
  final Product product;
  const _EditFab({required this.product});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        final bloc = context.read<ProductBloc>();
        Navigator.of(context).push(PageRouteBuilder<void>(
          pageBuilder: (_, a, __) => BlocProvider.value(
            value: bloc,
            child: ProductFormView(existingProduct: product),
          ),
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
            child: child,
          ),
          transitionDuration: SellerTheme.pageTransitionDuration,
        ));
      },
      backgroundColor: SellerTheme.primaryGreen,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.edit_rounded),
      label: const Text('Edit Produk', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
