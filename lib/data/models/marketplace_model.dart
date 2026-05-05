import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/index.dart';

part 'marketplace_model.g.dart';

@JsonSerializable()
class MarketPlaceModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  final bool isSynced;

  MarketPlaceModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
    this.isSynced = true,
  });

  /// Convert model to domain entity
  MarketPlace toEntity() {
    return MarketPlace(
      id: id,
      name: name,
      description: description,
      logoUrl: logoUrl,
      websiteUrl: websiteUrl,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      address: address,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncedAt: lastSyncedAt,
      isSynced: isSynced,
    );
  }

  /// Create model from domain entity
  factory MarketPlaceModel.fromEntity(MarketPlace marketplace) {
    return MarketPlaceModel(
      id: marketplace.id,
      name: marketplace.name,
      description: marketplace.description,
      logoUrl: marketplace.logoUrl,
      websiteUrl: marketplace.websiteUrl,
      contactEmail: marketplace.contactEmail,
      contactPhone: marketplace.contactPhone,
      address: marketplace.address,
      isActive: marketplace.isActive,
      createdAt: marketplace.createdAt,
      updatedAt: marketplace.updatedAt,
      lastSyncedAt: marketplace.lastSyncedAt,
      isSynced: marketplace.isSynced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketPlaceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory MarketPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$MarketPlaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketPlaceModelToJson(this);
}
