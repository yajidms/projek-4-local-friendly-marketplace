import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String category;
  final List<String>? images;
  final String? sku;
  final double? weight;
  final String? unit;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isSynced;
  final bool isLocalOnly;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
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

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? description,
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
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
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

  /// Convert model to domain entity
  Product toEntity() {
    return Product(
      id: id,
      sellerId: sellerId,
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      category: category,
      images: images,
      sku: sku,
      weight: weight,
      unit: unit,
      isAvailable: isAvailable,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: lastSyncedAt,
      isSynced: isSynced,
      isLocalOnly: isLocalOnly,
    );
  }

  /// Create model from domain entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      sellerId: product.sellerId,
      name: product.name,
      description: product.description,
      price: product.price,
      quantity: product.quantity,
      category: product.category,
      images: product.images,
      sku: product.sku,
      weight: product.weight,
      unit: product.unit,
      isAvailable: product.isAvailable,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      lastSyncedAt: product.lastSyncedAt,
      isSynced: product.isSynced,
      isLocalOnly: product.isLocalOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  /// Create model from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
