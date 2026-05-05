import 'location.dart';

class Seller {
  final String id;
  final String userId; // Reference to User entity
  final String shopName;
  final String? shopDescription;
  final String? shopImageUrl;
  final String? shopAddress;
  final String? shopPhone;
  final Location?
      location; // GPS coordinates for location-based recommendations
  final List<String> categories; // Product categories this seller offers
  final double rating; // Average rating (0-5)
  final int totalReviews;
  final int totalProducts;
  final bool isVerified;
  final bool isActive;
  final bool isOnline; // Current online status
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt; // For offline sync tracking
  final bool isSynced; // Indicates if changes are synced to MongoDB

  Seller({
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

  /// Check if seller's inventory is up-to-date with server
  bool get isInventorySynced => isSynced;

  /// Get seller's rating as a formatted string
  String get ratingString => rating.toStringAsFixed(1);

  /// Create a copy with modified fields
  Seller copyWith({
    String? id,
    String? userId,
    String? shopName,
    String? shopDescription,
    String? shopImageUrl,
    String? shopAddress,
    String? shopPhone,
    Location? location,
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
    return Seller(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Seller &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
