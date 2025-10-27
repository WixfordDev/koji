import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  double _radius = 4.0; // miles

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
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
              Text('Filter', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
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
              ElevatedButton(
                onPressed: () {
                  _filterEmployees();
                  Navigator.pop(context);
                },
                child: Text('Apply'),
              ),
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

    // add current location marker
    markers.add(
      Marker(
        markerId: MarkerId("current_location"),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "You"),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _openFilterScreen();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Searching employee...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredEmployees = _employees
                      .where(
                        (e) =>
                            e.name.toLowerCase().contains(value.toLowerCase()),
                      )
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14,
              ),
              markers: markers,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
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
