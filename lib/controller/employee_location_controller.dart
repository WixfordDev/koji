import 'dart:async';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koji/services/location_service.dart';

class EmployeeLocationController extends GetxController {
  final LocationService _locationService = LocationService();

  final RxBool isTrackingActive = false.obs;
  RxString currentAddressName = ''.obs;

  StreamSubscription<Position>? _positionSubscription;
  Position? _lastSentPosition;

  // Update when moved at least 10 meters (~0.0001 degree)
  static const double _distanceThresholdMeters = 10.0;

  /// Start location tracking — call this on check-in
  Future<void> startLocationTracking() async {
    if (isTrackingActive.value) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Only fires when device moves ≥10 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) => _onPositionUpdate(position));

    isTrackingActive.value = true;

    // Send initial position immediately after check-in
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _onPositionUpdate(position);
    } catch (_) {}
  }

  /// Called on every position update from the stream
  Future<void> _onPositionUpdate(Position position) async {
    if (_lastSentPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastSentPosition!.latitude,
        _lastSentPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      if (distance < _distanceThresholdMeters) return;
    }

    _lastSentPosition = position;

    final locationName = await _getAddressName(
      position.latitude,
      position.longitude,
    );
    currentAddressName.value = locationName;

    await _locationService.sendLocationUpdate(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: locationName,
    );
  }

  Future<String> _getAddressName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        String address = '';

        if (place.street?.isNotEmpty == true) address += place.street!;
        if (place.subLocality?.isNotEmpty == true) {
          address +=
              address.isEmpty ? place.subLocality! : ', ${place.subLocality}';
        }
        if (place.locality?.isNotEmpty == true) {
          address +=
              address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          address += address.isEmpty
              ? place.administrativeArea!
              : ', ${place.administrativeArea}';
        }
        if (place.country?.isNotEmpty == true) {
          address +=
              address.isEmpty ? place.country! : ', ${place.country}';
        }

        return address.isNotEmpty ? address : 'Unknown location';
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
  }

  /// Stop location tracking — call this on check-out
  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastSentPosition = null;
    isTrackingActive.value = false;
  }

  @override
  void onClose() {
    stopLocationTracking();
    super.onClose();
  }
}
