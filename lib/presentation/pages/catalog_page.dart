import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../app/models/product_model.dart';
import '../../app/routes/app_router.dart';
import '../widgets/bottom_nav_bar.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  double? _userLat;
  double? _userLng;
  bool _isLoading = true;
  String _selectedCategory = '';
  
  bool _isInit = false; // Flag agar inisialisasi hanya berjalan sekali

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    // Hapus _init() dari sini, kita pindahkan logika ambil argumen ke didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies adalah tempat yang aman untuk mengambil context / argumen route
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        // Jangan panggil setState langsung, cukup set nilai awal controller
        _searchController.text = args['query'] ?? '';
        _selectedCategory = args['category'] ?? '';
      }
      
      // Setelah dapat argumen, ambil lokasi dan produk
      _getUserLocation().then((_) => _loadProducts());
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ambil lokasi user
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _userLat = -6.8319;
        _userLng = 107.5436;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _userLat = -6.8319;
        _userLng = 107.5436;
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _userLat = position.latitude;
      _userLng = position.longitude;
    } catch (_) {
      _userLat = -6.8319;
      _userLng = 107.5436;
    }
  }

  void _loadProducts() {
    final box = Hive.box('products');
    final products = box.values.map((e) {
      final product = ProductModel.fromMap(Map.from(e));
      if (_userLat != null && _userLng != null) {
        product.distanceKm = _calculateDistance(
          _userLat!, _userLng!,
          product.storeLat, product.storeLng,
        );
      }
      return product;
    }).toList();

    final filtered = _selectedCategory.isEmpty
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    filtered.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

    setState(() {
      _allProducts = filtered;
      _filteredProducts = filtered;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.storeName.toLowerCase().contains(query);
      }).toList();
      
      _filteredProducts.sort((a, b) =>
          (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  String _formatDistance(double? km) {
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // LOGIKA PENGAMBILAN ARGUMEN DIHAPUS DARI SINI
    // karena sudah ditangani dengan aman di method didChangeDependencies()

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text('Katalog', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: theme.hintColor),
                  hintText: 'Cari produk, kategori, atau toko...',
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ), // <-- PERBAIKAN: Kurung tutup Container di sini
            
            // Chips diletakkan sebagai widget terpisah di dalam list children milik Column
            if (_selectedCategory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Chip(
                      label: Text(_selectedCategory),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = '';
                          _loadProducts();
                        });
                      },
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      labelStyle: const TextStyle(color: Colors.green, fontSize: 12),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),

            // Info jumlah hasil
            if (!_isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredProducts.length} produk ditemukan',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
              ),
            const SizedBox(height: 8),

            // Grid produk
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        )
                      : GridView.builder(
                          itemCount: _filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return InkWell(
                              onTap: () => Navigator.pushNamed(
                                context, AppRoutes.product,
                                arguments: product,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Gambar produk
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.outlineVariant,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.image, color: Colors.white54),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatPrice(product.price),
                                      style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    // Nama toko + jarak
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 10, color: Colors.grey),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            '${product.storeName} · ${_formatDistance(product.distanceKm)}',
                                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}