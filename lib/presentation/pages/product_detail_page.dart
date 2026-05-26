import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../app/routes/app_router.dart';
import 'package:pade_localfriendly_marketplace/data/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String _formatDistance(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final product = args['product'] as ProductModel;
    final distanceKm = args['distance'] as double?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Detail Produk', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          // Foto Produk (Memenuhi FR-025)
          Container(
            height: 250,
            color: theme.colorScheme.outlineVariant,
            child: const Center(
              child: Icon(Icons.image, size: 100, color: Colors.white54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Harga Produk (Memenuhi FR-025)
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),

                // Nama Produk (Memenuhi FR-025)
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Informasi Stok (Memenuhi FR-025 & menggunakan terminologi "Satuan" sesuai ledger)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Stok Tersedia: ${product.quantity} Satuan',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi Produk (Memenuhi FR-025)
                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description.isNotEmpty 
                      ? product.description 
                      : 'Tidak ada deskripsi untuk produk ini.',
                  style: const TextStyle(color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 24),
                
                // Info Toko & Jarak (Memenuhi FR-025: Nama toko dan jarak wajib ada)
                const Text(
                  'Informasi Penjual',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 20,
                        child: Icon(Icons.storefront, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.storeName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text(
                                  'Jarak dari lokasi Anda: ${_formatDistance(distanceKm)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Komponen Ulasan Pembeli Statis (FR-025)
                const Text('Ulasan Pembeli', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.grey, radius: 16, child: Icon(Icons.person, color: Colors.white, size: 16)),
                    const SizedBox(width: 8),
                    const Text('Hanifidin I.'),
                    const SizedBox(width: 8),
                    Row(children: List.generate(5, (index) => const Icon(Icons.star, size: 14, color: Colors.amber))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sangat puas dengan barangnya karena kondisinya sangat baik, harganya pas di kantong, dan lokasinya dekat sekali dari rumah.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulasi membuka fitur Chat dengan Seller...')),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Diubah menjadi hijau agar seragam
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // HUBUNGKAN TOMBOL: Mengarahkan langsung ke halaman Keranjang yang baru
                  Navigator.pushNamed(context, AppRoutes.cart, arguments: product,);
                },
                child: const Text('Masukkan Keranjang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            )
          ],
        ),
      ),
    );
  }
}