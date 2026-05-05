import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';
import 'location_model.dart';

part 'recommended_store_model.g.dart';

@JsonSerializable()
class RecommendedStoreModel {
  final String id;
  final String sellerId;
  final String shopName;
  final String? shopImageUrl;
  final double distance;
  final double rating;
  final int totalReviews;
  final LocationModel location;
  final List<String> categories;
  final bool isOnline;
  final int availableProducts;
  final DateTime recommendedAt;
  final DateTime cachedAt;
  final bool isCached;

  RecommendedStoreModel({
    required this.id,
    required this.sellerId,
    required this.shopName,
    this.shopImageUrl,
    required this.distance,
    required this.rating,
    required this.totalReviews,
    required this.location,
    required this.categories,
    this.isOnline = false,
    this.availableProducts = 0,
    required this.recommendedAt,
    required this.cachedAt,
    this.isCached = false,
  });

  /// Convert model to domain entity
  RecommendedStore toEntity() {
    return RecommendedStore(
      id: id,
      sellerId: sellerId,
      shopName: shopName,
      shopImageUrl: shopImageUrl,
      distance: distance,
      rating: rating,
      totalReviews: totalReviews,
      location: location.toEntity(),
      categories: categories,
      isOnline: isOnline,
      availableProducts: availableProducts,
      recommendedAt: recommendedAt,
      cachedAt: cachedAt,
      isCached: isCached,
    );
  }

  /// Create model from domain entity
  factory RecommendedStoreModel.fromEntity(RecommendedStore store) {
    return RecommendedStoreModel(
      id: store.id,
      sellerId: store.sellerId,
      shopName: store.shopName,
      shopImageUrl: store.shopImageUrl,
      distance: store.distance,
      rating: store.rating,
      totalReviews: store.totalReviews,
      location: LocationModel.fromEntity(store.location),
      categories: store.categories,
      isOnline: store.isOnline,
      availableProducts: store.availableProducts,
      recommendedAt: store.recommendedAt,
      cachedAt: store.cachedAt,
      isCached: store.isCached,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendedStoreModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$RecommendedStoreModelToJson(this);

  /// Create model from JSON
  factory RecommendedStoreModel.fromJson(Map<String, dynamic> json) =>
      _$RecommendedStoreModelFromJson(json);
}
