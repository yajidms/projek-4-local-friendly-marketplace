class StoreCategory {
  final String id;
  final String name;
  final String? icon; // Icon URL or asset path
  final String? description;
  final int productCount; // Number of products in this category
  final DateTime createdAt;

  StoreCategory({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.productCount = 0,
    required this.createdAt,
  });

  StoreCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    int? productCount,
    DateTime? createdAt,
  }) {
    return StoreCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
