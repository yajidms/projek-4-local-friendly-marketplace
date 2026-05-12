// File: lib/app/presentation/features/seller/views/transaction_list_view.dart
//
// Halaman Transaksi/Penjualan — daftar pesanan masuk milik penjual.
// Fitur:
// - Filter chip per status (Semua, Menunggu, Dikonfirmasi, Diproses, Dikirim, Selesai, Batal)
// - Card per order dengan info pembeli, total, tanggal
// - Tap → bottom sheet detail pesanan + tombol ubah status

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../theme/seller_theme.dart';
import '../../../../../domain/entities/index.dart';
import '../bloc/transaction_bloc.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransaksiMemuat) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TransaksiGagal) {
          return Center(
            child: Text(state.pesan,
                style: const TextStyle(color: SellerTheme.errorRed)),
          );
        }
        if (state is TransaksiTertampil) {
          return _TransactionBody(state: state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _TransactionBody extends StatelessWidget {
  final TransaksiTertampil state;
  const _TransactionBody({required this.state});

  static const _filterItems = [
    (null, 'Semua'),
    (OrderStatus.pending, 'Menunggu'),
    (OrderStatus.confirmed, 'Dikonfirmasi'),
    (OrderStatus.processing, 'Diproses'),
    (OrderStatus.shipped, 'Dikirim'),
    (OrderStatus.delivered, 'Selesai'),
    (OrderStatus.cancelled, 'Batal'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = state.transaksiFiltrat;

    return Column(
      children: [
        // ── Summary Banner ────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Menunggu',
                  value: '${state.jumlahMenunggu}',
                  icon: Icons.pending_actions_rounded,
                  color: SellerTheme.syncPending,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'Total Pendapatan',
                  value: _formatRp(state.totalPendapatan),
                  icon: Icons.payments_rounded,
                  color: SellerTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),

        // ── Filter Chip Row ───────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filterItems.map((item) {
                final (status, label) = item;
                final isSelected = state.filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: label,
                    selected: isSelected,
                    color: status != null
                        ? _statusColor(status)
                        : SellerTheme.primaryGreen,
                    onTap: () => context.read<TransactionBloc>().add(
                          FilterTransaksiBerdasarkanStatus(status: status),
                        ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1),

        // ── List Order ─────────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(filterStatus: state.filterStatus)
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _OrderCard(
                    order: filtered[i],
                    onTap: () => _showDetail(ctx, filtered[i]),
                  ),
                ),
        ),
      ],
    );
  }

  void _showDetail(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: _OrderDetailSheet(order: order),
      ),
    );
  }

  static String _formatRp(double value) {
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    }
    final s = value.toInt().toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return SellerTheme.syncPending;
      case OrderStatus.confirmed:
        return const Color(0xFF1565C0);
      case OrderStatus.processing:
        return const Color(0xFF6A1B9A);
      case OrderStatus.shipped:
        return const Color(0xFF00838F);
      case OrderStatus.delivered:
        return SellerTheme.primaryGreen;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return SellerTheme.errorRed;
    }
  }
}

