// File: lib/app/presentation/features/seller/views/inventory_view.dart
//
// Halaman Inventaris — manajemen stok produk secara cepat.
// Fitur:
// - Tampil semua produk dengan stok saat ini
// - Stepper (+/–) langsung di kartu untuk update stok
// - Badge peringatan stok rendah / habis
// - Tombol "Simpan Semua Perubahan" untuk batch update

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/seller_theme.dart';
import '../../../../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  /// Map produkId → stok sementara (perubahan belum disimpan)
  final Map<String, int> _draftStock = {};
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (ctx, state) {
        if (state is ProductTertampil && _isSaving) {
          setState(() {
            _isSaving = false;
            _draftStock.clear();
          });
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('Stok berhasil diperbarui!'),
            backgroundColor: SellerTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is ProductMemuat) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductGagal) {
          return Center(
            child: Text(state.pesan,
                style: const TextStyle(color: SellerTheme.errorRed)),
          );
        }
        if (state is ProductTertampil) {
          return _buildInventory(context, state.products);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildInventory(BuildContext context, List<Product> products) {
    // Stok Habis  : qty == 0
    // Stok Rendah : qty > 0 && qty < 5 (threshold)
    // Tersedia    : qty >= 5
    final lowStockCount = products.where((p) => p.quantity > 0 && p.quantity < 5).length;
    final outOfStockCount = products.where((p) => p.quantity == 0).length;
    final hasChanges = _draftStock.isNotEmpty;

    return Column(
      children: [
        // ── Summary Banner ────────────────────────────────────────────────
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SummaryChip(
                  icon: Icons.inventory_2_rounded,
                  label: '${products.length} Produk',
                  color: SellerTheme.primaryGreen,
                ),
                const SizedBox(width: 10),
                if (lowStockCount > 0)
                  _SummaryChip(
                    icon: Icons.warning_amber_rounded,
                    label: '$lowStockCount Stok Rendah',
                    color: SellerTheme.syncPending,
                  ),
                if (lowStockCount > 0) const SizedBox(width: 10),
                if (outOfStockCount > 0)
                  _SummaryChip(
                    icon: Icons.remove_shopping_cart_rounded,
                    label: '$outOfStockCount Stok Habis',
                    color: SellerTheme.errorRed,
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),

        // ── List Inventaris ───────────────────────────────────────────────
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text('Belum ada produk'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final product = products[i];
                    final currentStock =
                        _draftStock[product.id] ?? product.quantity;
                    final isChanged = _draftStock.containsKey(product.id) &&
                        _draftStock[product.id] != product.quantity;
                    return _InventoryCard(
                      key: ValueKey(product.id), // ← penting: cegah state reuse
                      product: product,
                      currentStock: currentStock,
                      isChanged: isChanged,
                      onDecrement: () {
                        if (currentStock > 0) {
                          setState(() {
                            _draftStock[product.id] = currentStock - 1;
                          });
                        }
                      },
                      onIncrement: () {
                        setState(() {
                          _draftStock[product.id] = currentStock + 1;
                        });
                      },
                      onDirectEdit: (newVal) {
                        setState(() {
                          _draftStock[product.id] = newVal;
                        });
                      },
                    );
                  },
                ),
        ),

        // ── Tombol Simpan (muncul jika ada perubahan) ─────────────────────
        AnimatedContainer(
          duration: SellerTheme.animationDuration,
          height: hasChanges ? 80 : 0,
          child: hasChanges
              ? Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _simpanSemua(context, products),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _isSaving
                            ? 'Menyimpan...'
                            : 'Simpan ${_draftStock.length} Perubahan',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SellerTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              SellerTheme.borderRadius),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _simpanSemua(BuildContext context, List<Product> products) {
    setState(() => _isSaving = true);
    // Dispatch satu per satu update stok
    for (final entry in _draftStock.entries) {
      final product = products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => products.first,
      );
      context.read<ProductBloc>().add(PerbaruiStokProduk(
            productId: entry.key,
            sellerId: product.sellerId,
            stokBaru: entry.value,
          ));
    }
  }
}

