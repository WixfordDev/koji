import 'package:get/get.dart';
import 'package:koji/services/location_service.dart';
import 'package:koji/services/socket_services.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koji/services/location_service.dart';

class EmployeeLocationController extends GetxController {
  final LocationService _locationService = LocationService();

  final RxBool _isTrackingActive = false.obs;
  final RxString _lastLocationUpdate = ''.obs;
  RxString currentAddressName = ''.obs;

  RxBool get isTrackingActive => _isTrackingActive;
  String get lastLocationUpdate => _lastLocationUpdate.value;

  @override
  void onInit() {
    super.onInit();
    // Initialize location service when the controller is initialized
    _initializeLocationTracking();
  }

  /// Initialize location tracking for the employee
  Future<void> _initializeLocationTracking() async {
    try {
      await _locationService.initializeLocationUpdates();
      _isTrackingActive.value = true;
      _lastLocationUpdate.value = "Location tracking started";
    } catch (e) {
      _isTrackingActive.value = false;
      _lastLocationUpdate.value = "Error starting location tracking: $e";
    }
  }

  /// Get address name from coordinates using reverse geocoding
  Future<void> _updateAddressName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Format the address - customize based on your needs
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += address.isEmpty
              ? place.subLocality!
              : ', ${place.subLocality}';
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }

        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += address.isEmpty
              ? place.administrativeArea!
              : ', ${place.administrativeArea}';
        }

        if (place.country != null && place.country!.isNotEmpty) {
          address += address.isEmpty ? place.country! : ', ${place.country}';
        }

        currentAddressName.value = address.isNotEmpty
            ? address
            : 'Unknown location';
        print("Address updated: $address");
      } else {
        currentAddressName.value = 'Address not found';
      }
    } catch (e) {
      print("Error getting address: $e");
      currentAddressName.value = 'Error getting address';
    }
  }

  /// Manually start location tracking
  Future<void> startLocationTracking() async {
    try {
      await _locationService.initializeLocationUpdates();
      _isTrackingActive.value = true;
      _lastLocationUpdate.value = "Location tracking started";
      print("Location tracking started for employee");
    } catch (e) {
      _isTrackingActive.value = false;
      _lastLocationUpdate.value = "Error starting location tracking: $e";
      print("Error starting location tracking: $e");
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _locationService.stopLocationUpdates();
    _isTrackingActive.value = false;
    _lastLocationUpdate.value = "Location tracking stopped";
  }

  /// Get the last known position coordinates
  String getLastKnownLocation() {
    final position = _locationService.lastKnownPosition;
    if (position != null) {
      return "Lat: ${position.latitude}, Lng: ${position.longitude}";
    }
    return "No location data available";
  }

  @override
  void onClose() {
    // Stop location updates when the controller is disposed
    if (_isTrackingActive.value) {
      stopLocationTracking();
    }
    super.onClose();
  }
}
