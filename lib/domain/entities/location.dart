import 'dart:math' as m;

class Location {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;

  Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country,
  });

  /// Calculate distance to another location using Haversine formula (in kilometers)
  double distanceTo(Location other) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(other.latitude - latitude);
    final dLon = _degreesToRadians(other.longitude - longitude);

    final a = (m.sin(dLat / 2) * m.sin(dLat / 2)) +
        m.cos(_degreesToRadians(latitude)) *
            m.cos(_degreesToRadians(other.latitude)) *
            (m.sin(dLon / 2) * m.sin(dLon / 2));

    final c = 2 * m.atan2(m.sqrt(a), m.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Get formatted distance string
  String getFormattedDistance(Location other) {
    final distance = distanceTo(other);
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  /// Get full address string
  String get fullAddress {
    final parts = [address, city, province, postalCode, country]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  Location copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? country,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
