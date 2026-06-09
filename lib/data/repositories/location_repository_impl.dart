import 'package:geolocator/geolocator.dart';

import '../../domain/entities/index.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/local/location_local_datasource.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl extends LocationRepository {
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Location> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final cached = await localDataSource.getCachedLocation();
        if (cached != null) return cached.toEntity();
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        final cached = await localDataSource.getCachedLocation();
        if (cached != null) return cached.toEntity();
        throw Exception('Location permissions are permanently denied');
      }
      if (permission == LocationPermission.denied) {
        final cached = await localDataSource.getCachedLocation();
        if (cached != null) return cached.toEntity();
        throw Exception('Location permissions are denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      final location = Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await cacheLocation(location);
      return location;
    } catch (e) {
      final cached = await localDataSource.getCachedLocation();
      if (cached != null) return cached.toEntity();
      throw Exception('Failed to get current location: $e');
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLocationPermissionGranted() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Location?> getCachedLocation() async {
    try {
      final cached = await localDataSource.getCachedLocation();
      return cached?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheLocation(Location location) async {
    try {
      final model = LocationModel.fromEntity(location);
      await localDataSource.cacheLocation(model);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<Location?> getLocationFromAddress(String address) async {
    try {
      // Use geocoding to convert address to coordinates
      // Requires geocoding package - stub for now
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getAddressFromLocation(Location location) async {
    try {
      // Use reverse geocoding to convert coordinates to address
      // Requires geocoding package - stub for now
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  double calculateDistance(Location from, Location to) {
    return from.distanceTo(to);
  }

  @override
  Future<void> trackSellerLocation(String sellerId, Location location) async {
    try {
      final model = LocationModel.fromEntity(location);
      await localDataSource.saveSellerLocation(sellerId, model);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<List<Location>> getSellerLocationHistory(String sellerId) async {
    try {
      final history = await localDataSource.getSellerLocationHistory(sellerId);
      return history
          .whereType<LocationModel>()
          .map((location) => location.toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> startLocationUpdates({
    required Function(Location) onLocationUpdate,
    double? distanceFilter,
  }) async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }

      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter != null ? distanceFilter.toInt() : 100,
        ),
      ).listen((position) {
        final location = Location(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        onLocationUpdate(location);
        cacheLocation(location);
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> stopLocationUpdates() async {
    // Geolocator stream subscription needs to be cancelled by caller
    // This is a stub - caller should cancel their subscription
  }
}
