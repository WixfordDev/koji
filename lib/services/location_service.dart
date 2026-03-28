import 'package:koji/services/socket_services.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Send location update to server via Socket.IO
  Future<void> sendLocationUpdate({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      SocketServices().socket.emit('location-update', {
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
      });
    } catch (e) {
      print("Error sending location update: $e");
    }
  }
}
