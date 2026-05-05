// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketPlaceModel _$MarketPlaceModelFromJson(Map<String, dynamic> json) =>
    MarketPlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? true,
    );

Map<String, dynamic> _$MarketPlaceModelToJson(MarketPlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'websiteUrl': instance.websiteUrl,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'address': instance.address,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
      'isSynced': instance.isSynced,
    };
