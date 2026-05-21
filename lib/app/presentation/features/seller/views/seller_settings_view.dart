// File: lib/app/presentation/features/seller/views/seller_settings_view.dart
//
// Halaman Pengaturan Toko — SRS Ch 3.5.2
// Fitur:
//   1. Info Toko (nama, deskripsi, kategori)
//   2. Foto & Banner Toko
//   3. Pengiriman & COD
//   4. Etalase Produk
//   5. Template Balasan Otomatis
//   6. Info Akun

import 'package:flutter/material.dart';
import '../../../../theme/seller_theme.dart';

class SellerSettingsView extends StatefulWidget {
  const SellerSettingsView({super.key});

  @override
  State<SellerSettingsView> createState() => _SellerSettingsViewState();
}

class _SellerSettingsViewState extends State<SellerSettingsView> {
  // ── State lokal pengaturan ────────────────────────────────────────────────
  final _namaTokoCtrl = TextEditingController(text: 'PaDe Seller');
  final _deskripsiCtrl = TextEditingController(
      text: 'Toko lokal terpercaya dengan produk segar dan berkualitas.');
  String _kategoriUtama = 'Sembako';

  bool _aktifkanJNE = true;
  bool _aktifkanSiCepat = true;
  bool _aktifkanJT = false;
  bool _aktifkanAnteraja = false;
  bool _layananCOD = true;
  bool _produkUnggulan = false;

  final _templateSambutanCtrl = TextEditingController(
      text:
          'Halo! Terima kasih sudah mampir ke toko kami 😊 Ada yang bisa kami bantu?');
  final _templateHabisCtrl = TextEditingController(
      text: 'Mohon maaf, produk ini sedang habis. Silakan cek lagi nanti ya!');
  final _templateKirimCtrl = TextEditingController(
      text: 'Pesanan Anda sudah kami kemas dan siap dikirim. Terima kasih! 🙏');

  final List<String> _etalase = ['Sembako', 'Minuman', 'Makanan Ringan'];
  final _etalaseCtrl = TextEditingController();

