import 'dart:async';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koji/services/location_service.dart';
import 'package:koji/services/socket_services.dart';
import 'package:koji/helpers/prefs_helper.dart';

class EmployeeLocationController extends GetxController {
  final LocationService _locationService = LocationService();

  final RxBool isTrackingActive = false.obs;
  RxString currentAddressName = ''.obs;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _periodicTimer;
  String? _myUserId;

  // ─── Periodic emit every 5s (home screen) ───────────────────────────────

  /// Start emitting location every 5 seconds — call on home screen load
  Future<void> startPeriodicEmit() async {
    _myUserId = await PrefsHelper.getString('userId');
    print('🚀 [Location] startPeriodicEmit called | userId=$_myUserId');
    _subscribeToOwnLocation();

    // Emit immediately, then every 5 seconds
    await _emitCurrentPosition();
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      print('⏱️ [Location] Timer tick — emitting location...');
      _emitCurrentPosition();
    });
    print('✅ [Location] Periodic timer started');
  }

  /// Stop periodic emit — call on home screen dispose
  void stopPeriodicEmit() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    print('🛑 [Location] Periodic emit stopped');
  }

  Future<void> _emitCurrentPosition() async {
    try {
      print('📡 [Location] Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('📍 [Location] Got position: lat=${position.latitude}, lng=${position.longitude}');
      await _onPositionUpdate(position);
    } catch (e) {
      print('❌ [Location] _emitCurrentPosition error: $e');
    }
  }

  // ─── Continuous tracking (check-in) ─────────────────────────────────────

  /// Start GPS stream tracking — call this on check-in
  Future<void> startLocationTracking() async {
    if (isTrackingActive.value) return;

    _myUserId ??= await PrefsHelper.getString('userId');
    _subscribeToOwnLocation();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) => _onPositionUpdate(position));

    isTrackingActive.value = true;

    // Send initial position immediately
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _onPositionUpdate(position);
    } catch (_) {}
  }

  /// Stop GPS stream — call on check-out
  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    isTrackingActive.value = false;

    if (_myUserId != null && _myUserId!.isNotEmpty) {
      SocketServices().socket.off('location::$_myUserId');
    }
  }

  // ─── Shared helpers ──────────────────────────────────────────────────────

  /// Listen to location::{userId} — server broadcasts our location back
  void _subscribeToOwnLocation() {
    if (_myUserId == null || _myUserId!.isEmpty) return;
    SocketServices().socket.off('location::$_myUserId'); // avoid duplicates
    SocketServices().socket.on('location::$_myUserId', (data) {
      if (data is Map<String, dynamic>) {
        final name = data['locationName'];
        if (name != null && name.toString().isNotEmpty) {
          currentAddressName.value = name.toString();
        }
      }
    });
  }

  Future<void> _onPositionUpdate(Position position) async {
    final locationName = await _getAddressName(
      position.latitude,
      position.longitude,
    );
    currentAddressName.value = locationName;

    print('📤 [Location] Emitting location-update → lat=${position.latitude}, lng=${position.longitude}, name=$locationName');
    await _locationService.sendLocationUpdate(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: locationName,
    );
    print('✅ [Location] Emit done');
  }

  Future<String> _getAddressName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        String address = '';
        if (place.street?.isNotEmpty == true) address += place.street!;
        if (place.subLocality?.isNotEmpty == true) {
          address += address.isEmpty ? place.subLocality! : ', ${place.subLocality}';
        }
        if (place.locality?.isNotEmpty == true) {
          address += address.isEmpty ? place.locality! : ', ${place.locality}';
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          address += address.isEmpty ? place.administrativeArea! : ', ${place.administrativeArea}';
        }
        if (place.country?.isNotEmpty == true) {
          address += address.isEmpty ? place.country! : ', ${place.country}';
        }
        return address.isNotEmpty ? address : 'Unknown location';
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
  }

  @override
  void onClose() {
    stopPeriodicEmit();
    stopLocationTracking();
    super.onClose();
  }
}
