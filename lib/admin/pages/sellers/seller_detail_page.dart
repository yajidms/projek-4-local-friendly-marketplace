import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/seller.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class SellerDetailPage extends StatelessWidget {
  const SellerDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final ds = AdminMockDatasource();
    final Seller seller = ds.sellers.firstWhere((Seller s) => s.id == id);
    final List<Product> products = ds.products.where((Product p) => p.sellerId == id).toList();

    return AdminScaffold(
      currentRoute: AdminRoutes.sellers,
      title: seller.shopName,
      subtitle: seller.shopAddress ?? '',
      headerActions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.sellers),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Kembali'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(width: 200, child: StatCard(icon: Icons.inventory_2_rounded, label: 'Total Produk', value: '${seller.totalProducts}', color: AdminTheme.info)),
                SizedBox(width: 200, child: StatCard(icon: Icons.star_rounded, label: 'Rating', value: seller.ratingString, color: AdminTheme.accent)),
                SizedBox(width: 200, child: StatCard(icon: Icons.reviews_rounded, label: 'Ulasan', value: '${seller.totalReviews}', color: AdminTheme.primaryLight)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AdminTheme.bgCard, borderRadius: BorderRadius.circular(AdminTheme.radiusMd), border: Border.all(color: AdminTheme.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Toko', style: TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        _info('Nama', seller.shopName),
                        _info('Deskripsi', seller.shopDescription ?? '-'),
                        _info('Alamat', seller.shopAddress ?? '-'),
                        _info('Telepon', seller.shopPhone ?? '-'),
                        _info('Kategori', seller.categories.join(', ')),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            seller.isVerified ? StatusBadge.verified() : StatusBadge.pending(),
                            const SizedBox(width: 8),
                            seller.isActive ? StatusBadge.active() : StatusBadge.inactive(),
                            const SizedBox(width: 8),
                            seller.isOnline ? StatusBadge.online() : StatusBadge.offline(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AdminTheme.bgCard, borderRadius: BorderRadius.circular(AdminTheme.radiusMd), border: Border.all(color: AdminTheme.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Produk (${products.length})', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        if (products.isEmpty)
                          const Text('Belum ada produk.', style: TextStyle(color: AdminTheme.textMuted))
                        else
                          ...products.take(10).map((Product p) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AdminTheme.bgSurface, borderRadius: BorderRadius.circular(AdminTheme.radiusSm), border: Border.all(color: AdminTheme.border)),
                            child: Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(p.name, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                                  Text(p.category, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                                ])),
                                Text('Rp ${p.price.toStringAsFixed(0)}', style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(width: 12),
                                StatusBadge(label: 'Stok: ${p.quantity}', color: p.quantity > 0 ? AdminTheme.success : AdminTheme.danger),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14))),
      ]),
    );
  }
}
