import 'package:flutter/material.dart';
import '../../main.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../app/routes/app_router.dart';
import '../../core/di/app_dependencies.dart';
import '../../data/datasources/local/in_memory_auth_local_datasource.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'username';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final auth = await InMemoryAuthLocalDataSource().getAuthSession();
      if (auth != null) {
        final user = await AppDependencies.userRepository.getUserById(auth.user.id);
        if (user != null && mounted) {
          setState(() {
            _userName = user.name.isNotEmpty ? user.name : 'username';
            _userEmail = user.email;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
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
                    const CircleAvatar(radius: 24, backgroundColor: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_isLoading ? 'Memuat...' : _userName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (_userEmail.isNotEmpty)
                            Text(_userEmail,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
          leading: Icon(icon, color: Theme.of(context).iconTheme.color),
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