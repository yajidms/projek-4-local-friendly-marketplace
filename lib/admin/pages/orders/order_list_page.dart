import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../../domain/entities/order.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final _ds = AdminMockDatasource();
  String _statusFilter = 'all';

  List<Order> get _filtered {
    List<Order> list = _ds.orders.toList();
    if (_statusFilter != 'all') {
      list = list.where((Order o) => o.status.name == _statusFilter).toList();
    }
    return list;
  }

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
    final orders = _filtered;

    return AdminScaffold(
      currentRoute: AdminRoutes.orders,
      title: 'Manajemen Pesanan',
      subtitle: '${_ds.orders.length} pesanan total',
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('Semua', 'all'),
                  const SizedBox(width: 8),
                  ...OrderStatus.values.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip(s.name[0].toUpperCase() + s.name.substring(1), s.name),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: ListView(
                  children: [
                    _header(),
                    const Divider(height: 1, color: AdminTheme.border),
                    ...orders.map(_row),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final sel = _statusFilter == value;
    return FilterChip(
      selected: sel, label: Text(label),
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(color: sel ? AdminTheme.primaryLight : AdminTheme.textSecondary, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(color: AdminTheme.bgSurface, borderRadius: BorderRadius.only(topLeft: Radius.circular(AdminTheme.radiusMd), topRight: Radius.circular(AdminTheme.radiusMd))),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Order ID', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Items', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Total', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
          SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _row(Order o) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AdminRoutes.orderDetail, arguments: o.id),
        hoverColor: AdminTheme.bgHover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(o.id, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 13))),
              Expanded(flex: 2, child: Text('${o.itemCount} item', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
              Expanded(flex: 2, child: Text('Rp ${o.total.toStringAsFixed(0)}', style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w600, fontSize: 14))),
              Expanded(flex: 1, child: StatusBadge(label: o.status.name, color: _statusColor(o.status))),
              Expanded(flex: 2, child: Text('${o.createdAt.day}/${o.createdAt.month}/${o.createdAt.year}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13))),
              SizedBox(width: 60, child: IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: AdminTheme.textMuted, size: 18), onPressed: () => Navigator.of(context).pushNamed(AdminRoutes.orderDetail, arguments: o.id))),
            ],
          ),
        ),
      ),
    );
  }
}
