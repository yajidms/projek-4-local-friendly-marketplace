import 'package:flutter/material.dart';

import '../../../domain/entities/verification_request.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class VerificationDetailPage extends StatefulWidget {
  const VerificationDetailPage({super.key, required this.id});
  final String id;

  @override
  State<VerificationDetailPage> createState() => _VerificationDetailPageState();
}

class _VerificationDetailPageState extends State<VerificationDetailPage> {
  late final AdminRepository _repo;
  VerificationRequest? _request;
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
      final detail = await _repo.getVerificationDetail(widget.id);
      if (mounted) setState(() { _request = detail; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Setujui Toko?', style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text('Toko "${_request!.seller.shopName}" akan diverifikasi dan dapat beroperasi.', style: const TextStyle(color: AdminTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.success),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _repo.approveStore(_request!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toko berhasil disetujui'), backgroundColor: AdminTheme.success));
          Navigator.of(context).pushReplacementNamed(AdminRoutes.verification);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AdminTheme.danger));
      }
    }
  }

  Future<void> _reject() async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.bgCard,
        title: const Text('Tolak Verifikasi', style: TextStyle(color: AdminTheme.textPrimary)),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: reasonCtrl,
            maxLines: 3,
            style: const TextStyle(color: AdminTheme.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Alasan penolakan...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonCtrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      try {
        await _repo.rejectStore(_request!.id, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verifikasi ditolak'), backgroundColor: AdminTheme.danger));
          Navigator.of(context).pushReplacementNamed(AdminRoutes.verification);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AdminTheme.danger));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.verification,
      title: 'Detail Verifikasi',
      subtitle: _request?.seller.shopName ?? '',
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
              : SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.verification),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Kembali ke daftar'),
            ),
            const SizedBox(height: 20),

            // Status section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AdminTheme.bgCard,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                border: Border.all(color: AdminTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AdminTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AdminTheme.primaryLight, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_request!.seller.shopName, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Pemilik: ${_request!.owner.name} • ${_request!.owner.email}', style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  _statusWidget(_request!.status),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _infoCard('Informasi Toko', [
                    _infoRow('Nama Toko', _request!.seller.shopName),
                    _infoRow('Jenis Usaha', _request!.businessType),
                    _infoRow('Alamat', _request!.seller.shopAddress ?? '-'),
                    _infoRow('Telepon', _request!.seller.shopPhone ?? '-'),
                    _infoRow('Kategori', _request!.seller.categories.join(', ')),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _infoCard('Informasi Pemilik', [
                    _infoRow('Nama', _request!.owner.name),
                    _infoRow('Email', _request!.owner.email),
                    _infoRow('Telepon', _request!.owner.phone ?? '-'),
                    _infoRow('Tanggal Daftar', '${_request!.submittedAt.day}/${_request!.submittedAt.month}/${_request!.submittedAt.year}'),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Rejection reason
            if (_request!.isRejected && _request!.rejectionReason != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminTheme.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
                  border: Border.all(color: AdminTheme.danger.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.warning_amber_rounded, color: AdminTheme.danger, size: 18),
                      SizedBox(width: 8),
                      Text('Alasan Penolakan', style: TextStyle(color: AdminTheme.danger, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 8),
                    Text(_request!.rejectionReason!, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Actions
            if (_request!.isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _reject,
                    icon: const Icon(Icons.close_rounded, size: 18, color: AdminTheme.danger),
                    label: const Text('Tolak', style: TextStyle(color: AdminTheme.danger)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AdminTheme.danger)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _approve,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Setujui'),
                    style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.success),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusWidget(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved: return StatusBadge.verified();
      case VerificationStatus.rejected: return StatusBadge.rejected();
      case VerificationStatus.pending: return StatusBadge.pending();
    }
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AdminTheme.border),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}
