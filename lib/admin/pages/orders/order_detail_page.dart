import 'package:flutter/material.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/entities/payment_method.dart';
import '../../../domain/entities/shipment.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.id});
  final String id;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final AdminRepository _repo;
  Order? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = AdminProvider.read(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final order = await _repo.getOrderDetail(widget.id);
      if (mounted) setState(() { _order = order; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return AdminTheme.warning;
      case OrderStatus.confirmed: return AdminTheme.info;
      case OrderStatus.processing: return AdminTheme.accent;
      case OrderStatus.shipped: return AdminTheme.primaryLight;
      case OrderStatus.delivered: return AdminTheme.success;
      case OrderStatus.cancelled: return AdminTheme.danger;
      case OrderStatus.refunded: return AdminTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.orders,
      title: 'Detail Pesanan',
      subtitle: _order != null ? 'ID: ${_order!.id}' : '',
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AdminTheme.primaryLight))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, color: AdminTheme.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
                ]))
              : SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.orders),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Kembali ke daftar'),
          ),
          const SizedBox(height: 20),

          // Order Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminTheme.bgCard,
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: AdminTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.receipt_long_rounded, color: AdminTheme.primaryLight, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order #${_order!.id.length > 12 ? _order!.id.substring(0, 12) : _order!.id}', style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('${_order!.createdAt.day}/${_order!.createdAt.month}/${_order!.createdAt.year} • ${_order!.items.length} item', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(_order!.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_order!.status.name.toUpperCase(), style: TextStyle(color: _statusColor(_order!.status), fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Items
            Expanded(flex: 3, child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Item Pesanan', style: TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AdminTheme.border),
                ..._order!.items.map((item) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text(item.product.name, style: const TextStyle(color: AdminTheme.textPrimary))),
                    SizedBox(width: 60, child: Text('×${item.quantity}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
                    SizedBox(width: 120, child: Text(_formatCurrency(item.subtotal), textAlign: TextAlign.end, style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w500))),
                  ]),
                )),
                const SizedBox(height: 12),
                _summaryRow('Subtotal', _formatCurrency(_order!.subtotal)),
                _summaryRow('Pajak', _formatCurrency(_order!.tax)),
                _summaryRow('Ongkir', _formatCurrency(_order!.shippingCost)),
                const Divider(height: 16, color: AdminTheme.border),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(_formatCurrency(_order!.total), style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w700, fontSize: 16)),
                ]),
              ]),
            )),
            const SizedBox(width: 16),

            // Payment & Shipping Info
            Expanded(flex: 2, child: Column(children: [
              _infoCard('Pembayaran', [
                _infoRow('Metode', _order!.payment?.method.value ?? '-'),
                _infoRow('Status', _order!.payment?.status.value ?? '-'),
                _infoRow('Jumlah', _order!.payment != null ? _formatCurrency(_order!.payment!.amount) : '-'),
              ]),
              const SizedBox(height: 16),
              _infoCard('Pengiriman', [
                _infoRow('Status', _order!.shipment?.status.value ?? '-'),
                _infoRow('Kurir', _order!.shipment?.carrier ?? '-'),
                _infoRow('No. Resi', _order!.shipment?.trackingNumber ?? '-'),
              ]),
            ])),
          ]),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
      Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13)),
    ]),
  );

  Widget _infoCard(String title, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AdminTheme.bgCard,
      borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
      border: Border.all(color: AdminTheme.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      const Divider(height: 1, color: AdminTheme.border),
      const SizedBox(height: 12),
      ...rows,
    ]),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
      Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13))),
    ]),
  );
}
