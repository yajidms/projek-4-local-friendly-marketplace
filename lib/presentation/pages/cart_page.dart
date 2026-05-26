import 'package:flutter/material.dart';
import '../../app/routes/app_router.dart';
import 'package:pade_localfriendly_marketplace/data/models/product_model.dart'; // 🛠️ Import Model Asli

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 🛠️ FIX: Menangkap produk dari halaman Product Detail
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args is ProductModel) {
        // Jika ada produk yang masuk, kita jadikan isi keranjang utama
        _currentStoreId = args.sellerId;
        _currentStoreName = args.storeName; // Menggunakan getter dari extension router
        _cartItems = [
          {
            'id': args.id,
            'name': args.name,
            'price': args.price,
            'quantity': 1, 
            'category': args.category,
          }
        ];
      } else {
        // Jika keranjang dibuka dari AppBar katalog tanpa klik beli, 
        // kita tetap memunculkan data dummy lama agar halaman tidak kosong
        _currentStoreId = 'seller_1';
        _currentStoreName = 'Toko Sembako Pak Budi';
        _cartItems = [
          {
            'id': '1', 'name': 'Beras Premium 5kg', 'price': 75000,
            'quantity': 1, 'category': 'Sembako',
          },
          {
            'id': '2', 'name': 'Minyak Goreng 2L', 'price': 32000,
            'quantity': 2, 'category': 'Sembako',
          },
        ];
      }
      _isInit = true;
    }
  }

  // Hitung Ringkasan Keranjang (FR-027)
  int get _totalItems => _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  double get _totalPrice => _cartItems.fold(0.0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as int)));

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
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
                          // Gambar dummy produk
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
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
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      if (item['quantity'] > 1) {
                                        item['quantity']--;
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
                            // Mengarah langsung ke halaman checkout yang sudah kita buat sebelumnya
                            Navigator.pushNamed(context, AppRoutes.checkout);
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