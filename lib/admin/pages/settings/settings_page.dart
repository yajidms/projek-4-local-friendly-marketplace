import 'package:flutter/material.dart';

import 'dart:convert';
import '../../../data/datasources/remote/admin_api_datasource.dart';
import '../../../data/services/token_manager.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _adminName = 'Mengambil data...';
  String _adminEmail = 'Mengambil data...';
  String _adminRole = 'Administrator';
  bool _isApiOnline = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final ds = AdminApiDatasource();
      
      // Check API Health
      final isOnline = await ds.checkHealth();
      
      // Get User from JWT
      String? name;
      String? email;
      String? role;
      
      final token = TokenManager.instance.accessToken;
      if (token != null) {
        final parts = token.split('.');
        if (parts.length >= 2) {
          final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final json = jsonDecode(payload) as Map<String, dynamic>;
          final userId = json['user_id'] as String?;
          
          if (userId != null) {
            final user = await ds.getUserById(userId);
            if (user != null) {
              name = user.name;
              email = user.email;
              role = user.roles.isNotEmpty ? user.roles.first.name.toUpperCase() : 'Administrator';
            }
          }
          
          if (name == null) {
            name = json['name'];
            email = json['email'];
          }
        }
      }

      if (mounted) {
        setState(() {
          _isApiOnline = isOnline;
          _adminName = name ?? 'Administrator';
          _adminEmail = email ?? 'admin@pade.com';
          _adminRole = role ?? 'Administrator';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _adminName = 'Administrator';
          _adminEmail = 'admin@pade.com';
          _isLoading = false;
        });
      }
    }
  }

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
              _field('Nama', _adminName),
              _field('Email', _adminEmail),
              _field('Role', _adminRole),
            ]),
            const SizedBox(height: 20),

            // App info
            _section('Informasi Aplikasi', Icons.info_rounded, [
              _field('Versi', '1.0.0'),
              _field('Backend', 'MongoDB Atlas + Fiber Go'),
              _field('Framework', 'Flutter Web'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text('Status API', style: TextStyle(color: AdminTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _isLoading 
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : Icon(
                                _isApiOnline ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: _isApiOnline ? AdminTheme.success : AdminTheme.danger,
                                size: 16,
                              ),
                          const SizedBox(width: 6),
                          Text(
                            _isLoading ? 'Mengecek...' : (_isApiOnline ? 'Online' : 'Offline'),
                            style: TextStyle(
                              color: _isApiOnline ? AdminTheme.success : AdminTheme.danger,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
