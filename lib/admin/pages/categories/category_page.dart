import 'package:flutter/material.dart';

import '../../../domain/entities/store_category.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final AdminRepository _repo;
  List<StoreCategory> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = AdminProvider.read(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cats = await _repo.getCategories();
      if (mounted) setState(() { _categories = cats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final iconCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Tambah Kategori', style: TextStyle(color: AdminTheme.textPrimary)),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AdminTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Nama Kategori *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: AdminTheme.textPrimary),
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: iconCtrl,
              style: const TextStyle(color: AdminTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Icon (emoji / URL)', border: OutlineInputBorder()),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (result == true && nameCtrl.text.isNotEmpty) {
      try {
        await _repo.createCategory(StoreCategory(
          id: '',
          name: nameCtrl.text,
          description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
          icon: iconCtrl.text.isNotEmpty ? iconCtrl.text : null,
          createdAt: DateTime.now(),
        ));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil ditambahkan'), backgroundColor: AdminTheme.success));
          _loadData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AdminTheme.danger));
      }
    }
  }

  Future<void> _showEditDialog(StoreCategory category) async {
    final nameCtrl = TextEditingController(text: category.name);
    final descCtrl = TextEditingController(text: category.description ?? '');
    final iconCtrl = TextEditingController(text: category.icon ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Edit Kategori', style: TextStyle(color: AdminTheme.textPrimary)),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Nama Kategori *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, style: const TextStyle(color: AdminTheme.textPrimary), maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: iconCtrl, style: const TextStyle(color: AdminTheme.textPrimary), decoration: const InputDecoration(labelText: 'Icon (emoji / URL)', border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (result == true && nameCtrl.text.isNotEmpty) {
      try {
        await _repo.updateCategory(category.copyWith(
          name: nameCtrl.text,
          description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
          icon: iconCtrl.text.isNotEmpty ? iconCtrl.text : null,
        ));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil diperbarui'), backgroundColor: AdminTheme.success));
          _loadData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AdminTheme.danger));
      }
    }
  }

  Future<void> _deleteCategory(StoreCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Hapus Kategori?', style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text('Kategori "${category.name}" akan dihapus.', style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repo.deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil dihapus'), backgroundColor: AdminTheme.success));
          _loadData();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AdminTheme.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.categories,
      title: 'Kategori',
      subtitle: 'Manajemen kategori toko',
      headerActions: [
        ElevatedButton.icon(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah Kategori'),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AdminTheme.primaryLight))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, color: AdminTheme.danger, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
                ]))
              : Padding(
        padding: const EdgeInsets.all(28),
        child: _categories.isEmpty
            ? const Center(child: Text('Belum ada kategori.', style: TextStyle(color: AdminTheme.textMuted, fontSize: 16)))
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            childAspectRatio: 1.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AdminTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(cat.icon ?? '📁', style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(cat.name, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('${cat.productCount} produk', style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12)),
                  ])),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AdminTheme.textSecondary, size: 18),
                    onSelected: (val) {
                      if (val == 'edit') _showEditDialog(cat);
                      if (val == 'delete') _deleteCategory(cat);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: AdminTheme.danger))),
                    ],
                  ),
                ]),
                const Spacer(),
                if (cat.description != null)
                  Text(cat.description!, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            );
          },
        ),
      ),
    );
  }
}
