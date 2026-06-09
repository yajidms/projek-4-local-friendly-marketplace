// File: lib/app/presentation/features/seller/views/invoice_view.dart
//
// Halaman invoice full-screen untuk detail transaksi penjual.
// Menampilkan: header status, timeline pengiriman, info pembeli,
// info pengiriman (Shipment), daftar item, ringkasan harga, tombol aksi status.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../theme/seller_theme.dart';
import '../../../../../domain/entities/index.dart';
import '../bloc/transaction_bloc.dart';

class InvoiceView extends StatelessWidget {
  final Order order;
  const InvoiceView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SellerTheme.sellerThemeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: CustomScrollView(
          slivers: [
            _InvoiceHeader(order: order),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TimelineSection(order: order),
                  const SizedBox(height: 12),
                  _InfoPembeliCard(order: order),
                  const SizedBox(height: 12),
                  if (order.shipment != null) ...[
                    _ShipmentCard(shipment: order.shipment!),
                    const SizedBox(height: 12),
                  ],
                  _ItemListCard(order: order),
                  const SizedBox(height: 12),
                  _RingkasanHargaCard(order: order),
                  const SizedBox(height: 12),
                  _AksiStatusCard(order: order),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _InvoiceHeader extends StatelessWidget {
  final Order order;
  const _InvoiceHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    final topPad = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox(width: 48, height: 48,
                child: Center(child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20))),
            ),
            const Spacer(),
            Icon(Icons.receipt_long_rounded, color: Colors.white.withValues(alpha: 0.7), size: 28),
          ]),
          const SizedBox(height: 8),
          Text('Invoice Pesanan',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          const SizedBox(height: 4),
          Text('#${order.id.toUpperCase()}',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.circle, size: 8, color: Colors.white),
              const SizedBox(width: 6),
              Text(_statusLabel(order.status),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 12),
          Text(
            'Dipesan: ${DateFormat('EEEE, dd MMMM yyyy · HH:mm', 'id').format(order.createdAt)}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ]),
      ),
    );
  }

  static Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return SellerTheme.syncPending;
      case OrderStatus.confirmed: return const Color(0xFF1565C0);
      case OrderStatus.processing: return const Color(0xFF6A1B9A);
      case OrderStatus.shipped: return const Color(0xFF00838F);
      case OrderStatus.delivered: return SellerTheme.primaryGreen;
      default: return SellerTheme.errorRed;
    }
  }

  static String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return 'Menunggu Konfirmasi';
      case OrderStatus.confirmed: return 'Dikonfirmasi';
      case OrderStatus.processing: return 'Sedang Diproses';
      case OrderStatus.shipped: return 'Sedang Dikirim';
      case OrderStatus.delivered: return 'Selesai';
      case OrderStatus.cancelled: return 'Dibatalkan';
      case OrderStatus.refunded: return 'Dikembalikan';
    }
  }
}

// ── Timeline ──────────────────────────────────────────────────────────────────
class _TimelineSection extends StatelessWidget {
  final Order order;
  const _TimelineSection({required this.order});

  static const _steps = [
    (OrderStatus.pending, 'Menunggu', Icons.pending_actions_rounded),
    (OrderStatus.confirmed, 'Dikonfirmasi', Icons.check_circle_outline_rounded),
    (OrderStatus.processing, 'Diproses', Icons.settings_rounded),
    (OrderStatus.shipped, 'Dikirim', Icons.local_shipping_rounded),
    (OrderStatus.delivered, 'Selesai', Icons.done_all_rounded),
  ];

