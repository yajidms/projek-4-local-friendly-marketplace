import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';
import 'order_item_model.dart';

part 'order_model.g.dart';


@JsonSerializable(explicitToJson: true)
class OrderModel {
  final String id;
  final String userId;
  final String? sellerId;
  final String? marketplaceId;
  final List<OrderItemModel> items;
  final String status;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(includeToJson: false)
  final DateTime? lastSyncedAt;
  @JsonKey(includeToJson: false)
  final bool isSynced;

  OrderModel({
    required this.id,
    required this.userId,
    this.sellerId,
    this.marketplaceId,
    required this.items,
    required this.status,
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

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  Order toEntity() {
    final statusEnum = OrderStatusExtension.fromString(status);
    return Order(
      id: id,
      userId: userId,
      sellerId: sellerId,
      marketplaceId: marketplaceId,
      items: items.map((e) => e.toEntity()).toList(),
      status: statusEnum,
      subtotal: subtotal,
      tax: tax,
      shippingCost: shippingCost,
      total: total,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: lastSyncedAt,
      isSynced: isSynced,
    );
  }

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      sellerId: order.sellerId,
      marketplaceId: order.marketplaceId,
      items: order.items.map((e) => OrderItemModel(
        id: e.id,
        orderId: order.id,
        productId: e.productId,
        productName: e.product.name,
        unitPrice: e.unitPrice,
        quantity: e.quantity,
        subtotal: e.subtotal,
      )).toList(),
      status: order.status.value,
      subtotal: order.subtotal,
      tax: order.tax,
      shippingCost: order.shippingCost,
      total: order.total,
      notes: order.notes,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      lastSyncedAt: order.lastSyncedAt,
      isSynced: order.isSynced,
    );
  }
}
