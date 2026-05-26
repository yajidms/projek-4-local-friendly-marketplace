part of 'store_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreCategoryModel _$StoreCategoryModelFromJson(Map<String, dynamic> json) =>
    StoreCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StoreCategoryModelToJson(StoreCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'description': instance.description,
      'productCount': instance.productCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };
