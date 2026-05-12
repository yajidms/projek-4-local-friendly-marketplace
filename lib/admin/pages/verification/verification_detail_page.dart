import 'package:flutter/material.dart';

import '../../../data/datasources/local/admin_mock_datasource.dart';
import '../../../domain/entities/verification_request.dart';
import '../../routes/admin_router.dart';
import '../../theme/admin_theme.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/status_badge.dart';

class VerificationDetailPage extends StatefulWidget {
  const VerificationDetailPage({super.key, required this.id});
  final String id;

  @override
  State<VerificationDetailPage> createState() => _VerificationDetailPageState();
}

class _VerificationDetailPageState extends State<VerificationDetailPage> {
  late VerificationRequest _request;

  @override
  void initState() {
    super.initState();
    final ds = AdminMockDatasource();
    _request = ds.verificationRequests.firstWhere((VerificationRequest r) => r.id == widget.id);
  }

  void _approve() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Setujui Toko?'),
        content: Text('Toko "${_request.seller.shopName}" akan disetujui dan tampil ke buyer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Toko "${_request.seller.shopName}" telah disetujui ✓'), backgroundColor: AdminTheme.success));
              Navigator.of(context).pushReplacementNamed(AdminRoutes.verification);
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _reject() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak Toko?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Berikan alasan penolakan untuk "${_request.seller.shopName}"'),
            const SizedBox(height: 16),
            TextField(controller: reasonCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Alasan penolakan...')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Toko "${_request.seller.shopName}" telah ditolak'), backgroundColor: AdminTheme.danger));
              Navigator.of(context).pushReplacementNamed(AdminRoutes.verification);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AdminRoutes.verification,
      title: 'Detail Verifikasi',
      subtitle: _request.seller.shopName,
      headerActions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AdminRoutes.verification),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Kembali'),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: _buildMainInfo()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildSideInfo()),
            ]);
          }
          return Column(children: [_buildMainInfo(), const SizedBox(height: 20), _buildSideInfo()]);
        }),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(children: [
      _card('Informasi Toko', Icons.storefront_rounded, [
        _infoRow('Nama Toko', _request.seller.shopName),
        _infoRow('Deskripsi', _request.seller.shopDescription ?? '-'),
        _infoRow('Alamat', _request.seller.shopAddress ?? '-'),
        _infoRow('Kategori', _request.seller.categories.join(', ')),
        _infoRow('Jenis Usaha', _request.businessType),
        _infoRow('Telepon', _request.seller.shopPhone ?? '-'),
      ]),
      const SizedBox(height: 20),
      _card('Dokumen Verifikasi', Icons.description_rounded, [
        const Text('KTP / Tanda Pengenal', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 180, width: double.infinity,
          decoration: BoxDecoration(color: AdminTheme.bgSurface, borderRadius: BorderRadius.circular(AdminTheme.radiusSm), border: Border.all(color: AdminTheme.border)),
          child: _request.idCardUrl != null
              ? ClipRRect(borderRadius: BorderRadius.circular(AdminTheme.radiusSm), child: Image.network(_request.idCardUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_rounded, color: AdminTheme.textMuted, size: 40))))
              : const Center(child: Text('Tidak ada dokumen', style: TextStyle(color: AdminTheme.textMuted))),
        ),
        const SizedBox(height: 16),
        const Text('Dokumen Usaha', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 180, width: double.infinity,
          decoration: BoxDecoration(color: AdminTheme.bgSurface, borderRadius: BorderRadius.circular(AdminTheme.radiusSm), border: Border.all(color: AdminTheme.border)),
          child: _request.businessDocUrl != null
              ? ClipRRect(borderRadius: BorderRadius.circular(AdminTheme.radiusSm), child: Image.network(_request.businessDocUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_rounded, color: AdminTheme.textMuted, size: 40))))
              : const Center(child: Text('Tidak ada dokumen', style: TextStyle(color: AdminTheme.textMuted))),
        ),
      ]),
    ]);
  }

  Widget _buildSideInfo() {
    return Column(children: [
      _card('Status Verifikasi', Icons.verified_user_rounded, [
        Center(child: _request.isPending ? StatusBadge.pending() : _request.isApproved ? StatusBadge.verified() : StatusBadge.rejected()),
        if (_request.rejectionReason != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AdminTheme.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AdminTheme.radiusSm), border: Border.all(color: AdminTheme.danger.withValues(alpha: 0.2))),
            child: Text('Alasan: ${_request.rejectionReason}', style: const TextStyle(color: AdminTheme.danger, fontSize: 13)),
          ),
        ],
        const SizedBox(height: 16),
        _infoRow('Diajukan', '${_request.submittedAt.day}/${_request.submittedAt.month}/${_request.submittedAt.year}'),
        if (_request.reviewedAt != null)
          _infoRow('Direview', '${_request.reviewedAt!.day}/${_request.reviewedAt!.month}/${_request.reviewedAt!.year}'),
      ]),
      const SizedBox(height: 20),
      _card('Informasi Pemilik', Icons.person_rounded, [
        _infoRow('Nama', _request.owner.name),
        _infoRow('Email', _request.owner.email),
        _infoRow('Telepon', _request.owner.phone ?? '-'),
      ]),
      const SizedBox(height: 20),
      if (_request.isPending)
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: 48, child: ElevatedButton.icon(onPressed: _approve, icon: const Icon(Icons.check_circle_rounded), label: const Text('Setujui Toko'), style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.success))),
          const SizedBox(height: 12),
          SizedBox(height: 48, child: OutlinedButton.icon(onPressed: _reject, icon: const Icon(Icons.cancel_rounded, color: AdminTheme.danger), label: const Text('Tolak Toko', style: TextStyle(color: AdminTheme.danger)), style: OutlinedButton.styleFrom(side: const BorderSide(color: AdminTheme.danger)))),
        ]),
    ]);
  }

  Widget _card(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AdminTheme.bgCard, borderRadius: BorderRadius.circular(AdminTheme.radiusMd), border: Border.all(color: AdminTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: AdminTheme.primaryLight, size: 20), const SizedBox(width: 10), Text(title, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600))]),
        const SizedBox(height: 16), const Divider(height: 1, color: AdminTheme.border), const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 14))),
      ]),
    );
  }
}
