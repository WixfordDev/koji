import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/services/socket_services.dart';
import 'dart:convert';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  double _radius = 2.0; // miles

  LatLng _currentLocation = LatLng(23.8103, 90.4125); // default Dhaka
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _connectToSocket();
  }

  @override
  void dispose() {
    SocketServices().socket.off('employee-live-location::snapshot');
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedForeverDialog();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Update map position if controller is available
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation, 14));
    }
  }

  void _connectToSocket() {
    // Listen for employee location updates
    SocketServices().socket.on('employee-live-location::snapshot', (data) {
      if (data != null) {
        _updateEmployeeLocations(data);
      }
    });
  }

  void _updateEmployeeLocations(dynamic data) {
    if (data is List) {
      List<Employee> newEmployees = [];

      for (var item in data) {
        if (item is Map<String, dynamic>) {
          // Extract coordinates from the location object
          var locationData = item['location'] as Map<String, dynamic>?;
          var coordinates = locationData?['coordinates'] as List<dynamic>?;

          if (coordinates != null && coordinates.length >= 2) {
            double lat = coordinates[1].toDouble(); // Latitude is the second element
            double lng = coordinates[0].toDouble(); // Longitude is the first element
            String fullName = item['fullName'] ?? 'Unknown Employee';

            // Only add employees with valid coordinates (not 0,0 which indicates default location)
            if (lat != 0.0 || lng != 0.0) {
              newEmployees.add(
                Employee(
                  id: item['id'] ?? '',
                  name: fullName,
                  location: LatLng(lat, lng),
                  image: item['image'],
                ),
              );
            }
          }
        }
      }

      setState(() {
        _employees = newEmployees;
        _filteredEmployees = _employees.where((employee) {
          double distanceInMeters = Geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            employee.location.latitude,
            employee.location.longitude,
          );
          double distanceInMiles = distanceInMeters / 1609.34;
          return distanceInMiles <= _radius;
        }).toList();
      });
    }
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        double distanceInMeters = Geolocator.distanceBetween(
          _currentLocation.latitude,
          _currentLocation.longitude,
          employee.location.latitude,
          employee.location.longitude,
        );
        double distanceInMiles = distanceInMeters / 1609.34;
        return distanceInMiles <= _radius;
      }).toList();
    });
  }

  void _openFilterScreen() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 320,
          child: Column(
            children: [
              Text('Filter', style: TextStyle(fontSize: 20)),
              Divider(),

              SizedBox(height: 20.h),
              Text('Miles From Me: ${_radius.toStringAsFixed(1)}'),
              Slider(
                min: 1,
                max: 20,
                value: _radius,
                onChanged: (value) {
                  setState(() {
                    _radius = value;
                    _filterEmployees(); // Update filter when slider changes
                  });
                },
              ),

              Spacer(),

              CustomButton(
                boderColor: Colors.transparent,
                color: Colors.redAccent,
                title: "Apply",
                onpress: () {
                  _filterEmployees();
                  Navigator.pop(context);
                },
              ),

              SizedBox(height: 50.h),
            ],
          ),
        );
      },
    );
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Services Disabled"),
        content: Text("Please enable location services to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Denied"),
        content: Text("Location permission is needed to show your location on the map."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Permission Permanently Denied"),
        content: Text("Location permission is permanently denied. Please enable it in app settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = _filteredEmployees
        .map(
          (e) => Marker(
            markerId: MarkerId(e.id.isNotEmpty ? e.id : e.name),
            position: e.location,
            infoWindow: InfoWindow(title: e.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        )
        .toSet();

    // Add current location marker
    markers.add(
      Marker(
        markerId: MarkerId("current_location"),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "You"),
      ),
    );

    // Add radius circle around user's location
    Set<Circle> circles = {
      Circle(
        circleId: CircleId("radius_circle"),
        center: _currentLocation,
        radius: _radius * 1609.34, // convert miles → meters
        fillColor: Colors.blue.withOpacity(0.15),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: Text("Employee Tracking"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterScreen,
          ),
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Google Map with radius circle
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14,
            ),
            markers: markers,
            circles: circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // Search Field (Floating Style)
          SafeArea(
            child: Positioned(
              top: 100.h,
              left: 16,
              right: 16,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search employee...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filteredEmployees = _employees
                          .where(
                            (e) => e.name.toLowerCase().contains(
                              value.toLowerCase(),
                            ),
                          )
                          .toList();
                    });
                  },
                ),
              ),
            ),
          ),

          // Status indicator
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Live",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Employee {
  final String id;
  final String name;
  final LatLng location;
  final String? image;

  Employee({
    required this.id,
    required this.name,
    required this.location,
    this.image,
  });
}
