// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommended_store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendedStoreModel _$RecommendedStoreModelFromJson(
        Map<String, dynamic> json) =>
    RecommendedStoreModel(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      shopName: json['shopName'] as String,
      shopImageUrl: json['shopImageUrl'] as String?,
      distance: (json['distance'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      location:
          LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isOnline: json['isOnline'] as bool? ?? false,
      availableProducts: (json['availableProducts'] as num?)?.toInt() ?? 0,
      recommendedAt: DateTime.parse(json['recommendedAt'] as String),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      isCached: json['isCached'] as bool? ?? false,
    );

Map<String, dynamic> _$RecommendedStoreModelToJson(
        RecommendedStoreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sellerId': instance.sellerId,
      'shopName': instance.shopName,
      'shopImageUrl': instance.shopImageUrl,
      'distance': instance.distance,
      'rating': instance.rating,
      'totalReviews': instance.totalReviews,
      'location': instance.location,
      'categories': instance.categories,
      'isOnline': instance.isOnline,
      'availableProducts': instance.availableProducts,
      'recommendedAt': instance.recommendedAt.toIso8601String(),
      'cachedAt': instance.cachedAt.toIso8601String(),
      'isCached': instance.isCached,
    };
