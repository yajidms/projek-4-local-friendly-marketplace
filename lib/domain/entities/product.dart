class Product {
  final String id;
  final String sellerId; // Reference to Seller
  final String name;
  final String description;
  final String? specifications; // Spesifikasi / bahan produk (opsional)
  final double price;
  final int quantity; // Current stock
  final String category;
  final List<String>? images; // URL list for online, local paths for offline
  final String? sku;
  final double? weight;
  final String? unit;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt; // For offline sync tracking
  final bool isSynced; // Indicates if changes are synced to MongoDB
  final bool isLocalOnly; // Temporary product created offline

  Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    this.specifications,
    required this.price,
    required this.quantity,
    required this.category,
    this.images,
    this.sku,
    this.weight,
    this.unit,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isSynced = true,
    this.isLocalOnly = false,
  });

  /// Check if product inventory needs to be updated on server
  bool get needsSync => !isSynced || isLocalOnly;

  /// Get product availability status
  bool get inStock => isAvailable && quantity > 0;

  /// Get stock status message
  String get stockStatus {
    if (!isAvailable) return 'Tidak Tersedia';
    if (quantity <= 0) return 'Stok Habis';
    if (quantity < 5) return 'Stok Terbatas';
    return 'Stok Tersedia';
  }

  /// Create a copy with modified fields
  Product copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? description,
    Object? specifications = _sentinel,
    double? price,
    int? quantity,
    String? category,
    List<String>? images,
    String? sku,
    double? weight,
    String? unit,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? isSynced,
    bool? isLocalOnly,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      specifications: specifications == _sentinel
          ? this.specifications
          : specifications as String?,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      images: images ?? this.images,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isSynced: isSynced ?? this.isSynced,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sellerId == other.sellerId;

  @override
  int get hashCode => id.hashCode ^ sellerId.hashCode;
}

/// Sentinel untuk membedakan "tidak diberikan" vs "null" pada copyWith
const Object _sentinel = Object();
