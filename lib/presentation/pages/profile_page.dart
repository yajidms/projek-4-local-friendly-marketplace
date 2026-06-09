import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../app/routes/app_router.dart';
import '../../core/di/app_dependencies.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/location.dart';
import '../../data/services/token_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final auth = await AuthBootstrap.build().getCurrentSession(
        useRemote: Env.hasConfiguredBackendUrl && !Env.usesMongoConnectionString,
      );
      if (auth != null) {
        final user = await AppDependencies.userRepository.getUserById(auth.user.id);
        if (user != null && mounted) {
          setState(() {
            _user = user;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _showBuatTokoSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BuatTokoSheet(userId: _user!.id),
    );

    if (result == 'success') {
      _loadUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toko berhasil dibuat!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (result != null && result.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.green.shade100,
                      child: _user != null && _user!.profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _user!.profileImageUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : Text(
                              _user != null
                                  ? _user!.name.isNotEmpty
                                      ? _user!.name[0].toUpperCase()
                                      : '?'
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_isLoading ? 'Memuat...' : (_user?.name ?? 'username'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (_user != null && _user!.email.isNotEmpty)
                            Text(_user!.email,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          if (_user != null)
                            const SizedBox(height: 4),
                          if (_user != null)
                            Row(
                              children: [
                                if (_user!.isAdmin)
                                  _RoleBadge(label: 'Admin', color: Colors.red),
                                if (_user!.isSeller)
                                  _RoleBadge(label: 'Penjual', color: Colors.orange),
                                if (_user!.isBuyer)
                                  _RoleBadge(label: 'Pembeli', color: Colors.blue),
                              ],
                            ),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (context, themeMode, _) {
                        return Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (isDark) {
                            themeNotifier.value =
                                isDark ? ThemeMode.dark : ThemeMode.light;
                          },
                          activeThumbColor: Colors.green,
                        );
                      },
                    ),
                    const Icon(Icons.settings_outlined),
                  ],
                ),
              ),

              // Green Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Menu
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (_user != null && _user!.isSeller) ...[
                      _MenuItem(
                        icon: Icons.store_rounded,
                        label: 'Masuk ke Toko',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.sellerDashboard),
                      ),
                    ] else ...[
                      _MenuItem(
                        icon: Icons.add_business_rounded,
                        label: 'Buat Toko',
                        onTap: _showBuatTokoSheet,
                      ),
                    ],
                    _MenuItem(icon: Icons.star_border_rounded, label: 'Rating & Ulasan'),
                    _MenuItem(icon: Icons.security_outlined, label: 'Perizinan Aplikasi'),
                    _MenuItem(icon: Icons.store_outlined, label: 'Toko yang diikuti'),
                    _MenuItem(icon: Icons.storefront_outlined, label: 'Temukan Toko Terdekat'),
                    _MenuItem(icon: Icons.info_outline_rounded, label: 'Tentang Aplikasi ini'),
                    _MenuItem(icon: Icons.menu_book_outlined, label: 'Panduan Pengguna'),
                    _MenuItem(icon: Icons.headset_mic_outlined, label: 'Customer Service', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Keluar
              TextButton(
                onPressed: () async {
                  final auth = AuthBootstrap.build();
                  await auth.logout(useRemote: false);
                  try {
                    await auth.logout(useRemote: true);
                  } catch (_) {}
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.auth,
                    (route) => false,
                  );
                },
                child: const Text('Keluar',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RoleBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLast;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.isLast = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).iconTheme.color),
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

const _availableCategories = [
  'Makanan',
  'Minuman',
  'Fashion',
  'Elektronik',
  'Sayuran',
  'Rumah Tangga',
  'Olahraga',
  'Buku',
  'Sembako',
  'Kesehatan',
  'Mainan',
  'Aksesoris',
];

class _BuatTokoSheet extends StatefulWidget {
  final String userId;

  const _BuatTokoSheet({
    required this.userId,
  });

  @override
  State<_BuatTokoSheet> createState() => _BuatTokoSheetState();
}

class _BuatTokoSheetState extends State<_BuatTokoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _teleponController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  String? _imagePath;
  final Set<String> _selectedCategories = {};
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      setState(() => _imagePath = file.path);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi diperlukan untuk mengisi koordinat')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (mounted) {
        setState(() {
          _latController.text = position.latitude.toStringAsFixed(7);
          _longController.text = position.longitude.toStringAsFixed(7);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu kategori')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final lat = double.tryParse(_latController.text);
      final lng = double.tryParse(_longController.text);

      final body = <String, dynamic>{
        'userId': widget.userId,
        'shopName': _namaController.text.trim(),
        'categories': _selectedCategories.toList(),
      };

      final desc = _deskripsiController.text.trim();
      if (desc.isNotEmpty) body['shopDescription'] = desc;

      final alamat = _alamatController.text.trim();
      if (alamat.isNotEmpty) body['shopAddress'] = alamat;

      final telp = _teleponController.text.trim();
      if (telp.isNotEmpty) body['shopPhone'] = telp;

      if (lat != null && lng != null) {
        body['location'] = {
          'latitude': lat,
          'longitude': lng,
        };
      }

      final token = TokenManager.instance;
      final client = http.Client();
      final response = await client.post(
        token.uri('/sellers'),
        headers: token.authHeaders,
        body: jsonEncode(body),
      );
      client.close();

      if (mounted) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          Navigator.of(context).pop('success');
        } else {
          final msg = response.body.isNotEmpty ? response.body : '${response.statusCode}';
          Navigator.of(context).pop('Gagal membuat toko: $msg');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop('Gagal membuat toko: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Buat Toko',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lengkapi data toko Anda',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Nama Toko'),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama toko',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Nama toko wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Deskripsi Toko'),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(
                        hintText: 'Deskripsi singkat tentang toko',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Gambar Toko'),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 140,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 40, color: Colors.grey[400]),
                                  const SizedBox(height: 6),
                                  Text('Ketuk untuk upload gambar',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Alamat Toko'),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        hintText: 'Alamat lengkap toko',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Nomor Telepon'),
                    TextFormField(
                      controller: _teleponController,
                      decoration: const InputDecoration(
                        hintText: 'Nomor telepon toko',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Lokasi (Latitude / Longitude)'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: const InputDecoration(
                              hintText: 'Latitude',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _longController,
                            decoration: const InputDecoration(
                              hintText: 'Longitude',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isGettingLocation ? null : _getCurrentLocation,
                            icon: _isGettingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location, size: 18),
                            label: Text(
                              _isGettingLocation ? '...' : 'Ambil',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Kategori'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _availableCategories.map((cat) {
                        final selected = _selectedCategories.contains(cat);
                        return FilterChip(
                          label: Text(cat, style: const TextStyle(fontSize: 13)),
                          selected: selected,
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedCategories.add(cat);
                              } else {
                                _selectedCategories.remove(cat);
                              }
                            });
                          },
                          selectedColor: Colors.green[100],
                          checkmarkColor: Colors.green,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'Daftarkan Toko',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}