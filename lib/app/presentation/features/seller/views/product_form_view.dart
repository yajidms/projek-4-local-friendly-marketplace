// File: lib/app/presentation/features/seller/views/product_form_view.dart
//
// Form tambah & edit produk.
// Mode tambah  : existingProduct == null
// Mode edit    : existingProduct != null (fields diisi dengan data lama)
// Validasi : nama & harga wajib diisi.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/seller_theme.dart';
import '../../../../../core/auth/auth_bootstrap.dart';
import '../../../../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';

/// Daftar kategori yang tersedia untuk produk.
const _kKategori = [
  'Sembako',
  'Makanan',
  'Minuman',
  'Kebersihan',
  'Kesehatan',
  'Lainnya',
];

const _kSatuan = [
  'pcs', 'kg', 'gram', 'liter', 'ml',
  'lusin', 'pak', 'dus',
  'karung', 'botol', 'bungkus', 'renceng', 'sachet', 'ikat', 'lembar',
];

class ProductFormView extends StatefulWidget {
  /// Null berarti mode TAMBAH, non-null berarti mode EDIT.
  final Product? existingProduct;

  const ProductFormView({super.key, this.existingProduct});

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaCtrl;
  late final TextEditingController _deskripsiCtrl;
  late final TextEditingController _spesifikasiCtrl;
  late final TextEditingController _hargaCtrl;
  late final TextEditingController _stokCtrl;
  late final TextEditingController _beratCtrl;
  late final TextEditingController _skuCtrl;

  late String _kategori;
  late String _satuan;
  late bool _tersedia;

  bool _isSaving = false;
  bool get _isEdit => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _namaCtrl = TextEditingController(text: p?.name ?? '');
    _deskripsiCtrl = TextEditingController(text: p?.description ?? '');
    _spesifikasiCtrl = TextEditingController(text: p?.specifications ?? '');
    _hargaCtrl =
        TextEditingController(text: p != null ? p.price.toInt().toString() : '');
    _stokCtrl = TextEditingController(
        text: p != null ? p.quantity.toString() : '');
    _beratCtrl = TextEditingController(
        text: p?.weight != null ? p!.weight!.toString() : '');
    _skuCtrl = TextEditingController(text: p?.sku ?? '');
    final savedCategory = p?.category ?? _kKategori.first;
    _kategori = _kKategori.contains(savedCategory) ? savedCategory : _kKategori.first;

    final savedUnit = p?.unit ?? _kSatuan.first;
    _satuan = _kSatuan.contains(savedUnit) ? savedUnit : _kSatuan.first;

