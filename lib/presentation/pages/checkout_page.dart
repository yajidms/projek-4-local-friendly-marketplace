import 'package:flutter/material.dart';
import '../../app/routes/app_router.dart';
import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../core/di/app_dependencies.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isSubmitting = false;

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Widget _buildItemImage(dynamic images) {
    if (images is List && images.isNotEmpty && images.first is String) {
      return Image.network(
        images.first as String,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
      );
    }
    return const Icon(Icons.image, color: Colors.grey);
  }

  Future<void> _submitOrder() async {
    setState(() => _isSubmitting = true);
    try {
      final auth = await AuthBootstrap.build().getCurrentSession(
        useRemote: Env.hasConfiguredBackendUrl && !Env.usesMongoConnectionString,
      );
      if (auth == null) throw Exception('Not logged in');

      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final items = (args?['items'] as List? ?? []).cast<Map<String, dynamic>>();
      final storeId = args?['storeId'] as String? ?? '';

      if (items.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Keranjang belanja kosong')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      final subtotal = items.fold(0.0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as int)));
      final orderItems = items.map((item) => OrderItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderId: '',
        productId: item['id'],
        productName: item['name'] ?? '',
        quantity: item['quantity'],
        unitPrice: (item['price'] as num).toDouble(),
        subtotal: (item['price']) * (item['quantity'] as int),
      )).toList();

      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: auth.user.id,
        sellerId: storeId.isNotEmpty ? storeId : null,
        items: orderItems,
        status: 'pending',
        subtotal: subtotal,
        tax: 0,
        shippingCost: 0,
        total: subtotal,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await AppDependencies.orderRepository.createOrder(order.toEntity());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.transaction,
          (route) => route.settings.name == AppRoutes.home,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final items = (args?['items'] as List? ?? []).cast<Map<String, dynamic>>();
    final storeName = args?['storeName'] as String? ?? 'Toko';
    final subtotal = items.fold(0.0, (sum, item) => sum + ((item['price'] as num) * (item['quantity'] as int)));
    final totalItems = items.fold(0, (sum, item) => sum + (item['quantity'] as int));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(storeName, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 16),

          const Text('Item Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...items.map((item) {
            final name = item['name'] as String? ?? '';
            final price = (item['price'] as num).toDouble();
            final qty = item['quantity'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80, height: 80,
                      color: Colors.grey[300],
                      child: _buildItemImage(item['images']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('$qty x ${_formatPrice(price)}', style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 16),

          const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)),
            child: const Row(
              children: [
                Icon(Icons.handshake, color: Colors.green),
                SizedBox(width: 12),
                Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 16),

          const Text('Detail Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Harga ($totalItems Item)', style: const TextStyle(color: Colors.grey)),
              Text(_formatPrice(subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Tagihan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(_formatPrice(subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _isSubmitting ? null : _submitOrder,
              child: Text(_isSubmitting ? 'Memproses...' : 'Buat Pesanan', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
