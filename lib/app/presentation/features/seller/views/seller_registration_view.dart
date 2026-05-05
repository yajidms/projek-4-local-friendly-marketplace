// File: lib/app/presentation/features/seller/views/seller_registration_view.dart
//
// SRS Ch 3.5.2 — Registrasi Toko
// NFR-OPR-01: Semua elemen interaktif ≥ 48×48 dp.
// NFR-ATR-03: Transisi halaman ≤ 300ms (slide-up).
// NFR-UND-02: Semua copy dalam Bahasa Indonesia, termasuk "Tersimpan di HP".

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/seller_theme.dart';
import '../bloc/seller_registration_bloc.dart';
import '../widgets/image_picker_box.dart';

/// Pilihan Jenis Usaha untuk dropdown.
const _jenisUsahaList = [
  'Warung / Kios',
  'Pedagang Kaki Lima',
  'UMKM Rumahan',
  'Toko Kelontong',
  'Restoran / Warung Makan',
  'Lainnya',
];

class SellerRegistrationView extends StatelessWidget {
  const SellerRegistrationView({super.key});

  /// NFR-ATR-03: Transisi slide-up ≤ 300ms.
  static Route<void> route() => PageRouteBuilder<void>(
        pageBuilder: (_, a, __) =>
            BlocProvider.value(
              value: BlocProvider.of<SellerRegistrationBloc>(
                  _routeContext!, listen: false),
              child: const SellerRegistrationView(),
            ),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: a, curve: SellerTheme.animationCurve)),
          child: child,
        ),
        transitionDuration: SellerTheme.pageTransitionDuration,
      );

  // Simpan context sementara untuk route (dipanggil dari luar)
  static BuildContext? _routeContext;

  @override
  Widget build(BuildContext context) {
    _routeContext = context;
    return Theme(
      data: SellerTheme.sellerThemeData,
      child: const _RegistrationBody(),
    );
  }
}

// ─── Halaman Utama ────────────────────────────────────────────────────────────

class _RegistrationBody extends StatelessWidget {
  const _RegistrationBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerRegistrationBloc, SellerRegistrationState>(
      listener: (ctx, state) {
        if (state.status == StatusRegistrasi.berhasil) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('Toko berhasil didaftarkan!'),
            backgroundColor: SellerTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ));
          Navigator.of(ctx).pop(); // Kembali / navigasi ke Dashboard
        }
        if (state.status == StatusRegistrasi.gagal &&
            state.pesanError != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.pesanError!),
            backgroundColor: SellerTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (ctx, state) => Scaffold(
        backgroundColor: const Color(0xFFF4F6F4),
        body: Column(
          children: [
            _GreenHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SellerTheme.paddingPage),
                child: _FormContent(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header Hijau "Info Toko" ─────────────────────────────────────────────────

class _GreenHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SellerTheme.primaryGreenDark,
            SellerTheme.primaryGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NFR-OPR-01: Tombol kembali ≥ 48×48 dp via SizedBox + InkWell
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Info Toko',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lengkapi informasi toko Anda untuk mulai berjualan di PaDe',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Konten Form ──────────────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  final SellerRegistrationState state;
  const _FormContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // 1. Nama Toko
        _Label('Nama Toko'),
        _PadeField(
          key: const Key('field_nama_toko'),
          hint: 'Contoh: Warung Bu Sari',
          onChanged: (v) => context
              .read<SellerRegistrationBloc>()
              .add(NamaTokoBerubah(v)),
        ),
        const SizedBox(height: 18),

        // 2. Kategori Produk yang Dijual
        _Label('Kategori Produk yang Dijual'),
        _PadeField(
          key: const Key('field_kategori'),
          hint: 'Contoh: Makanan, Minuman, Sembako',
          onChanged: (v) => context
              .read<SellerRegistrationBloc>()
              .add(KategoriProdukBerubah(v)),
        ),
        const SizedBox(height: 18),

        // 3. Jenis Usaha (Dropdown)
        _Label('Jenis Usaha'),
        DropdownButtonFormField<String>(
          initialValue: state.jenisUsaha,
          decoration:
              const InputDecoration(hintText: 'Pilih jenis usaha'),
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF212121)), // min 14sp
          items: _jenisUsahaList
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o,
                      style:
                          const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) => context
              .read<SellerRegistrationBloc>()
              .add(JenisUsahaBerubah(v)),
        ),
        const SizedBox(height: 18),

        // 4. Alamat Lengkap (multiline)
        _Label('Alamat Lengkap Toko'),
        _PadeField(
          key: const Key('field_alamat'),
          hint:
              'Jalan, RT/RW, Kelurahan, Kecamatan, Kota/Kabupaten',
          maxLines: 4,
          onChanged: (v) => context
              .read<SellerRegistrationBloc>()
              .add(AlamatBerubah(v)),
        ),
        const SizedBox(height: 24),

        // 5. Unggah Tanda Pengenal
        ImagePickerBox(
          imagePath: state.pathGambarTandaPengenal,
          onTap: () async {
            final picker = ImagePicker();
            final file = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 90,
            );
            if (file != null && context.mounted) {
              context.read<SellerRegistrationBloc>().add(
                    GambarTandaPengenalanDipilih(file.path),
                  );
            }
          },
        ),
        const SizedBox(height: 8),

        // NFR-UND-02: "Tersimpan di HP" bukan "Saved locally"
        Row(children: const [
          Icon(Icons.phone_android_rounded,
              size: 13, color: Color(0xFF9E9E9E)),
          SizedBox(width: 4),
          Text('Tersimpan di HP Anda',
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF9E9E9E))),
        ]),
        const SizedBox(height: 36),

        // Tombol Lanjut — rata kanan
        Align(
          alignment: Alignment.centerRight,
          child: _LanjutButton(state: state),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Reusable Sub-Widgets ─────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            // NFR-UND-02: min font size 14sp
            style: SellerTheme.labelStyle
                .copyWith(fontWeight: FontWeight.w600)),
      );
}

class _PadeField extends StatelessWidget {
  final String hint;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _PadeField({
    super.key,
    required this.hint,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14), // min 14sp
        decoration: InputDecoration(hintText: hint),
        onChanged: onChanged,
      );
}

class _LanjutButton extends StatelessWidget {
  final SellerRegistrationState state;
  const _LanjutButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final loading = state.status == StatusRegistrasi.memuat;
    return SizedBox(
      // NFR-OPR-01: min 48dp height
      height: 50,
      width: 150,
      child: ElevatedButton(
        key: const Key('btn_lanjut'),
        onPressed: loading || !state.isFormValid
            ? null
            : () => context
                .read<SellerRegistrationBloc>()
                .add(DaftarkanToko()),
        style: ElevatedButton.styleFrom(
          backgroundColor: SellerTheme.primaryGreen,
          disabledBackgroundColor: const Color(0xFFBDBDBD),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SellerTheme.borderRadius),
          ),
        ),
        child: AnimatedSwitcher(
          duration: SellerTheme.animationDuration,
          child: loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : const Row(
                  key: ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lanjut',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
