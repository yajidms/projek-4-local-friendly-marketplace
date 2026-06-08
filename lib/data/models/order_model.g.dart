// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sellerId: json['sellerId'] as String?,
      marketplaceId: json['marketplaceId'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? true,
    );

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
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
    };
