enum ShippingMethod {
  standard,
  express,
  overnight,
}

extension ShippingMethodExtension on ShippingMethod {
  String get value {
    switch (this) {
      case ShippingMethod.standard:
        return 'standard';
      case ShippingMethod.express:
        return 'express';
      case ShippingMethod.overnight:
        return 'overnight';
    }
  }
}

enum ShippingStatus {
  pending,
  processing,
  shipped,
  inTransit,
  delivered,
  failed,
}

extension ShippingStatusExtension on ShippingStatus {
  String get value {
    switch (this) {
      case ShippingStatus.pending:
        return 'pending';
      case ShippingStatus.processing:
        return 'processing';
      case ShippingStatus.shipped:
        return 'shipped';
      case ShippingStatus.inTransit:
        return 'in_transit';
      case ShippingStatus.delivered:
        return 'delivered';
      case ShippingStatus.failed:
        return 'failed';
    }
  }
}

/// Represents shipping/delivery information (Pengiriman in ERD)
class Shipment {
  final String id; // id_kirim
  final String orderId;
  final ShippingMethod method; // metode
  final ShippingStatus status;
  final String? trackingNumber;
  final String? carrier;
  final String? shippingAddress;
  final DateTime estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Shipment({
    required this.id,
    required this.orderId,
    required this.method,
    required this.status,
    this.trackingNumber,
    this.carrier,
    this.shippingAddress,
    required this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if shipment is delivered
  bool get isDelivered => status == ShippingStatus.delivered;

  /// Check if shipment is in transit
  bool get isInTransit => status == ShippingStatus.inTransit;

  /// Create a copy with modified fields
  Shipment copyWith({
    String? id,
    String? orderId,
    ShippingMethod? method,
    ShippingStatus? status,
    String? trackingNumber,
    String? carrier,
    String? shippingAddress,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shipment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      method: method ?? this.method,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      carrier: carrier ?? this.carrier,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shipment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
