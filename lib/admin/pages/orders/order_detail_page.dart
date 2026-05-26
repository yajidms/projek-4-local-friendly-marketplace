import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_item.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.id});
  final String id;

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return AdminTheme.warning;
      case OrderStatus.confirmed: return AdminTheme.info;
      case OrderStatus.processing: return AdminTheme.info;
      case OrderStatus.shipped: return AdminTheme.primaryLight;
      case OrderStatus.delivered: return AdminTheme.success;
      case OrderStatus.cancelled: return AdminTheme.danger;
      case OrderStatus.refunded: return AdminTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = AdminMockDatasource();
    final Order order = ds.orders.firstWhere((Order o) => o.id == id);
    final buyer = ds.users.where((u) => u.id == order.userId).firstOrNull;

    return AdminScaffold(
      currentRoute: AdminRoutes.orders,
      title: 'Detail Pesanan',
      subtitle: order.id,
      headerActions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.orders),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Kembali'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(children: [
                _card('Item Pesanan', Icons.shopping_bag_rounded, [
                  ...order.items.map((OrderItem item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AdminTheme.bgSurface, borderRadius: BorderRadius.circular(AdminTheme.radiusSm), border: Border.all(color: AdminTheme.border)),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.product.name, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                        Text('${item.quantity}x @ Rp ${item.unitPrice.toStringAsFixed(0)}', style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                      ])),
                      Text('Rp ${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                  )),
                  const Divider(color: AdminTheme.border),
                  _summaryRow('Subtotal', 'Rp ${order.subtotal.toStringAsFixed(0)}'),
                  _summaryRow('Pajak', 'Rp ${order.tax.toStringAsFixed(0)}'),
                  _summaryRow('Ongkir', 'Rp ${order.shippingCost.toStringAsFixed(0)}'),
                  const Divider(color: AdminTheme.border),
                  _summaryRow('Total', 'Rp ${order.total.toStringAsFixed(0)}', bold: true),
                ]),
              ]),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Column(children: [
                _card('Status', Icons.info_rounded, [
                  Center(child: StatusBadge(label: order.status.name, color: _statusColor(order.status))),
                  const SizedBox(height: 16),
                  _infoRow('Order ID', order.id),
                  _infoRow('Tanggal', '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
                  if (buyer != null) ...[
                    _infoRow('Buyer', buyer.name),
                    _infoRow('Email', buyer.email),
                  ],
                ]),
                const SizedBox(height: 20),
                if (order.payment != null)
                  _card('Pembayaran', Icons.payment_rounded, [
                    _infoRow('Metode', order.payment!.method.name),
                    _infoRow('Status', order.payment!.status.name),
                    _infoRow('Jumlah', 'Rp ${order.payment!.amount.toStringAsFixed(0)}'),
                  ]),
                const SizedBox(height: 20),
                if (order.shipment != null)
                  _card('Pengiriman', Icons.local_shipping_rounded, [
                    _infoRow('Status', order.shipment!.status.name),
                    _infoRow('No. Resi', order.shipment!.trackingNumber ?? '-'),
                    _infoRow('Kurir', order.shipment!.carrier ?? '-'),
                  ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AdminTheme.bgCard, borderRadius: BorderRadius.circular(AdminTheme.radiusMd), border: Border.all(color: AdminTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: AdminTheme.primaryLight, size: 20), const SizedBox(width: 10), Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600))]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13))),
      ]),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(color: bold ? AdminTheme.primaryLight : AdminTheme.textPrimary, fontSize: bold ? 16 : 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      ]),
    );
  }
}
