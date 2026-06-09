import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/product_model.dart';
import '../../app/routes/app_router.dart';
import '../../core/di/app_dependencies.dart';
import '../../domain/entities/seller.dart';
import '../../domain/entities/location.dart' as loc;

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  ProductModel? _product;
  Seller? _seller;
  bool _isLoading = true;
  bool _isLoaded = false;
  String? _error;
  loc.Location? _userLocation;
  double? _distanceKm;
  final _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      _isLoaded = true;
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? productId;

    if (args is Map) {
      productId = args['productId'] as String?;
    } else if (args is String) {
      productId = args;
    }

    if (productId == null || productId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'ID produk tidak valid.';
        });
      }
      return;
    }

    try {
      final product = await AppDependencies.productRepository.getProductById(productId);
      if (!mounted) return;

      if (product != null) {
        _product = ProductModel.fromEntity(product);
        _loadSeller(product.sellerId);
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Produk tidak ditemukan.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat data produk: $e';
      });
    }
  }

  Future<void> _loadSeller(String sellerId) async {
    try {
      final seller = await AppDependencies.sellerRepository.getSellerById(sellerId);
      if (!mounted) return;

      _seller = seller;

      if (seller?.location != null) {
        await _loadUserLocation(seller!.location!);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserLocation(loc.Location sellerLocation) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      _userLocation = loc.Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _distanceKm = _userLocation!.distanceTo(sellerLocation);
    } catch (_) {
      // GPS tidak tersedia
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDistance(double km) {
    if (km.isInfinite) return 'Lokasi belum tersedia';
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Detail Produk', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Detail Produk', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _loadProduct();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final product = _product!;
    final storeName = _seller?.shopName ?? 'Toko';
    final distanceText = _distanceKm != null
        ? _formatDistance(_distanceKm!)
        : 'Lokasi toko';

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
          Stack(
            children: [
              SizedBox(
                height: 250,
                child: product.images != null && product.images!.isNotEmpty
                    ? PageView(
                        controller: _pageController,
                        onPageChanged: (i) {
                          setState(() => _currentImageIndex = i);
                        },
                        children: product.images!.map((url) {
                          return Container(
                            color: theme.colorScheme.outlineVariant,
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image, size: 100, color: Colors.white54),
                              ),
                              loadingBuilder: (_, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.green,
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      )
                    : Container(
                        color: theme.colorScheme.outlineVariant,
                        child: const Center(
                          child: Icon(Icons.image, size: 100, color: Colors.white54),
                        ),
                      ),
              ),
              if (product.images != null && product.images!.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(product.images!.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == i ? 10 : 6,
                        height: _currentImageIndex == i ? 10 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == i
                              ? Colors.green
                              : Colors.white.withValues(alpha: 0.6),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),

                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

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
                              storeName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text(
                                  distanceText,
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
                
                const Text('Ulasan Pembeli', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.grey, radius: 16, child: Icon(Icons.person, color: Colors.white, size: 16)),
                    SizedBox(width: 8),
                    Text('Hanifidin I.'),
                    SizedBox(width: 8),
                    Row(children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      Icon(Icons.star, size: 14, color: Colors.amber),
                    ]),
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
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cart, arguments: product);
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
