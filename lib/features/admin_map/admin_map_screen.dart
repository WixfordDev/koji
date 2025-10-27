import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_button.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  double _radius = 2.0; // miles

  LatLng _currentLocation = LatLng(23.8103, 90.4125); // default Dhaka
  final List<Employee> _employees = [
    Employee(name: "Alice", location: LatLng(23.8120, 90.4110)),
    Employee(name: "Bob", location: LatLng(23.8150, 90.4180)),
    Employee(name: "Charlie", location: LatLng(23.8070, 90.4200)),
    Employee(name: "David", location: LatLng(23.8050, 90.4100)),
    Employee(name: "Eve", location: LatLng(23.8110, 90.4220)),
  ];

  List<Employee> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _filteredEmployees = _employees;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation, 14));
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

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = _filteredEmployees
        .map(
          (e) => Marker(
            markerId: MarkerId(e.name),
            position: e.location,
            infoWindow: InfoWindow(title: e.name),
          ),
        )
        .toSet();

    // ✅ Add current location marker
    markers.add(
      Marker(
        markerId: MarkerId("current_location"),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "You"),
      ),
    );

    // ✅ Add radius circle around user’s location
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
        title: Text("Tracking"),
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
          // ✅ Google Map with radius circle
          SizedBox(
            height: 730.h,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14,
              ),
              markers: markers,
              circles: circles,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),

          // ✅ Search Field (Floating Style)
          SafeArea(
            child: Positioned(
              top: 400.h,
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
        ],
      ),
    );
  }
}

class Employee {
  final String name;
  final LatLng location;

  Employee({required this.name, required this.location});
}