// ─── Order Card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final statusLabel = _statusLabel(order.status);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID & status badge
              Row(
                children: [
                  Text(
                    '#${order.id.toUpperCase()}',
                    style: SellerTheme.subHeadingStyle.copyWith(fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Item list summary
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${item.product.name} × ${item.quantity}',
                      style: SellerTheme.bodyStyle.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              if (order.items.length > 2)
                Text(
                  '  + ${order.items.length - 2} produk lainnya',
                  style: SellerTheme.bodyStyle
                      .copyWith(fontSize: 12, color: const Color(0xFF9E9E9E)),
                ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12, color: const Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text(
                    _formatRelativeTime(order.createdAt),
                    style: SellerTheme.bodyStyle.copyWith(fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${_formatRp(order.total)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SellerTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  static String _formatRp(double value) {
    final s = value.toInt().toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.delivered:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
      case OrderStatus.refunded:
        return 'Dikembalikan';
    }
  }

  static Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return SellerTheme.syncPending;
      case OrderStatus.confirmed:
        return const Color(0xFF1565C0);
      case OrderStatus.processing:
        return const Color(0xFF6A1B9A);
      case OrderStatus.shipped:
        return const Color(0xFF00838F);
      case OrderStatus.delivered:
        return SellerTheme.primaryGreen;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return SellerTheme.errorRed;
    }
  }
}

// ─── Order Detail Bottom Sheet ────────────────────────────────────────────────

class _OrderDetailSheet extends StatelessWidget {
  final Order order;
  const _OrderDetailSheet({required this.order});

  // Transisi status yang diperbolehkan untuk penjual
  static List<OrderStatus> _allowedNextStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.pending:
        return [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.confirmed:
        return [OrderStatus.processing, OrderStatus.cancelled];
      case OrderStatus.processing:
        return [OrderStatus.shipped];
      case OrderStatus.shipped:
        return [OrderStatus.delivered];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextStatuses = _allowedNextStatus(order.status);
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.85),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFBDBDBD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Detail Pesanan',
                  style: SellerTheme.subHeadingStyle,
                ),
                const Spacer(),
                Text(
                  '#${order.id.toUpperCase()}',
                  style: SellerTheme.bodyStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info tanggal
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal',
                    value: _formatDate(order.createdAt),
                  ),
                  const SizedBox(height: 10),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.note_rounded,
                      label: 'Catatan',
                      value: order.notes!,
                    ),
                  const SizedBox(height: 16),

                  // Daftar produk
                  Text('Produk yang Dipesan',
                      style: SellerTheme.subHeadingStyle
                          .copyWith(fontSize: 14)),
                  const SizedBox(height: 10),
                  ...order.items.map((item) => _OrderItemRow(item: item)),
                  const Divider(height: 24),

                  // Ringkasan harga
                  _PriceRow(label: 'Subtotal', value: order.subtotal),
                  const SizedBox(height: 6),
                  _PriceRow(
                      label: 'Ongkos Kirim', value: order.shippingCost),
                  if (order.tax > 0) ...[
                    const SizedBox(height: 6),
                    _PriceRow(label: 'Pajak', value: order.tax),
                  ],
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121))),
                      const Spacer(),
                      Text(
                        _formatRp(order.total),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: SellerTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tombol ubah status
                  if (nextStatuses.isNotEmpty) ...[
                    Text('Ubah Status Pesanan',
                        style: SellerTheme.subHeadingStyle
                            .copyWith(fontSize: 14)),
                    const SizedBox(height: 10),
                    ...nextStatuses.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _StatusButton(
                            order: order,
                            targetStatus: s,
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return DateFormat('EEEE, dd MMMM yyyy · HH:mm', 'id').format(dt);
  }

  static String _formatRp(double value) {
    final s = value.toInt().toString();
    final buf = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatusButton extends StatelessWidget {
  final Order order;
  final OrderStatus targetStatus;

  const _StatusButton({required this.order, required this.targetStatus});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(targetStatus);
    final label = _statusLabel(targetStatus);

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: () {
          context.read<TransactionBloc>().add(
                PerbaruiStatusTransaksi(
                  orderId: order.id,
                  sellerId: order.sellerId ?? 'mock-seller-001',
                  status: targetStatus,
                ),
              );
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Status diubah menjadi "$label"'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
          ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
          ),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  static String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Konfirmasi Pesanan';
      case OrderStatus.processing:
        return 'Tandai Sedang Diproses';
      case OrderStatus.shipped:
        return 'Tandai Telah Dikirim';
      case OrderStatus.delivered:
        return 'Tandai Pesanan Selesai';
      case OrderStatus.cancelled:
        return 'Batalkan Pesanan';
      default:
        return status.value;
    }
  }

  static Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return const Color(0xFF1565C0);
      case OrderStatus.processing:
        return const Color(0xFF6A1B9A);
      case OrderStatus.shipped:
        return const Color(0xFF00838F);
      case OrderStatus.delivered:
        return SellerTheme.primaryGreen;
      case OrderStatus.cancelled:
        return SellerTheme.errorRed;
      default:
        return const Color(0xFF757575);
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(label,
                    style: SellerTheme.bodyStyle.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SellerTheme.animationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF757575),
          ),
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  '${item.quantity}× Rp ${_fmt(item.unitPrice)}',
                  style: SellerTheme.bodyStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text('Rp ${_fmt(item.subtotal)}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: SellerTheme.bodyStyle
                .copyWith(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: SellerTheme.bodyStyle)),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: SellerTheme.bodyStyle),
        const Spacer(),
        Text('Rp ${_fmt(value)}', style: SellerTheme.bodyStyle),
      ],
    );
  }

  static String _fmt(double v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _EmptyState extends StatelessWidget {
  final OrderStatus? filterStatus;
  const _EmptyState({this.filterStatus});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded,
              size: 64, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 16),
          Text(
            filterStatus == null
                ? 'Belum ada transaksi'
                : 'Tidak ada transaksi dengan status ini',
            style: SellerTheme.subHeadingStyle
                .copyWith(color: const Color(0xFF9E9E9E)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
