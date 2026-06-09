import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../core/di/app_dependencies.dart';
import '../../data/datasources/local/in_memory_auth_local_datasource.dart';
import '../../domain/entities/order.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final auth = await InMemoryAuthLocalDataSource().getAuthSession();
      if (auth != null) {
        final orders = await AppDependencies.orderRepository.getOrdersByUserId(auth.user.id);
        if (mounted) setState(() { _orders = orders; _isLoading = false; });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Menunggu Verifikasi';
      case 'confirmed': return 'Dikonfirmasi';
      case 'processing': return 'Diproses';
      case 'shipped': return 'Dikirim';
      case 'delivered': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text('Riwayat Transaksi', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text('Belum ada riwayat transaksi', style: TextStyle(color: theme.hintColor)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final itemsLabel = order.items.map((i) => '${i.product.name} x${i.quantity}').join(', ');
                final statusColor = _getStatusColor(order.status.value);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                _statusLabel(order.status.value),
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.updatedAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Divider(height: 20),

                        Text(
                          itemsLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.storefront, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              order.sellerId ?? 'Toko',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${order.itemCount} Satuan',
                              style: TextStyle(color: theme.hintColor, fontSize: 13),
                            ),
                            Text(
                              _formatPrice(order.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
                            ),
                          ],
                        ),

                        if (order.status == OrderStatus.pending || order.status == OrderStatus.delivered) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (order.status == OrderStatus.pending)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Simulasi upload bukti pembayaran...')),
                                    );
                                  },
                                  icon: const Icon(Icons.cloud_upload, size: 16),
                                  label: const Text('Upload Bukti Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              if (order.status == OrderStatus.delivered) ...[
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Simulasi menuju halaman ulasan produk...')),
                                    );
                                  },
                                  child: const Text('Beri Ulasan', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Produk berhasil ditambahkan kembali ke keranjang belanja!')),
                                    );
                                  },
                                  child: const Text('Beli Lagi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2), // Sesuaikan index navbar untuk Riwayat
    );
  }
}