  static int _statusIndex(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return 0;
      case OrderStatus.confirmed: return 1;
      case OrderStatus.processing: return 2;
      case OrderStatus.shipped: return 3;
      case OrderStatus.delivered: return 4;
      default: return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statusIndex(order.status);
    final isCancelled = order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.timeline_rounded, size: 18, color: SellerTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Alur Pesanan', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
          ]),
          const SizedBox(height: 14),
          if (isCancelled)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SellerTheme.errorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SellerTheme.errorRed.withValues(alpha: 0.3)),
              ),
              child: const Row(children: [
                Icon(Icons.cancel_rounded, color: SellerTheme.errorRed, size: 20),
                SizedBox(width: 8),
                Text('Pesanan ini dibatalkan / dikembalikan',
                    style: TextStyle(color: SellerTheme.errorRed, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            )
          else
            Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  // connector line
                  final stepIndex = i ~/ 2;
                  final isActive = stepIndex < currentIndex;
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? SellerTheme.primaryGreen : const Color(0xFFE0E0E0),
                    ),
                  );
                }
                final stepIndex = i ~/ 2;
                final (_, label, icon) = _steps[stepIndex];
                final isDone = stepIndex <= currentIndex;
                final isCurrentStep = stepIndex == currentIndex;
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    duration: SellerTheme.animationDuration,
                    width: isCurrentStep ? 38 : 32,
                    height: isCurrentStep ? 38 : 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? SellerTheme.primaryGreen : const Color(0xFFE0E0E0),
                      boxShadow: isCurrentStep ? [
                        BoxShadow(color: SellerTheme.primaryGreen.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1),
                      ] : null,
                    ),
                    child: Icon(icon, size: isCurrentStep ? 20 : 16,
                        color: isDone ? Colors.white : const Color(0xFFBDBDBD)),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 56,
                    child: Text(label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isCurrentStep ? FontWeight.w700 : FontWeight.normal,
                          color: isDone ? SellerTheme.primaryGreen : const Color(0xFFBDBDBD),
                        )),
                  ),
                ]);
              }),
            ),
        ]),
      ),
    );
  }
}

// ── Info Pembeli ──────────────────────────────────────────────────────────────
class _InfoPembeliCard extends StatelessWidget {
  final Order order;
  const _InfoPembeliCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.person_rounded, size: 18, color: SellerTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Info Pembeli', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _InfoRow2(icon: Icons.badge_rounded, label: 'ID Pembeli', value: order.userId),
          if (order.notes != null && order.notes!.isNotEmpty)
            _InfoRow2(icon: Icons.note_rounded, label: 'Catatan', value: order.notes!),
          _InfoRow2(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal Order',
            value: DateFormat('dd MMM yyyy, HH:mm', 'id').format(order.createdAt),
            isLast: true,
          ),
        ]),
      ),
    );
  }
}

// ── Shipment Card ─────────────────────────────────────────────────────────────
class _ShipmentCard extends StatelessWidget {
  final Shipment shipment;
  const _ShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.local_shipping_rounded, size: 18, color: Color(0xFF00838F)),
            const SizedBox(width: 8),
            Text('Info Pengiriman', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _InfoRow2(icon: Icons.directions_boat_rounded, label: 'Metode', value: _methodLabel(shipment.method)),
          if (shipment.trackingNumber != null)
            _InfoRow2(icon: Icons.pin_rounded, label: 'No. Resi', value: shipment.trackingNumber!),
          if (shipment.carrier != null)
            _InfoRow2(icon: Icons.business_rounded, label: 'Kurir', value: shipment.carrier!),
          _InfoRow2(
            icon: Icons.event_rounded,
            label: 'Est. Tiba',
            value: DateFormat('dd MMM yyyy', 'id').format(shipment.estimatedDeliveryDate),
          ),
          if (shipment.shippingAddress != null)
            _InfoRow2(
              icon: Icons.location_on_rounded,
              label: 'Alamat',
              value: shipment.shippingAddress!,
              isLast: true,
            ),
        ]),
      ),
    );
  }

  static String _methodLabel(ShippingMethod m) {
    switch (m) {
      case ShippingMethod.standard: return 'Reguler';
      case ShippingMethod.express: return 'Express';
      case ShippingMethod.overnight: return 'Same Day';
    }
  }
}

