import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('username',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Switch(
                      value: _isOnline,
                      onChanged: (val) => setState(() => _isOnline = val),
                      activeColor: Colors.green,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
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
                onPressed: () {},
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLast;
  const _MenuItem({required this.icon, required this.label, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
          onTap: () {},
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}