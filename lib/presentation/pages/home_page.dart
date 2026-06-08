import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../app/routes/app_router.dart';
import '../../core/di/app_dependencies.dart';
import '../../domain/entities/seller.dart';
import '../../domain/entities/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<Position>? _positionSubscription;
  double? _userLat;
  double? _userLng;
  bool _isLoadingLocation = true;
  bool _isBottomRefreshInProgress = false;
  bool _isRequestingLocationPermission = false;
  String? _locationStatusMessage;
  List<Seller> _cachedSellers = [];
  List<_StoreWithDistance> _nearbyStores = [];

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationTracking() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _locationStatusMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
          _locationStatusMessage =
              'Aktifkan layanan lokasi agar kami bisa membaca GPS Anda dan menampilkan toko terdekat.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _isRequestingLocationPermission = true;
          _locationStatusMessage =
              'Izinkan akses lokasi untuk melihat toko terdekat berdasarkan GPS Anda.';
        });
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        setState(() {
          _isRequestingLocationPermission = false;
        });
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
          _locationStatusMessage =
              'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengaktifkan GPS.';
        });
        return;
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
          _locationStatusMessage =
              'Akses lokasi diperlukan agar toko terdekat bisa dihitung dari posisi Anda.';
        });
        return;
      }

      await _loadCurrentUserLocationAndStores();
      await _startLocationStream();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _locationStatusMessage =
            'Tidak dapat membaca lokasi saat ini. Coba aktifkan GPS lalu muat ulang halaman.';
      });
    }
  }

  Future<void> _loadCurrentUserLocationAndStores() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    await _updateNearbyStores(
      Location(latitude: position.latitude, longitude: position.longitude),
      refreshSellers: true,
    );
  }

  Future<void> _startLocationStream() async {
    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    ).listen((position) {
      _updateNearbyStores(
        Location(latitude: position.latitude, longitude: position.longitude),
      );
    });
  }

  Future<void> _updateNearbyStores(
    Location userLocation, {
    bool refreshSellers = false,
  }) async {
    List<Seller> sellers = _cachedSellers;
    if (refreshSellers || sellers.isEmpty) {
      try {
        sellers = await AppDependencies.sellerRepository.getAllSellers();
        _cachedSellers = sellers;
      } catch (_) {
        sellers = [];
      }
    }

    final stores = sellers.map((s) {
      final distance = s.location == null
          ? double.infinity
          : s.location!.distanceTo(userLocation);
      return _StoreWithDistance(seller: s, distance: distance);
    }).toList();

    stores.sort((a, b) => a.distance.compareTo(b.distance));

    if (!mounted) return;

    setState(() {
      _userLat = userLocation.latitude;
      _userLng = userLocation.longitude;
      _nearbyStores = stores;
      _isLoadingLocation = false;
      _locationStatusMessage = null;
    });
  }

  Future<void> _refreshHomeData() async {
    await _initializeLocationTracking();
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void _triggerBottomRefresh() {
    if (_isBottomRefreshInProgress) return;
    _isBottomRefreshInProgress = true;
    _refreshHomeData().whenComplete(() {
      _isBottomRefreshInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: NotificationListener<OverscrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final isBottomOverscroll = notification.overscroll > 0 &&
                metrics.pixels >= metrics.maxScrollExtent;
            if (isBottomOverscroll) {
              _triggerBottomRefresh();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: _refreshHomeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_locationStatusMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.my_location_rounded,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _locationStatusMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_userLat != null && _userLng != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'GPS: ${_userLat!.toStringAsFixed(5)}, ${_userLng!.toStringAsFixed(5)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (_isRequestingLocationPermission)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.green,
                                    ),
                                  )
                                else
                                  FilledButton.tonal(
                                    onPressed: _initializeLocationTracking,
                                    child: const Text('Izinkan Lokasi'),
                                  ),
                                TextButton(
                                  onPressed: _openLocationSettings,
                                  child: const Text('Buka Pengaturan GPS'),
                                ),
                                TextButton(
                                  onPressed: _openAppSettings,
                                  child: const Text('Pengaturan Aplikasi'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.catalog),
                              child: AbsorbPointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.search,
                                        color: theme.hintColor),
                                    hintText: 'Cari produk...',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.notifications_none_rounded,
                            color: theme.iconTheme.color),
                        const SizedBox(width: 8),
                        Icon(Icons.chat_bubble_outline_rounded,
                            color: theme.iconTheme.color),
                      ],
                    ),
                  ),

                  // Green Banner
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
                  const SizedBox(height: 20),

                  // Kategori — 2 baris
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CategoryItem(
                              icon: Icons.location_on_outlined,
                              label: 'Lokasi',
                              category: '',
                              sortByLocation: true,
                            ),
                            _CategoryItem(
                                icon: Icons.checkroom_outlined,
                                label: 'Fashion',
                                category: 'Fashion'),
                            _CategoryItem(
                                icon: Icons.storefront_outlined,
                                label: 'Toko',
                                category: 'Toko'),
                            _CategoryItem(
                                icon: Icons.rice_bowl_outlined,
                                label: 'Makanan',
                                category: 'Makanan'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CategoryItem(
                                icon: Icons.devices_outlined,
                                label: 'Elektronik',
                                category: 'Elektronik'),
                            _CategoryItem(
                                icon: Icons.eco_outlined,
                                label: 'Sayuran',
                                category: 'Sayuran'),
                            _CategoryItem(
                                icon: Icons.home_outlined,
                                label: 'Rumah Tangga',
                                category: 'Rumah Tangga'),
                            _CategoryItem(
                              icon: Icons.grid_view_rounded,
                              label: 'Lainnya',
                              category: '',
                              onTapOverride: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Kategori Lainnya',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 24,
                                            runSpacing: 16,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(context,
                                                      AppRoutes.catalog,
                                                      arguments: {
                                                        'category': 'Olahraga'
                                                      });
                                                },
                                                child: const Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .sports_basketball_outlined,
                                                        size: 30,
                                                        color: Colors.green),
                                                    SizedBox(height: 4),
                                                    Text('Olahraga',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.pushNamed(context,
                                                      AppRoutes.catalog,
                                                      arguments: {
                                                        'category': 'Buku'
                                                      });
                                                },
                                                child: const Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons.menu_book_rounded,
                                                        size: 30,
                                                        color: Colors.green),
                                                    SizedBox(height: 4),
                                                    Text('Buku',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 32),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Toko Terdekat (Recommended Stores)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toko Terdekat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.catalog),
                          icon: const Icon(Icons.arrow_forward_ios, size: 12),
                          label: const Text('Lihat Semua',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_isLoadingLocation)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Center(
                          child:
                              CircularProgressIndicator(color: Colors.green)),
                    )
                  else ...[
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _nearbyStores.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final store = _nearbyStores[index];
                          return _NearbyStoreCard(
                            seller: store.seller,
                            distance: store.distance,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.catalog,
                              arguments: {
                                'category': store.seller.categories.isNotEmpty
                                    ? store.seller.categories.first
                                    : ''
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Baru-baru ini dibeli
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Baru-baru ini dibeli',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _StoreWithDistance {
  final Seller seller;
  final double distance;

  _StoreWithDistance({required this.seller, required this.distance});
}

class _NearbyStoreCard extends StatelessWidget {
  final Seller seller;
  final double distance;
  final VoidCallback onTap;

  const _NearbyStoreCard({
    required this.seller,
    required this.distance,
    required this.onTap,
  });

  String _formatDistance(double km) {
    if (km.isInfinite) return 'Lokasi belum tersedia';
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.storefront, color: Colors.green, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              seller.shopName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  seller.rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.location_on, size: 10, color: Colors.grey),
                const SizedBox(width: 2),
                Text(
                  _formatDistance(distance),
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${seller.totalReviews} ulasan',
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String category;
  final bool sortByLocation;
  final VoidCallback? onTapOverride;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.category,
    this.sortByLocation = false,
    this.onTapOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTapOverride ??
          () => Navigator.pushNamed(
                context,
                AppRoutes.catalog,
                arguments: {
                  'category': category,
                  'sortByLocation': sortByLocation,
                },
              ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 26, color: theme.iconTheme.color),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: theme.textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}
