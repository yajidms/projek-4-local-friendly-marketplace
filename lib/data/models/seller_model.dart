import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';
import 'location_model.dart';

part 'seller_model.g.dart';

@JsonSerializable()
class SellerModel {
  final String id;
  final String userId;
  final String shopName;
  final String? shopDescription;
  final String? shopImageUrl;
  final String? shopAddress;
  final String? shopPhone;
  final LocationModel? location;
  final List<String> categories;
  final double rating;
  final int totalReviews;
  final int totalProducts;
  final bool isVerified;
  final bool isActive;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isSynced;

  SellerModel({
    required this.id,
    required this.userId,
    required this.shopName,
    this.shopDescription,
    this.shopImageUrl,
    this.shopAddress,
    this.shopPhone,
    this.location,
    this.categories = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalProducts = 0,
    this.isVerified = false,
    this.isActive = true,
    this.isOnline = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isSynced = true,
  });

  SellerModel copyWith({
    String? id,
    String? userId,
    String? shopName,
    String? shopDescription,
    String? shopImageUrl,
    String? shopAddress,
    String? shopPhone,
    LocationModel? location,
    List<String>? categories,
    double? rating,
    int? totalReviews,
    int? totalProducts,
    bool? isVerified,
    bool? isActive,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isSynced,
  }) {
    return SellerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
      shopImageUrl: shopImageUrl ?? this.shopImageUrl,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      location: location ?? this.location,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalProducts: totalProducts ?? this.totalProducts,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Convert model to domain entity
  Seller toEntity() {
    return Seller(
      id: id,
      userId: userId,
      shopName: shopName,
      shopDescription: shopDescription,
      shopImageUrl: shopImageUrl,
      shopAddress: shopAddress,
      shopPhone: shopPhone,
      location: location?.toEntity(),
      categories: categories,
      rating: rating,
      totalReviews: totalReviews,
      totalProducts: totalProducts,
      isVerified: isVerified,
      isActive: isActive,
      isOnline: isOnline,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: lastSyncedAt,
      isSynced: isSynced,
    );
  }

  /// Create model from domain entity
  factory SellerModel.fromEntity(Seller seller) {
    return SellerModel(
      id: seller.id,
      userId: seller.userId,
      shopName: seller.shopName,
      shopDescription: seller.shopDescription,
      shopImageUrl: seller.shopImageUrl,
      shopAddress: seller.shopAddress,
      shopPhone: seller.shopPhone,
      location: seller.location != null
          ? LocationModel.fromEntity(seller.location!)
          : null,
      categories: seller.categories,
      rating: seller.rating,
      totalReviews: seller.totalReviews,
      totalProducts: seller.totalProducts,
      isVerified: seller.isVerified,
      isActive: seller.isActive,
      isOnline: seller.isOnline,
      createdAt: seller.createdAt,
      updatedAt: seller.updatedAt,
      lastSyncedAt: seller.lastSyncedAt,
      isSynced: seller.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$SellerModelToJson(this);

  /// Create model from JSON
  factory SellerModel.fromJson(Map<String, dynamic> json) =>
      _$SellerModelFromJson(json);
}
