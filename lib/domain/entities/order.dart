import 'order_item.dart';
import 'payment.dart';
import 'shipment.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.refunded:
        return 'refunded';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Represents a customer order (Pesanan in ERD)
class Order {
  final String id; // id_pesanan
  final String userId;
  final String? sellerId;
  final String? marketplaceId;
  final List<OrderItem> items; // terdiri_dari
  final OrderStatus status;
  final Payment? payment;
  final Shipment? shipment;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isSynced;

  Order({
    required this.id,
    required this.userId,
    this.sellerId,
    this.marketplaceId,
    required this.items,
    required this.status,
    this.payment,
    this.shipment,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isSynced = true,
  });

  /// Check if order is paid
  bool get isPaid => payment?.isCompleted ?? false;

  /// Check if order is shipped
  bool get isShipped => shipment?.isInTransit ?? false;

  /// Check if order is delivered
  bool get isDelivered => shipment?.isDelivered ?? false;

  /// Get item count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Create a copy with modified fields
  Order copyWith({
    String? id,
    String? userId,
    String? sellerId,
    String? marketplaceId,
    List<OrderItem>? items,
    OrderStatus? status,
    Payment? payment,
    Shipment? shipment,
    double? subtotal,
    double? tax,
    double? shippingCost,
    double? total,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isSynced,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      marketplaceId: marketplaceId ?? this.marketplaceId,
      items: items ?? this.items,
      status: status ?? this.status,
      payment: payment ?? this.payment,
      shipment: shipment ?? this.shipment,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