// ─── Inventory Card ────────────────────────────────────────────────────────────

class _InventoryCard extends StatefulWidget {
  final Product product;
  final int currentStock;
  final bool isChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int> onDirectEdit;

  const _InventoryCard({
    super.key, // ← diperlukan agar ValueKey dari ListView bekerja
    required this.product,
    required this.currentStock,
    required this.isChanged,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDirectEdit,
  });

  @override
  State<_InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<_InventoryCard> {
  late TextEditingController _stokCtrl;

  @override
  void initState() {
    super.initState();
    _stokCtrl =
        TextEditingController(text: widget.currentStock.toString());
  }

  @override
  void didUpdateWidget(covariant _InventoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStock != widget.currentStock) {
      final pos = _stokCtrl.selection;
      _stokCtrl.text = widget.currentStock.toString();
      if (pos.start <= _stokCtrl.text.length) {
        _stokCtrl.selection = pos;
      }
    }
  }

  @override
  void dispose() {
    _stokCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    // ── 3 + 1 state stok ─────────────────────────────────────────────────
    // 1. Stok Habis   : qty == 0             (merah)
    // 2. Stok Rendah  : 0 < qty < 5          (oranye)
    // 3. Tidak Tersedia: qty ≥ 0, !isAvail   (abu-abu)
    // 4. Tersedia     : qty ≥ 5 && isAvail   (hijau)
    Color statusColor;
    String statusLabel;
    if (widget.currentStock == 0) {
      statusColor = SellerTheme.errorRed;
      statusLabel = 'Stok Habis';
    } else if (!p.isAvailable) {
      statusColor = const Color(0xFF9E9E9E);
      statusLabel = 'Tdk Tersedia';
    } else if (widget.currentStock < 5) {
      statusColor = SellerTheme.syncPending;
      statusLabel = 'Stok Rendah';
    } else {
      statusColor = SellerTheme.primaryGreen;
      statusLabel = 'Tersedia';
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Ikon & status
            Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(SellerTheme.borderRadiusSmall),
                  ),
                  child: Icon(Icons.inventory_2_rounded,
                      color: statusColor, size: 22),
                ),
                const SizedBox(height: 4),
                Text(statusLabel,
                    style: TextStyle(
                        fontSize: 9,
                        color: statusColor,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(width: 12),

            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: SellerTheme.subHeadingStyle.copyWith(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    p.category,
                    style: SellerTheme.bodyStyle.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6)),
                  ),
                  if (widget.isChanged)
                    Text(
                      'Stok asal: ${p.quantity}',
                      style: const TextStyle(
                          fontSize: 11, color: SellerTheme.syncPending),
                    ),
                ],
              ),
            ),

            // Stepper
            _StockStepper(
              stokCtrl: _stokCtrl,
              currentStock: widget.currentStock,
              onDecrement: widget.onDecrement,
              onIncrement: widget.onIncrement,
              onDirectEdit: widget.onDirectEdit,
            ),
          ],
        ),
      ),
    );
  }
}

class _StockStepper extends StatelessWidget {
  final TextEditingController stokCtrl;
  final int currentStock;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int> onDirectEdit;

  const _StockStepper({
    required this.stokCtrl,
    required this.currentStock,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDirectEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tombol minus
        _StepBtn(
          icon: Icons.remove_rounded,
          onTap: onDecrement,
          enabled: currentStock > 0,
        ),
        // Input langsung
        SizedBox(
          width: 46,
          child: TextField(
            controller: stokCtrl,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).dividerColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: SellerTheme.primaryGreen, width: 2),
              ),
              filled: false,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed >= 0) onDirectEdit(parsed);
            },
          ),
        ),
        // Tombol plus
        _StepBtn(
          icon: Icons.add_rounded,
          onTap: onIncrement,
          enabled: true,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled
                ? SellerTheme.primaryGreen.withValues(alpha: 0.1)
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon,
              size: 18,
              color: enabled
                  ? SellerTheme.primaryGreen
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
        ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
