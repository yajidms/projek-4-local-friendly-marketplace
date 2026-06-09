import 'seller.dart';
import 'user.dart';

enum VerificationStatus {
  pending,
  approved,
  rejected,
}

extension VerificationStatusExtension on VerificationStatus {
  String get value {
    switch (this) {
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case VerificationStatus.pending:
        return 'Menunggu';
      case VerificationStatus.approved:
        return 'Disetujui';
      case VerificationStatus.rejected:
        return 'Ditolak';
    }
  }

  static VerificationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }
}

/// Represents a store verification request submitted by a seller for admin review.
/// Part of the "Moderasi Terpusat" requirement from SRS.
class VerificationRequest {
  final String id;
  final Seller seller;
  final User owner;
  final String businessType;
  final String? idCardUrl;
  final String? businessDocUrl;
  final VerificationStatus status;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  VerificationRequest({
    required this.id,
    required this.seller,
    required this.owner,
    required this.businessType,
    this.idCardUrl,
    this.businessDocUrl,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  bool get isPending => status == VerificationStatus.pending;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;

  VerificationRequest copyWith({
    String? id,
    Seller? seller,
    User? owner,
    String? businessType,
    String? idCardUrl,
    String? businessDocUrl,
    VerificationStatus? status,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      seller: seller ?? this.seller,
      owner: owner ?? this.owner,
      businessType: businessType ?? this.businessType,
      idCardUrl: idCardUrl ?? this.idCardUrl,
      businessDocUrl: businessDocUrl ?? this.businessDocUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerificationRequest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
