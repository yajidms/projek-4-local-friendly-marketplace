import 'package:flutter/material.dart';

import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.settings,
      title: 'Pengaturan',
      subtitle: 'Konfigurasi platform PaDe',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // Marketplace info
            _section('Informasi Marketplace', Icons.business_rounded, [
              _field('Nama Platform', 'PaDe - Pasar Dekat'),
              _field('Deskripsi', 'Platform marketplace lokal untuk pasar tradisional'),
              _field('Email Kontak', 'admin@pade.com'),
              _field('Telepon', '021-12345678'),
              _field('Alamat', 'Bandung, Jawa Barat, Indonesia'),
            ]),
            const SizedBox(height: 20),

            // Admin profile
            _section('Profil Admin', Icons.person_rounded, [
              _field('Nama', 'Ahmad Fauzi'),
              _field('Email', 'ahmad.fauzi@mail.com'),
              _field('Role', 'Administrator'),
            ]),
            const SizedBox(height: 20),

            // App info
            _section('Informasi Aplikasi', Icons.info_rounded, [
              _field('Versi', '1.0.0'),
              _field('Backend', 'MongoDB Atlas'),
              _field('Framework', 'Flutter Web'),
              _field('Status API', 'Mock Data (Development)'),
            ]),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengaturan disimpan'), backgroundColor: AdminTheme.success),
                  );
                },
                child: const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AdminTheme.primaryLight, size: 20),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AdminTheme.border),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
