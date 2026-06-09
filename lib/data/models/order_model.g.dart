// MODIFIED — DO NOT REGENERATE (custom JSON handling for API compatibility)

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator (hand-patched for API compatibility)
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) {
  T? _field<T>(String camel, String snake) =>
      (json[camel] ?? json[snake]) as T?;

  // Items might be empty if endpoint doesn't return them
  final rawItems = json['items'] as List<dynamic>? ?? [];

  return OrderModel(
    id: (json['id'] as String?) ?? '',
    userId: (_field<String>('userId', 'user_id')) ?? '',
    sellerId: _field<String>('sellerId', 'seller_id'),
    marketplaceId: _field<String>('marketplaceId', 'marketplace_id'),
    items: rawItems
        .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: (json['status'] as String?) ?? 'pending',
    subtotal: ((_field<num>('subtotal', 'subtotal'))?.toDouble()) ?? 0.0,
    tax: ((_field<num>('tax', 'tax'))?.toDouble()) ?? 0.0,
    shippingCost:
        ((_field<num>('shippingCost', 'shipping_cost'))?.toDouble()) ?? 0.0,
    total: ((_field<num>('total', 'total'))?.toDouble()) ?? 0.0,
    notes: _field<String>('notes', 'notes'),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : (json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now()),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : (json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now()),
    lastSyncedAt: json['lastSyncedAt'] == null
        ? null
        : DateTime.parse(json['lastSyncedAt'] as String),
    isSynced: (json['isSynced'] as bool?) ?? true,
  );
}

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sellerId': instance.sellerId,
      'marketplaceId': instance.marketplaceId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'status': instance.status,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'shippingCost': instance.shippingCost,
      'total': instance.total,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
