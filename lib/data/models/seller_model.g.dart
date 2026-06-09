// MODIFIED — DO NOT REGENERATE (custom JSON handling for API compatibility)

part of 'seller_model.dart';

// **************************************************************************
// JsonSerializableGenerator (hand-patched for API compatibility)
// **************************************************************************

SellerModel _$SellerModelFromJson(Map<String, dynamic> json) {
  T? _field<T>(String camel, String snake) =>
      (json[camel] ?? json[snake]) as T?;

  return SellerModel(
    id: (json['id'] as String?) ?? '',
    userId: (_field<String>('userId', 'user_id')) ?? '',
    shopName: (_field<String>('shopName', 'shop_name')) ?? '',
    shopDescription: _field<String>('shopDescription', 'shop_description'),
    shopImageUrl: _field<String>('shopImageUrl', 'shop_image_url'),
    shopAddress: _field<String>('shopAddress', 'shop_address'),
    shopPhone: _field<String>('shopPhone', 'shop_phone'),
    location: json['location'] == null
        ? null
        : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
    categories: (json['categories'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    rating: ((_field<num>('rating', 'rating'))?.toDouble()) ?? 0.0,
    totalReviews: ((_field<num>('totalReviews', 'total_reviews'))?.toInt()) ?? 0,
    totalProducts: ((_field<num>('totalProducts', 'total_products'))?.toInt()) ?? 0,
    isVerified: (_field<bool>('isVerified', 'is_verified')) ?? false,
    isActive: (_field<bool>('isActive', 'is_active')) ?? true,
    isOnline: (_field<bool>('isOnline', 'is_online')) ?? false,
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

Map<String, dynamic> _$SellerModelToJson(SellerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'shopName': instance.shopName,
      'shopDescription': instance.shopDescription,
      'shopImageUrl': instance.shopImageUrl,
      'shopAddress': instance.shopAddress,
      'shopPhone': instance.shopPhone,
      'location': instance.location,
      'categories': instance.categories,
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'totalProducts': instance.totalProducts,
      'isVerified': instance.isVerified,
      'isActive': instance.isActive,
      'isOnline': instance.isOnline,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
    };
