import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../app/routes/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.catalog),
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                icon: Icon(Icons.search, color: theme.hintColor),
                                hintText: 'Cari produk...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.notifications_none_rounded, color: theme.iconTheme.color),
                    const SizedBox(width: 8),
                    Icon(Icons.chat_bubble_outline_rounded, color: theme.iconTheme.color),
                  ],
                ),
              ),

              // Green Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kategori — 2 baris
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CategoryItem(icon: Icons.location_on_outlined, label: 'Lokasi', category: '', sortByLocation: true,),
                        _CategoryItem(icon: Icons.checkroom_outlined, label: 'Fashion', category: 'Fashion'),
                        _CategoryItem(icon: Icons.storefront_outlined, label: 'Toko', category: 'Toko'),
                        _CategoryItem(icon: Icons.rice_bowl_outlined, label: 'Makanan', category: 'Makanan'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CategoryItem(icon: Icons.devices_outlined, label: 'Elektronik', category: 'Elektronik'),
                        _CategoryItem(icon: Icons.eco_outlined, label: 'Sayuran', category: 'Sayuran'),
                        _CategoryItem(icon: Icons.home_outlined, label: 'Rumah Tangga', category: 'Rumah Tangga'),
                        _CategoryItem(
                          icon: Icons.grid_view_rounded, 
                          label: 'Lainnya', 
                          category: '',
                          onTapOverride: () {
                            // Memunculkan Bottom Sheet saat ditekan
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min, // Sesuaikan tinggi dengan isi
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Kategori Lainnya',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      // Contoh isi kategori tambahan
                                      Wrap(
                                        spacing: 24, // Jarak antar item
                                        runSpacing: 16,
                                        children: [
                                          // Kamu bisa pakai _CategoryItem lagi di sini!
                                          // Pastikan saat diklik, tutup dulu bottom sheet-nya pakai Navigator.pop
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context); // Tutup popup
                                              Navigator.pushNamed(
                                                context, 
                                                AppRoutes.catalog, 
                                                arguments: {'category': 'Olahraga'}
                                              );
                                            },
                                            child: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.sports_basketball_outlined, size: 30, color: Colors.green),
                                                SizedBox(height: 4),
                                                Text('Olahraga', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context); // Tutup popup
                                              Navigator.pushNamed(
                                                context, 
                                                AppRoutes.catalog, 
                                                arguments: {'category': 'Buku'}
                                              );
                                            },
                                            child: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.menu_book_rounded, size: 30, color: Colors.green),
                                                SizedBox(height: 4),
                                                Text('Buku', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          
                                          // Tambahkan kategori lain yang kamu mau di sini...
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Baru-baru ini dibeli
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Baru-baru ini dibeli',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String category;
  final bool sortByLocation;
  final VoidCallback? onTapOverride; // ← Tambah ini

  const _CategoryItem({
    super.key, // ganti super.key kalau versinya butuh
    required this.icon,
    required this.label,
    required this.category,
    this.sortByLocation = false,
    this.onTapOverride, // ← Tambah ini
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      // 👇 Ubah bagian onTap ini
      onTap: onTapOverride ?? () => Navigator.pushNamed(
        context,
        AppRoutes.catalog,
        arguments: {
          'category': category,
          'sortByLocation': sortByLocation,
        },
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: theme.iconTheme.color),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}