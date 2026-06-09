import 'package:flutter/material.dart';
import '../../app/routes/app_router.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../config/env.dart';
import '../../core/auth/auth_bootstrap.dart';
import '../../core/di/app_dependencies.dart';
import '../../data/models/product_model.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  String _selectedCategory = '';
  bool _isInit = false;
  String? _sellerId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        _searchController.text = args['query'] ?? '';
        _selectedCategory = args['category'] ?? '';
      }
      
      _loadAuth();
      _loadProducts();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuth() async {
    final auth = await AuthBootstrap.build().getCurrentSession(
      useRemote: Env.hasConfiguredBackendUrl && !Env.usesMongoConnectionString,
    );
    if (auth != null && auth.user.isSeller) {
      _sellerId = auth.user.sellerId;
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await AppDependencies.productRepository.getAllProducts();
      setState(() {
        _allProducts = products.map((p) => ProductModel.fromEntity(p)).toList();
        _isLoading = false;
        _onSearch();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $e')),
        );
      }
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesQuery = p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory.isEmpty || p.category == _selectedCategory;
        final matchesSeller = _sellerId == null || p.sellerId == _sellerId;
        return matchesQuery && matchesCategory && matchesSeller;
      }).toList();
    });
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: Text(
          _sellerId != null ? 'Produk Saya' : 'Katalog Terdekat',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: theme.hintColor),
                  hintText: 'Cari produk, kategori...',
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedCategory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 8),
                child: Row(
                  children: [
                    Chip(
                      label: Text(_selectedCategory),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => setState(() { _selectedCategory = ''; _onSearch(); }),
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      labelStyle: const TextStyle(color: Colors.green, fontSize: 12),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ],
                ),
              ),
            if (!_isLoading)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('${_filteredProducts.length} produk ditemukan', style: TextStyle(fontSize: 12, color: theme.hintColor)),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _filteredProducts.isEmpty
                      ? Center(child: Text('Tidak ada produk ditemukan.', style: TextStyle(color: theme.hintColor)))
                      : GridView.builder(
                          itemCount: _filteredProducts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78,
                          ),
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return InkWell(
                              onTap: () => Navigator.pushNamed(
                                context, AppRoutes.product,
                                arguments: {'productId': product.id},
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          decoration: BoxDecoration(color: theme.colorScheme.outlineVariant),
                                          child: product.images != null && product.images!.isNotEmpty
                                              ? Image.network(
                                                  product.images!.first,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image, color: Colors.white54)),
                                                  loadingBuilder: (_, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                            : null,
                                                        color: Colors.green,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const Center(child: Icon(Icons.image, color: Colors.white54)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(product.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(_formatPrice(product.price), style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}