// MODIFIED — DO NOT REGENERATE (custom JSON handling for API compatibility)
// The API may return either camelCase or snake_case field names depending on the
// backend ORM configuration. This file adds safe fallbacks for both conventions.

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator (hand-patched for API compatibility)
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  // Helper: read a field with camelCase primary and snake_case fallback
  T? _field<T>(String camel, String snake) =>
      (json[camel] ?? json[snake]) as T?;

  return ProductModel(
    id: (json['id'] as String?) ?? '',
    sellerId: (_field<String>('sellerId', 'seller_id')) ?? '',
    name: (json['name'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    price: ((_field<num>('price', 'price'))?.toDouble()) ?? 0.0,
    quantity: ((_field<num>('quantity', 'quantity'))?.toInt()) ?? 0,
    category: (json['category'] as String?) ?? '',
    images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    sku: _field<String>('sku', 'sku'),
    weight: (_field<num>('weight', 'weight'))?.toDouble(),
    unit: _field<String>('unit', 'unit'),
    isAvailable: (_field<bool>('isAvailable', 'is_available')) ?? true,
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
    isLocalOnly: (json['isLocalOnly'] as bool?) ?? false,
  );
}

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sellerId': instance.sellerId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'quantity': instance.quantity,
      'category': instance.category,
      'images': instance.images,
      'sku': instance.sku,
      'weight': instance.weight,
      'unit': instance.unit,
      'isAvailable': instance.isAvailable,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
      'isLocalOnly': instance.isLocalOnly,
    };
