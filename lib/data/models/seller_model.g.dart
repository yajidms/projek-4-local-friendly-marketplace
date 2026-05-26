part of 'seller_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerModel _$SellerModelFromJson(Map<String, dynamic> json) => SellerModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      shopName: json['shopName'] as String,
      shopDescription: json['shopDescription'] as String?,
      shopImageUrl: json['shopImageUrl'] as String?,
      shopAddress: json['shopAddress'] as String?,
      shopPhone: json['shopPhone'] as String?,
      location: json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? true,
    );

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
