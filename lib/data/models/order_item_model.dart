import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/order_item.dart';
import '../../domain/entities/product.dart';

part 'order_item_model.g.dart';

@JsonSerializable()
class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productName = '',
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItem toEntity() => OrderItem(
    id: id,
    orderId: orderId,
    productId: productId,
    product: Product(
      id: productId,
      sellerId: '',
      name: productName,
      description: '',
      price: unitPrice,
      quantity: quantity,
      category: '',
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    quantity: quantity,
    unitPrice: unitPrice,
    subtotal: subtotal,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? subtotal,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
