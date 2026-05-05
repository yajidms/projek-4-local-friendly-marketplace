import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';

part 'store_category_model.g.dart';

@JsonSerializable()
class StoreCategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final int productCount;
  final DateTime createdAt;

  StoreCategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.productCount = 0,
    required this.createdAt,
  });

  /// Convert model to domain entity
  StoreCategory toEntity() {
    return StoreCategory(
      id: id,
      name: name,
      icon: icon,
      description: description,
      productCount: productCount,
      createdAt: createdAt,
    );
  }

  /// Create model from domain entity
  factory StoreCategoryModel.fromEntity(StoreCategory category) {
    return StoreCategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      description: category.description,
      productCount: category.productCount,
      createdAt: category.createdAt,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$StoreCategoryModelToJson(this);

  /// Create model from JSON
  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoreCategoryModelFromJson(json);
}
