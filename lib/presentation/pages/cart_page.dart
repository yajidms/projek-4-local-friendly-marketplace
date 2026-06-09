import 'package:flutter/material.dart';
import '../../app/routes/app_router.dart';
import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../core/di/app_dependencies.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/seller.dart';

/// Per-user cart storage keyed by userId.
final Map<String, _UserCartData> _carts = {};

class _UserCartData {
  String storeId = '';
  String storeName = '';
  List<Map<String, dynamic>> items = [];
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _currentStoreId = '';
  String _currentStoreName = '';
  List<Map<String, dynamic>> _cartItems = [];
  bool _isInit = false;
  String? _userId;
  Seller? _seller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInit) {
      _loadAuthAndCart();
      _isInit = true;
    }
  }

  Future<void> _loadAuthAndCart() async {
    final auth = await AuthBootstrap.build().getCurrentSession(
      useRemote: Env.hasConfiguredBackendUrl && !Env.usesMongoConnectionString,
    );
    if (!mounted) return;

    final userId = auth?.user.id ?? 'guest';
    final args = ModalRoute.of(context)?.settings.arguments;

    _userId = userId;
    final cart = _carts.putIfAbsent(userId, () => _UserCartData());

    if (args is ProductModel) {
      cart.storeId = args.sellerId;
      cart.items = [
        {
          'id': args.id,
          'name': args.name,
          'price': args.price,
          'quantity': 1,
          'category': args.category,
          'images': args.images,
        }
      ];
      _loadSeller(args.sellerId);
    }

    setState(() {
      _currentStoreId = cart.storeId;
      _currentStoreName = cart.storeName;
      _cartItems = cart.items;
    });
  }

  Future<void> _loadSeller(String sellerId) async {
    try {
      final seller = await AppDependencies.sellerRepository.getSellerById(sellerId);
      if (!mounted) return;
      setState(() {
        _seller = seller;
        _currentStoreName = seller?.shopName ?? 'Toko';
        if (_userId != null) {
          final cart = _carts[_userId!];
          if (cart != null) {
            cart.storeName = _currentStoreName;
          }
        }
      });
    } catch (_) {
      // fallback ke 'Toko'
    }
  }

  // Hitung Ringkasan Keranjang (FR-027)
  int get _totalItems => _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  double get _totalPrice => _cartItems.fold(0.0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as int)));

  Widget _buildItemImage(dynamic images) {
    if (images is List && images.isNotEmpty && images.first is String) {
      return Image.network(
        images.first as String,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
      );
    }
    return const Icon(Icons.image, color: Colors.grey);
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  void _persistCart() {
    if (_userId != null) {
      final cart = _carts[_userId!]!;
      cart.storeId = _currentStoreId;
      cart.storeName = _currentStoreName;
      cart.items = _cartItems;
    }
  }

  // Simulasi Validasi Aturan Bisnis FR-026 (Satu Toko yang Sama)
  void _simulateAddFromDifferentStore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Gagal Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Sesuai aturan FR-026, keranjang Anda sudah berisi produk dari "$_currentStoreName".\n\nAnda tidak bisa menambahkan produk dari toko lain sebelum menyelesaikan atau mengosongkan keranjang saat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Paham', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Keranjang Belanja', style: TextStyle(color: Colors.white)),
        actions: [
          // Tombol khusus buat pamer Validasi SRS pas demo/sidang
          TextButton.icon(
            onPressed: _simulateAddFromDifferentStore,
            icon: const Icon(Icons.bug_report, color: Colors.white, size: 16),
            label: const Text('Test FR-026', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text('Keranjang belanjamu kosong', style: TextStyle(color: theme.hintColor)),
                ],
              ),
            )
          : Column(
              children: [
                // Header Toko (Menandakan pelacakan satu toko - FR-026)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.green.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentStoreName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Text(
                              'Produk dikirim dari toko yang sama',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Daftar Item di Keranjang (FR-027)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gambar produk
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: _buildItemImage(item['images']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Detail informasi produk
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  item['category'],
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(item['price'].toDouble()),
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          // Kontrol kuantitas item
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(item['quantity'] == 1 ? Icons.delete_outline : Icons.remove, size: 20, color: item['quantity'] == 1 ? Colors.red : null),
                                  onPressed: () {
                                    setState(() {
                                      if (item['quantity'] > 1) {
                                        item['quantity']--;
                                        _persistCart();
                                      } else {
                                        _cartItems.removeAt(index);
                                        _persistCart();
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      item['quantity']++;
                                      _persistCart();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Ringkasan Harga & Tombol Checkout (FR-027)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Barang ($_totalItems Satuan)', style: const TextStyle(color: Colors.grey)),
                          Text(_formatPrice(_totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.checkout, arguments: {
                              'items': _cartItems,
                              'storeName': _currentStoreName,
                            });
                          },
                          child: const Text(
                            'Lanjut ke Checkout',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}