import 'location.dart';
class RecommendedStore {
  final String id;
  final String sellerId; // Reference to Seller
  final String shopName;
  final String? shopImageUrl;
  final double distance; // Distance in km from buyer's location
  final double rating;
  final int totalReviews;
  final Location location;
  final List<String> categories; // Product categories available
  final bool isOnline; // Is seller currently online
  final int availableProducts; // Number of available products
  final DateTime recommendedAt; // When this recommendation was generated
  final DateTime cachedAt; // For offline cache management
  final bool isCached; // Is this a cached recommendation

  RecommendedStore({
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

  /// Check if recommendation is still fresh (cache validation)
  bool get isFresh {
    final now = DateTime.now();
    final difference = now.difference(cachedAt).inHours;
    return difference < 24; // Consider cache fresh if less than 24 hours
  }

  /// Get distance as formatted string
  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  /// Get rating as formatted string
  String get ratingString => rating.toStringAsFixed(1);

  /// Check if store has a specific category
  bool hasCategory(String category) =>
      categories.contains(category.toLowerCase());

  /// Get shop status string
  String get statusString {
    if (!isOnline) return 'Offline';
    if (availableProducts == 0) return 'Produk Habis';
    return 'Online';
  }

  RecommendedStore copyWith({
    String? id,
    String? sellerId,
    String? shopName,
    String? shopImageUrl,
    double? distance,
    double? rating,
    int? totalReviews,
    Location? location,
    List<String>? categories,
    bool? isOnline,
    int? availableProducts,
    DateTime? recommendedAt,
    DateTime? cachedAt,
    bool? isCached,
  }) {
    return RecommendedStore(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      shopName: shopName ?? this.shopName,
      shopImageUrl: shopImageUrl ?? this.shopImageUrl,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      location: location ?? this.location,
      categories: categories ?? this.categories,
      isOnline: isOnline ?? this.isOnline,
      availableProducts: availableProducts ?? this.availableProducts,
      recommendedAt: recommendedAt ?? this.recommendedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      isCached: isCached ?? this.isCached,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendedStore &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sellerId == other.sellerId;

  @override
  int get hashCode => id.hashCode ^ sellerId.hashCode;
}
