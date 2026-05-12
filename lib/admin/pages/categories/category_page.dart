import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _ds = AdminMockDatasource();

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Nama kategori')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'Deskripsi'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kategori berhasil ditambahkan'), backgroundColor: AdminTheme.success),
              );
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _ds.categories;

    return AdminScaffold(
      currentRoute: AdminRoutes.categories,
      title: 'Manajemen Kategori',
      subtitle: '${categories.length} kategori terdaftar',
      headerActions: [
        ElevatedButton.icon(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah Kategori'),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: LayoutBuilder(builder: (context, constraints) {
          final crossCount = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AdminTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(cat.icon ?? '📦', style: const TextStyle(fontSize: 22))),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AdminTheme.textMuted, size: 18),
                        color: AdminTheme.bgCard,
                        onSelected: (v) {
                          if (v == 'delete') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Kategori "${cat.name}" dihapus'), backgroundColor: AdminTheme.danger),
                            );
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: AdminTheme.danger))),
                        ],
                      ),
                    ]),
                    const Spacer(),
                    Text(cat.name, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${cat.productCount} produk', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
