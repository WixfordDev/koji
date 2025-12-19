import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:koji/services/socket_services.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/core/app_constants.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  bool _isActive = false;
  Position? _lastKnownPosition;

  /// Initialize location updates and connect to socket
  Future<void> initializeLocationUpdates() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Initialize socket connection
    await _initializeSocketConnection();

    // Start location updates
    _startLocationUpdates();

    _isActive = true;
  }

  /// Initialize socket connection
  Future<void> _initializeSocketConnection() async {
    final token = await PrefsHelper.getString(AppConstants.bearerToken);
    final userId = await PrefsHelper.getString(AppConstants.userId);
    final fcmToken = await PrefsHelper.getString(AppConstants.fcmToken);

    await SocketServices().init(userId: userId, fcmToken: fcmToken);
  }

  Timer? _locationUpdateTimer;

  /// Start listening to location updates
  void _startLocationUpdates() {
    // Update location every 10 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _getCurrentLocationAndSend();
    });
  }

  /// Get current location and send update
  Future<void> _getCurrentLocationAndSend() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastKnownPosition = position;
      _sendLocationUpdate(position);
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  /// Send location update to server via socket
  void _sendLocationUpdate(Position position) {
    final locationData = {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "locationName": _getLocationName(position),
    };

    // Print location data for debugging
    print("Sending location update: $locationData");

    // Emit location update via socket
    SocketServices().emit("location-update", locationData);
  }

  /// Get a human-readable location name
  String _getLocationName(Position position) {
    // This is a simplified version - in production, you might want to use
    // a reverse geocoding service to get the actual address
    return "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
  }

  /// Stop location updates
  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _isActive = false;
  }

  /// Check if location updates are currently active
  bool get isActive => _isActive;

  /// Get the last known position
  Position? get lastKnownPosition => _lastKnownPosition;
}
