import 'package:flutter/material.dart';

import '../../../domain/entities/verification_request.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class VerificationListPage extends StatefulWidget {
  const VerificationListPage({super.key});

  @override
  State<VerificationListPage> createState() => _VerificationListPageState();
}

class _VerificationListPageState extends State<VerificationListPage> {
  late final AdminRepository _repo;
  List<VerificationRequest> _allRequests = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _repo = AdminProvider.read(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final requests = await _repo.getVerificationRequests();
      if (mounted) setState(() { _allRequests = requests; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<VerificationRequest> get _filteredRequests {
    List<VerificationRequest> list = _allRequests.toList();
    if (_filter != 'all') {
      list = list.where((VerificationRequest r) => r.status.name == _filter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((VerificationRequest r) =>
              r.seller.shopName.toLowerCase().contains(q) ||
              r.owner.name.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests;

    return AdminScaffold(
      currentRoute: AdminRoutes.verification,
      title: 'Verifikasi Toko',
      subtitle: 'Moderasi dan persetujuan pendaftaran toko baru',
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
        child: Column(
          children: [
            Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Menunggu', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Disetujui', 'approved'),
                const SizedBox(width: 8),
                _buildFilterChip('Ditolak', 'rejected'),
                const Spacer(),
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Cari toko atau pemilik...',
                      prefixIcon: Icon(Icons.search, color: AdminTheme.textMuted),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AdminTheme.bgCard,
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: requests.isEmpty
                    ? const Center(child: Text('Tidak ada data.', style: TextStyle(color: AdminTheme.textMuted)))
                    : ListView(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: const BoxDecoration(
                              color: AdminTheme.bgSurface,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(AdminTheme.radiusMd), topRight: Radius.circular(AdminTheme.radiusMd)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: Text('Nama Toko', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                                Expanded(flex: 2, child: Text('Pemilik', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                                Expanded(flex: 2, child: Text('Jenis Usaha', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                                Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                                Expanded(flex: 1, child: Text('Status', style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                                SizedBox(width: 80, child: Text('Aksi', textAlign: TextAlign.center, style: TextStyle(color: AdminTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AdminTheme.border),
                          ...requests.map(_buildRow),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _filter == value;
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: AdminTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AdminTheme.primaryLight,
      labelStyle: TextStyle(
        color: selected ? AdminTheme.primaryLight : AdminTheme.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildRow(VerificationRequest req) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AdminRoutes.verificationDetail, arguments: req.id),
        hoverColor: AdminTheme.bgHover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AdminTheme.border, width: 0.5))),
          child: Row(
            children: [
              Expanded(flex: 3, child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: AdminTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.storefront_rounded, color: AdminTheme.primaryLight, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Text(req.seller.shopName, style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ])),
              Expanded(flex: 2, child: Text(req.owner.name, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
              Expanded(flex: 2, child: Text(req.businessType, style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
              Expanded(flex: 2, child: Text('${req.submittedAt.day}/${req.submittedAt.month}/${req.submittedAt.year}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 14))),
              Expanded(flex: 1, child: _statusBadge(req.status)),
              SizedBox(width: 80, child: Center(child: IconButton(icon: const Icon(Icons.arrow_forward_rounded, color: AdminTheme.textSecondary, size: 18), onPressed: () => Navigator.of(context).pushNamed(AdminRoutes.verificationDetail, arguments: req.id)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved: return StatusBadge.verified();
      case VerificationStatus.rejected: return StatusBadge.rejected();
      case VerificationStatus.pending: return StatusBadge.pending();
    }
  }
}