    _tersedia = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _spesifikasiCtrl.dispose();
    _hargaCtrl.dispose();
    _stokCtrl.dispose();
    _beratCtrl.dispose();
    _skuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SellerTheme.sellerThemeData,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: Column(
          children: [
            _FormHeader(isEdit: _isEdit),
            Expanded(
              child: BlocListener<ProductBloc, ProductState>(
                listener: (ctx, state) {
                  if (state is ProductTertampil && _isSaving) {
                    setState(() => _isSaving = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(_isEdit
                          ? 'Produk berhasil diperbarui!'
                          : 'Produk berhasil ditambahkan!'),
                      backgroundColor: SellerTheme.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                    ));
                    Navigator.of(ctx).pop();
                  }
                  if (state is ProductGagal && _isSaving) {
                    setState(() => _isSaving = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(state.pesan),
                      backgroundColor: SellerTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(SellerTheme.paddingPage),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _FormCard(children: [
                          _FieldLabel('Nama Produk *'),
                          _buildTextField(
                            controller: _namaCtrl,
                            hint: 'Contoh: Beras Premium 5kg',
                            keyId: 'nama_produk',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nama produk wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Deskripsi Produk'),
                          _buildTextField(
                            controller: _deskripsiCtrl,
                            hint: 'Jelaskan produk Anda...',
                            keyId: 'deskripsi',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('Spesifikasi / Bahan'),
                          _buildTextField(
                            controller: _spesifikasiCtrl,
                            hint: 'Contoh: Tepung terigu, gula, garam...\natau:\nBahan: 100% beras organik\nBerat bersih: 5 kg',
                            keyId: 'spesifikasi',
                            maxLines: 4,
                          ),
                        ]),
                        const SizedBox(height: 14),

                        _FormCard(children: [
                          _FieldLabel('Kategori *'),
                          DropdownButtonFormField<String>(
                            initialValue: _kategori,
                            decoration: const InputDecoration(
                                hintText: 'Pilih kategori'),
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF212121)),
                            items: _kKategori
                                .map((k) => DropdownMenuItem(
                                    value: k,
                                    child: Text(k,
                                        style: const TextStyle(fontSize: 14))))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _kategori = v ?? _kategori),
                          ),
                        ]),
                        const SizedBox(height: 14),

                        _FormCard(children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Harga Jual (Rp) *'),
                                    _buildTextField(
                                      controller: _hargaCtrl,
                                      hint: '0',
                                      keyId: 'harga',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Harga wajib diisi';
                                        }
                                        if (int.tryParse(v) == null ||
                                            int.parse(v) <= 0) {
                                          return 'Harga harus lebih dari 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Stok'),
                                    _buildTextField(
                                      controller: _stokCtrl,
                                      hint: '0',
                                      keyId: 'stok',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Satuan'),
                                    DropdownButtonFormField<String>(
                                      initialValue: _satuan,
                                      decoration: const InputDecoration(
                                          hintText: 'Satuan'),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF212121)),
                                      items: _kSatuan
                                          .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s,
                                                  style: const TextStyle(
                                                      fontSize: 14))))
                                          .toList(),
                                      onChanged: (v) => setState(
                                          () => _satuan = v ?? _satuan),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel('Berat (gram)'),
                                    _buildTextField(
                                      controller: _beratCtrl,
                                      hint: '0',
                                      keyId: 'berat',
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel('SKU / Kode Produk'),
                          _buildTextField(
                            controller: _skuCtrl,
                            hint: 'Contoh: BERAS-001',
                            keyId: 'sku',
                          ),
                        ]),
                        const SizedBox(height: 14),

                        // Toggle ketersediaan
                        _FormCard(children: [
                          Row(
                            children: [
                              const Icon(Icons.storefront_rounded,
                                  color: Color(0xFF757575), size: 20),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text('Produk Tersedia di Toko',
                                    style: SellerTheme.labelStyle),
                              ),
                              Switch(
                                value: _tersedia,
                                activeThumbColor: SellerTheme.primaryGreen,
                                onChanged: (v) =>
                                    setState(() => _tersedia = v),
                              ),
                            ],
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Tombol Simpan
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            key: const Key('btn_simpan_produk'),
                            onPressed: _isSaving ? null : _onSimpan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SellerTheme.primaryGreen,
                              disabledBackgroundColor:
                                  const Color(0xFFBDBDBD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    SellerTheme.borderRadius),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: SellerTheme.animationDuration,
                              child: _isSaving
                                  ? const SizedBox(
                                      key: ValueKey('loading'),
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                  : Row(
                                      key: const ValueKey('label'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(_isEdit
                                            ? Icons.save_rounded
                                            : Icons.add_rounded),
                                        const SizedBox(width: 8),
                                        Text(_isEdit
                                            ? 'Simpan Perubahan'
                                            : 'Tambah Produk'),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final existing = widget.existingProduct;
    final authFacade = AuthBootstrap.build();
    final auth = await authFacade.getCurrentSession(useRemote: true);
    final sellerId = existing?.sellerId ?? auth?.user.sellerId ?? '';

    final product = Product(
      id: existing?.id ?? '',
      sellerId: sellerId,
      name: _namaCtrl.text.trim(),
      description: _deskripsiCtrl.text.trim(),
      specifications: _spesifikasiCtrl.text.trim().isNotEmpty
          ? _spesifikasiCtrl.text.trim()
          : null,
      price: double.parse(_hargaCtrl.text.trim()),
      quantity: int.tryParse(_stokCtrl.text.trim()) ?? 0,
      category: _kategori,
      unit: _satuan,
      weight: _beratCtrl.text.trim().isNotEmpty
          ? double.tryParse(_beratCtrl.text.trim())
          : null,
      sku: _skuCtrl.text.trim().isNotEmpty ? _skuCtrl.text.trim() : null,
      isAvailable: _tersedia,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      isSynced: false,
      isLocalOnly: existing == null,
    );

    if (_isEdit) {
      if (context.mounted) {
        context.read<ProductBloc>().add(PerbaruiProduk(product: product));
      }
    } else {
      if (context.mounted) {
        context.read<ProductBloc>().add(TambahProduk(product: product));
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String keyId,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      key: Key(keyId),
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(hintText: hint),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final bool isEdit;
  const _FormHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 28),
      decoration: const BoxDecoration(
        gradient: SellerTheme.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SellerTheme.neonGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEdit ? Icons.edit_rounded : Icons.add_box_rounded,
                  color: SellerTheme.neonGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Produk' : 'Tambah Produk',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEdit
                        ? 'Perbarui informasi produk Anda'
                        : 'Isi data produk yang ingin Anda jual',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: SellerTheme.labelStyle
                .copyWith(fontWeight: FontWeight.w600)),
      );
}
