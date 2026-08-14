import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionResult { granted, denied, deniedForever, serviceDisabled }

/// Thin wrapper around geolocator/geocoding so the rest of the app never
/// talks to the plugins directly — makes it easy to swap providers later.
class LocationService {
  Future<LocationPermissionResult> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionResult.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionResult.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionResult.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionResult.denied;
    }
  }

  /// Resolves the device's current position into a human-readable
  /// approximate area (e.g. "Accra, Ghana") — never raw coordinates, and
  /// never stored more precisely than city-level. Returns null if the
  /// position or reverse-geocoding lookup fails.
  Future<String?> getApproximateArea() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final locality = place.locality?.isNotEmpty == true ? place.locality : place.subAdministrativeArea;
      final region = place.administrativeArea?.isNotEmpty == true ? place.administrativeArea : place.country;

      final parts = [locality, region].whereType<String>().where((s) => s.isNotEmpty).toList();
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