  @override
  void dispose() {
    _namaTokoCtrl.dispose();
    _deskripsiCtrl.dispose();
    _templateSambutanCtrl.dispose();
    _templateHabisCtrl.dispose();
    _templateKirimCtrl.dispose();
    _etalaseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SellerTheme.sellerThemeData,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          _SettingsHeader(),

          const SizedBox(height: 16),

          // ── Seksi 1: Foto Toko ─────────────────────────────────────────────
          _buildSection(
            icon: Icons.photo_camera_rounded,
            title: 'Foto & Banner Toko',
            color: SellerTheme.neonGreen,
            child: _FotoTokoSection(),
          ),

          // ── Seksi 2: Info Toko ─────────────────────────────────────────────
          _buildSection(
            icon: Icons.storefront_rounded,
            title: 'Informasi Toko',
            color: SellerTheme.tealGreen,
            child: _InfoTokoSection(
              namaCtrl: _namaTokoCtrl,
              deskripsiCtrl: _deskripsiCtrl,
              kategoriUtama: _kategoriUtama,
              onKategoriChanged: (v) => setState(() => _kategoriUtama = v!),
            ),
          ),

          // ── Seksi 3: Etalase ───────────────────────────────────────────────
          _buildSection(
            icon: Icons.view_module_rounded,
            title: 'Etalase Produk',
            color: const Color(0xFF82B1FF),
            child: _EtalaseSection(
              etalase: _etalase,
              ctrl: _etalaseCtrl,
              onAdd: () {
                final val = _etalaseCtrl.text.trim();
                if (val.isNotEmpty && !_etalase.contains(val)) {
                  setState(() {
                    _etalase.add(val);
                    _etalaseCtrl.clear();
                  });
                }
              },
              onRemove: (i) => setState(() => _etalase.removeAt(i)),
            ),
          ),

          // ── Seksi 4: Pengiriman ────────────────────────────────────────────
          _buildSection(
            icon: Icons.local_shipping_rounded,
            title: 'Pengiriman & COD',
            color: const Color(0xFFFFD740),
            child: _PengirimanSection(
              jne: _aktifkanJNE,
              siCepat: _aktifkanSiCepat,
              jt: _aktifkanJT,
              anteraja: _aktifkanAnteraja,
              cod: _layananCOD,
              produkUnggulan: _produkUnggulan,
              onJNE: (v) => setState(() => _aktifkanJNE = v),
              onSiCepat: (v) => setState(() => _aktifkanSiCepat = v),
              onJT: (v) => setState(() => _aktifkanJT = v),
              onAnteraja: (v) => setState(() => _aktifkanAnteraja = v),
              onCOD: (v) => setState(() => _layananCOD = v),
              onUnggulan: (v) => setState(() => _produkUnggulan = v),
            ),
          ),

          // ── Seksi 5: Template Balasan ──────────────────────────────────────
          _buildSection(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Template Balasan Otomatis',
            color: const Color(0xFFCE93D8),
            child: _TemplateSection(
              sambutanCtrl: _templateSambutanCtrl,
              habisCtrl: _templateHabisCtrl,
              kirimCtrl: _templateKirimCtrl,
            ),
          ),

          // ── Tombol Simpan ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _GradientButton(
              label: 'Simpan Pengaturan',
              icon: Icons.save_rounded,
              onTap: () => _simpan(context),
            ),
          ),

          // ── Seksi 6: Akun ──────────────────────────────────────────────────
          _buildSection(
            icon: Icons.manage_accounts_rounded,
            title: 'Akun Penjual',
            color: const Color(0xFFFF6E40),
            child: _AkunSection(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: SellerTheme.subHeadingStyle.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
              border: Border.all(color: SellerTheme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  void _simpan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Pengaturan toko berhasil disimpan!'),
          ],
        ),
        backgroundColor: SellerTheme.darkTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SellerTheme.borderRadius)),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: SellerTheme.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SellerTheme.neonGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_rounded,
                color: SellerTheme.neonGreen, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('Pengaturan Toko',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Kelola informasi, pengiriman & tampilan toko Anda',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Foto Toko ────────────────────────────────────────────────────────────────

class _FotoTokoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: SellerTheme.headerGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined,
                      color: Colors.white.withValues(alpha: 0.5), size: 32),
                  const SizedBox(height: 6),
                  Text('Banner Toko',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12)),
                ],
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: _PhotoPickerBtn(label: 'Ubah Banner'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Avatar
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [SellerTheme.neonGreen, SellerTheme.tealGreen],
                ),
                boxShadow: [
                  BoxShadow(
                    color: SellerTheme.neonGreen.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child:
                  const Icon(Icons.store_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Foto Profil Toko',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                _PhotoPickerBtn(label: 'Ganti Foto'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoPickerBtn extends StatelessWidget {
  final String label;
  const _PhotoPickerBtn({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur upload foto akan segera tersedia'),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: SellerTheme.neonGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: SellerTheme.neonGreen.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_rounded,
                size: 13, color: SellerTheme.darkTeal),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: SellerTheme.darkTeal,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Info Toko ────────────────────────────────────────────────────────────────

class _InfoTokoSection extends StatelessWidget {
  final TextEditingController namaCtrl;
  final TextEditingController deskripsiCtrl;
  final String kategoriUtama;
  final ValueChanged<String?> onKategoriChanged;

  const _InfoTokoSection({
    required this.namaCtrl,
    required this.deskripsiCtrl,
    required this.kategoriUtama,
    required this.onKategoriChanged,
  });

  static const _kategori = [
    'Sembako',
    'Makanan',
    'Minuman',
    'Kebersihan',
    'Kesehatan',
    'Lainnya'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsLabel('Nama Toko'),
        const SizedBox(height: 6),
        TextField(
          controller: namaCtrl,
          decoration: const InputDecoration(
            hintText: 'Nama toko Anda',
            prefixIcon: Icon(Icons.storefront_outlined, size: 18),
          ),
        ),
        const SizedBox(height: 14),
        _SettingsLabel('Deskripsi Toko'),
        const SizedBox(height: 6),
        TextField(
          controller: deskripsiCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ceritakan tentang toko Anda...',
          ),
        ),
        const SizedBox(height: 14),
        _SettingsLabel('Kategori Utama'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: kategoriUtama,
          decoration:
              const InputDecoration(hintText: 'Pilih kategori utama toko'),
          items: _kategori
              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
              .toList(),
          onChanged: onKategoriChanged,
        ),
      ],
    );
  }
}

// ─── Etalase ─────────────────────────────────────────────────────────────────

class _EtalaseSection extends StatelessWidget {
  final List<String> etalase;
  final TextEditingController ctrl;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _EtalaseSection({
    required this.etalase,
    required this.ctrl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kelola kategori/etalase produk di toko Anda.',
            style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: etalase.asMap().entries.map((e) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: SellerTheme.darkTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: SellerTheme.darkTeal.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.value,
                      style: const TextStyle(
                          fontSize: 13, color: SellerTheme.darkTeal)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => onRemove(e.key),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: SellerTheme.darkTeal),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  hintText: 'Nama etalase baru...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: SellerTheme.neonGradient,
                  borderRadius:
                      BorderRadius.circular(SellerTheme.borderRadiusSmall),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Pengiriman ───────────────────────────────────────────────────────────────

class _PengirimanSection extends StatelessWidget {
  final bool jne, siCepat, jt, anteraja, cod, produkUnggulan;
  final ValueChanged<bool> onJNE, onSiCepat, onJT, onAnteraja, onCOD,
      onUnggulan;

  const _PengirimanSection({
    required this.jne,
    required this.siCepat,
    required this.jt,
    required this.anteraja,
    required this.cod,
    required this.produkUnggulan,
    required this.onJNE,
    required this.onSiCepat,
    required this.onJT,
    required this.onAnteraja,
    required this.onCOD,
    required this.onUnggulan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsLabel('Kurir yang Tersedia'),
        const SizedBox(height: 8),
        _SwitchRow(label: 'JNE Reguler', icon: Icons.local_shipping_rounded, value: jne, onChanged: onJNE, color: const Color(0xFFD32F2F)),
        _SwitchRow(label: 'SiCepat', icon: Icons.speed_rounded, value: siCepat, onChanged: onSiCepat, color: const Color(0xFFE65100)),
        _SwitchRow(label: 'J&T Express', icon: Icons.delivery_dining_rounded, value: jt, onChanged: onJT, color: const Color(0xFF1565C0)),
        _SwitchRow(label: 'Anteraja', icon: Icons.airport_shuttle_rounded, value: anteraja, onChanged: onAnteraja, color: const Color(0xFF6A1B9A)),
        const Divider(height: 20),
        _SettingsLabel('Layanan Khusus'),
        const SizedBox(height: 8),
        _SwitchRow(
          label: 'Bayar di Tempat (COD)',
          icon: Icons.payments_rounded,
          value: cod,
          onChanged: onCOD,
          color: SellerTheme.tealGreen,
          subtitle: 'Pembeli bayar saat barang tiba',
        ),
        _SwitchRow(
          label: 'Aktifkan Produk Unggulan',
          icon: Icons.stars_rounded,
          value: produkUnggulan,
          onChanged: onUnggulan,
          color: const Color(0xFFFFD740),
          subtitle: 'Tampilkan banner produk pilihan di toko',
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;
  final String? subtitle;

  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Template Balasan ─────────────────────────────────────────────────────────

class _TemplateSection extends StatelessWidget {
  final TextEditingController sambutanCtrl;
  final TextEditingController habisCtrl;
  final TextEditingController kirimCtrl;

  const _TemplateSection({
    required this.sambutanCtrl,
    required this.habisCtrl,
    required this.kirimCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Pesan otomatis yang dikirim ke pembeli sesuai situasi.',
            style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
        const SizedBox(height: 14),
        _TemplateField(
          icon: Icons.waving_hand_rounded,
          label: 'Pesan Sambutan',
          ctrl: sambutanCtrl,
          color: SellerTheme.neonGreen,
        ),
        const SizedBox(height: 14),
        _TemplateField(
          icon: Icons.remove_shopping_cart_rounded,
          label: 'Produk Habis',
          ctrl: habisCtrl,
          color: SellerTheme.errorRed,
        ),
        const SizedBox(height: 14),
        _TemplateField(
          icon: Icons.local_shipping_rounded,
          label: 'Konfirmasi Pengiriman',
          ctrl: kirimCtrl,
          color: SellerTheme.tealGreen,
        ),
      ],
    );
  }
}

class _TemplateField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController ctrl;
  final Color color;

  const _TemplateField({
    required this.icon,
    required this.label,
    required this.ctrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: 2,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ─── Akun ────────────────────────────────────────────────────────────────────

class _AkunSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AkunTile(
          icon: Icons.person_outline_rounded,
          label: 'ID Penjual',
          value: 'mock-seller-001',
          color: const Color(0xFF82B1FF),
        ),
        const Divider(height: 16),
        _AkunTile(
          icon: Icons.verified_outlined,
          label: 'Status Verifikasi',
          value: 'Belum Terverifikasi',
          color: SellerTheme.syncPending,
        ),
        const Divider(height: 16),
        GestureDetector(
          onTap: () => _showLogoutDialog(context),
          child: const _AkunTile(
            icon: Icons.logout_rounded,
            label: 'Keluar dari Akun',
            value: '',
            color: SellerTheme.errorRed,
            isAction: true,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SellerTheme.borderRadius)),
        title: const Text('Keluar?'),
        content: const Text(
            'Anda akan keluar dari akun penjual PaDe. Data lokal tetap tersimpan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: SellerTheme.errorRed),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _AkunTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isAction;

  const _AkunTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isAction ? color : const Color(0xFF212121))),
        ),
        if (value.isNotEmpty)
          Text(value,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        if (isAction)
          Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5)),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SettingsLabel extends StatelessWidget {
  final String text;
  const _SettingsLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242)),
      );
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: SellerTheme.neonGradient,
          borderRadius: BorderRadius.circular(SellerTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: SellerTheme.neonGreen.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
