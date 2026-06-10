import 'package:flutter/material.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late final AdminRepository _repo;
  List<Order> _allOrders = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _repo = AdminProvider.read(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await _repo.getAllOrders();
      if (mounted) setState(() { _allOrders = orders; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Order> get _filteredOrders {
    if (_statusFilter == 'all') return _allOrders;
    return _allOrders.where((o) => o.status.name == _statusFilter).toList();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    return 'Rp ${amount.toStringAsFixed(0)}';
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
    final orders = _filteredOrders;

    return AdminScaffold(
      currentRoute: AdminRoutes.orders,
      title: 'Pesanan',
      subtitle: 'Semua pesanan di marketplace',
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
              : Padding(
        padding: const EdgeInsets.all(28),
        child: Column(children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip('Semua (${_allOrders.length})', 'all'),
              const SizedBox(width: 8),
              _chip('Pending', 'pending'),
              const SizedBox(width: 8),
              _chip('Confirmed', 'confirmed'),
              const SizedBox(width: 8),
              _chip('Processing', 'processing'),
              const SizedBox(width: 8),
              _chip('Shipped', 'shipped'),
              const SizedBox(width: 8),
              _chip('Delivered', 'delivered'),
              const SizedBox(width: 8),
              _chip('Cancelled', 'cancelled'),
            ]),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AdminTheme.bgCard,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                border: Border.all(color: AdminTheme.border),
              ),
              child: orders.isEmpty
                  ? const Center(child: Text('Tidak ada data.', style: TextStyle(color: AdminTheme.textMuted)))
                  : ListView(children: [
                      _header(),
                      const Divider(height: 1, color: AdminTheme.border),
                      ...orders.map(_row),
                    ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _statusFilter == value;
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(color: selected ? AdminTheme.primaryLight : AdminTheme.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    color: AdminTheme.bgSurface,
    child: const Row(children: [
      Expanded(flex: 2, child: Text('Order ID', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Items', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 2, child: Text('Total', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      Expanded(flex: 1, child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
      SizedBox(width: 60),
    ]),
  );

  Widget _row(Order order) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => Navigator.of(context).pushNamed(AdminRoutes.orderDetail, arguments: order.id),
      hoverColor: AdminTheme.bgHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
        child: Row(children: [
          Expanded(flex: 2, child: Text(order.id.length > 12 ? '${order.id.substring(0, 12)}...' : order.id, style: const TextStyle(color: AdminTheme.textPrimary, fontFamily: 'monospace', fontSize: 13))),
          Expanded(flex: 1, child: Text('${order.items.length} item', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
          Expanded(flex: 2, child: Text(_formatCurrency(order.total), style: const TextStyle(color: AdminTheme.primaryLight, fontWeight: FontWeight.w500, fontSize: 14))),
          Expanded(flex: 2, child: Text('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _statusColor(order.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(order.status.name.toUpperCase(), style: TextStyle(color: _statusColor(order.status), fontSize: 11, fontWeight: FontWeight.w600)),
          )),
          SizedBox(width: 60, child: IconButton(icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: AdminTheme.textSecondary), onPressed: () => Navigator.of(context).pushNamed(AdminRoutes.orderDetail, arguments: order.id))),
        ]),
      ),
    ),
  );
}
