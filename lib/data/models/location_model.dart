import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/index.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country,
  });

  /// Convert model to domain entity
  Location toEntity() {
    return Location(
      latitude: latitude,
      longitude: longitude,
      address: address,
      city: city,
      province: province,
      postalCode: postalCode,
      country: country,
    );
  }

  /// Create model from domain entity
  factory LocationModel.fromEntity(Location location) {
    return LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      city: location.city,
      province: location.province,
      postalCode: location.postalCode,
      country: location.country,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);

  /// Create model from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
