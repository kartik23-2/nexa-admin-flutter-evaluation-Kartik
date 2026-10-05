import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/branch_model.dart';

class GeofenceVerificationResult {
  final bool isInside;
  final double distanceMeters;
  final double radiusMeters;
  final double deltaMeters; // Difference (positive = outside, negative = inside)
  final String status; // 'Present' or 'Rejected'
  final String message;

  const GeofenceVerificationResult({
    required this.isInside,
    required this.distanceMeters,
    required this.radiusMeters,
    required this.deltaMeters,
    required this.status,
    required this.message,
  });
}

class GeofenceService {
  /// Check GPS status and ensure device location is active
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request and check location permissions
  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Fetch high-accuracy current GPS position with robust error handling
  Future<Position> getCurrentPosition() async {
    final bool serviceEnabled = await isGpsEnabled();
    if (!serviceEnabled) {
      throw 'Device GPS is disabled. Please turn on location services in your system settings.';
    }

    final permission = await checkAndRequestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permission was denied. Permission is required to verify attendance.';
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is permanently denied. Please grant permission in app settings.';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// Distance calculation engine comparing employee position with branch coordinates
  double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Core Geofence Verification Logic
  GeofenceVerificationResult verifyGeofence({
    required double userLat,
    required double userLng,
    required BranchModel branch,
  }) {
    final distance = calculateDistanceMeters(
      startLatitude: userLat,
      startLongitude: userLng,
      endLatitude: branch.latitude,
      endLongitude: branch.longitude,
    );

    final isInside = distance <= branch.radius;
    final delta = distance - branch.radius;

    if (isInside) {
      return GeofenceVerificationResult(
        isInside: true,
        distanceMeters: distance,
        radiusMeters: branch.radius,
        deltaMeters: delta,
        status: 'Present',
        message: 'Verified inside "${branch.name}" perimeter (${distance.toStringAsFixed(1)}m from center, radius is ${branch.radius.toInt()}m).',
      );
    } else {
      return GeofenceVerificationResult(
        isInside: false,
        distanceMeters: distance,
        radiusMeters: branch.radius,
        deltaMeters: delta,
        status: 'Rejected',
        message: 'Outside geofence: ${distance.toStringAsFixed(1)}m away from "${branch.name}". Exceeds boundary by ${delta.toStringAsFixed(1)}m.',
      );
    }
  }
}
