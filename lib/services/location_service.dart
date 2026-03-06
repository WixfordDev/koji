import 'package:koji/services/api_client.dart';
import 'package:koji/services/api_constants.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Send location update to server via REST API
  Future<void> sendLocationUpdate({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      await ApiClient.postData(
        ApiConstants.locationUpdateEndPoint,
        {
          "latitude": latitude,
          "longitude": longitude,
          "locationName": locationName,
        },
      );
    } catch (e) {
      print("Error sending location update: $e");
    }
  }
}