// ── Item List ─────────────────────────────────────────────────────────────────
class _ItemListCard extends StatelessWidget {
  final Order order;
  const _ItemListCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.shopping_cart_rounded, size: 18, color: SellerTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Produk Dipesan', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
            const Spacer(),
            Text('${order.itemCount} item',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: SellerTheme.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_rounded, size: 20, color: SellerTheme.primaryGreen),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.product.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${item.quantity}× Rp ${_fmt(item.unitPrice)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
              ])),
              Text('Rp ${_fmt(item.subtotal)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          )),
        ]),
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

// ── Ringkasan Harga ───────────────────────────────────────────────────────────
class _RingkasanHargaCard extends StatelessWidget {
  final Order order;
  const _RingkasanHargaCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.receipt_rounded, size: 18, color: SellerTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Ringkasan Harga', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _PriceRow2(label: 'Subtotal', value: order.subtotal),
          const SizedBox(height: 6),
          _PriceRow2(label: 'Ongkos Kirim', value: order.shippingCost),
          if (order.tax > 0) ...[
            const SizedBox(height: 6),
            _PriceRow2(label: 'Pajak', value: order.tax),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(children: [
            const Text('Total Pembayaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
            const Spacer(),
            Text('Rp ${_fmt(order.total)}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: SellerTheme.primaryGreen)),
          ]),
        ]),
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

class _PriceRow2 extends StatelessWidget {
  final String label;
  final double value;
  const _PriceRow2({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final s = value.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF757575))),
      const Spacer(),
      Text('Rp $buf', style: const TextStyle(fontSize: 13, color: Color(0xFF424242))),
    ]);
  }
}

// ── Aksi Status ───────────────────────────────────────────────────────────────
class _AksiStatusCard extends StatelessWidget {
  final Order order;
  const _AksiStatusCard({required this.order});

  static List<OrderStatus> _allowedNext(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.confirmed: return [OrderStatus.processing, OrderStatus.cancelled];
      case OrderStatus.processing: return [OrderStatus.shipped];
      case OrderStatus.shipped: return [OrderStatus.delivered];
      default: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextStatuses = _allowedNext(order.status);
    if (nextStatuses.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.swap_horiz_rounded, size: 18, color: SellerTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Ubah Status Pesanan', style: SellerTheme.subHeadingStyle.copyWith(fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          ...nextStatuses.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _StatusBtn(order: order, targetStatus: s),
          )),
        ]),
      ),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final Order order;
  final OrderStatus targetStatus;
  const _StatusBtn({required this.order, required this.targetStatus});

  @override
  Widget build(BuildContext context) {
    final color = _color(targetStatus);
    final label = _label(targetStatus);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<TransactionBloc>().add(PerbaruiStatusTransaksi(
            orderId: order.id,
            sellerId: order.sellerId ?? '',
            status: targetStatus,
          ));
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SellerTheme.borderRadius)),
        ),
        icon: Icon(_icon(targetStatus), size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  static Color _color(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return const Color(0xFF1565C0);
      case OrderStatus.processing: return const Color(0xFF6A1B9A);
      case OrderStatus.shipped: return const Color(0xFF00838F);
      case OrderStatus.delivered: return SellerTheme.primaryGreen;
      case OrderStatus.cancelled: return SellerTheme.errorRed;
      default: return const Color(0xFF757575);
    }
  }

  static String _label(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return 'Konfirmasi Pesanan';
      case OrderStatus.processing: return 'Tandai Sedang Diproses';
      case OrderStatus.shipped: return 'Tandai Telah Dikirim';
      case OrderStatus.delivered: return 'Tandai Pesanan Selesai';
      case OrderStatus.cancelled: return 'Batalkan Pesanan';
      default: return s.value;
    }
  }

  static IconData _icon(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return Icons.check_rounded;
      case OrderStatus.processing: return Icons.settings_rounded;
      case OrderStatus.shipped: return Icons.local_shipping_rounded;
      case OrderStatus.delivered: return Icons.done_all_rounded;
      case OrderStatus.cancelled: return Icons.close_rounded;
      default: return Icons.swap_horiz_rounded;
    }
  }
}

// ── Reusable InfoRow ──────────────────────────────────────────────────────────
class _InfoRow2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow2({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121)))),
      ]),
    );
  }
}
