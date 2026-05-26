import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pade_localfriendly_marketplace/data/models/product_model.dart'; // Import yg benar
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
  
  // 🛠️ FIX: Menyimpan jarak produk secara terpisah berdasarkan ID produk
  final Map<String, double> _productDistances = {}; 
  
  double? _userLat;
  double? _userLng;
  bool _isLoading = true;
  String _selectedCategory = '';
  double _selectedRadius = 3.0; 
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        _searchController.text = args['query'] ?? '';
        _selectedCategory = args['category'] ?? '';
      }
      
      _getUserLocation().then((_) => _loadProducts());
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _userLat = -6.8319; _userLng = 107.5436;
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        _userLat = -6.8319; _userLng = 107.5436;
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _userLat = position.latitude; _userLng = position.longitude;
    } catch (_) {
      _userLat = -6.8319; _userLng = 107.5436;
    }
  }

  void _loadProducts() {
    try {
      final box = Hive.box('products');
      final products = box.values.map((e) {
        final product = ProductModel.fromJson(Map<String, dynamic>.from(e));
        if (_userLat != null && _userLng != null) {
          // 🛠️ FIX: Simpan jarak ke dalam Map, bukan ke dalam modelnya!
          _productDistances[product.id] = _calculateDistance(
            _userLat!, _userLng!, product.storeLat, product.storeLng,
          );
        }
        return product;
      }).toList();

      setState(() {
        _allProducts = products;
        _isLoading = false;
        _onSearch();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e (Coba hapus & install ulang aplikasi)')),
      );
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesQuery = p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.storeName.toLowerCase().contains(query);
            
        final matchesCategory = _selectedCategory.isEmpty || p.category == _selectedCategory;
        
        final distance = _productDistances[p.id] ?? 0;
        final matchesRadius = distance <= _selectedRadius;

        return matchesQuery && matchesCategory && matchesRadius;
      }).toList();
      
      _filteredProducts.sort((a, b) => 
          (_productDistances[a.id] ?? 0).compareTo(_productDistances[b.id] ?? 0));
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
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
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text('Katalog Terdekat', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: theme.hintColor),
                  hintText: 'Cari produk, kategori...',
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.radar, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text('Radius: ${_selectedRadius.toInt()} km', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _selectedRadius,
                    min: 1, max: 10, divisions: 9,
                    activeColor: Colors.green,
                    inactiveColor: Colors.green.withValues(alpha: 0.2),
                    onChanged: (value) => setState(() { _selectedRadius = value; _onSearch(); }),
                  ),
                ),
              ],
            ),
            if (_selectedCategory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 8),
                child: Row(
                  children: [
                    Chip(
                      label: Text(_selectedCategory),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() { _selectedCategory = ''; _onSearch(); }),
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      labelStyle: const TextStyle(color: Colors.green, fontSize: 12),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ],
                ),
              ),
            if (!_isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('${_filteredProducts.length} produk ditemukan dalam radius ${_selectedRadius.toInt()} km', style: TextStyle(fontSize: 12, color: theme.hintColor)),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _filteredProducts.isEmpty
                      ? Center(child: Text('Tidak ada produk di radius ini.', style: TextStyle(color: theme.hintColor)))
                      : GridView.builder(
                          itemCount: _filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final distance = _productDistances[product.id]; // Ambil dari Map
                            
                            return InkWell(
                              onTap: () => Navigator.pushNamed(
                                context, AppRoutes.product,
                                // 🛠️ FIX: Kirim produk & jaraknya sekaligus sebagai Map!
                                arguments: {
                                  'product': product,
                                  'distance': distance,
                                },
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: Container(decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.image, color: Colors.white54)))),
                                    const SizedBox(height: 8),
                                    Text(product.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(_formatPrice(product.price), style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 10, color: Colors.grey),
                                        const SizedBox(width: 2),
                                        Expanded(child: Text('${product.storeName} · ${_formatDistance(distance)}', style: const TextStyle(fontSize: 9, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
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