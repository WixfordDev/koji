import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/services/socket_services.dart';

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
  String _searchType = 'All';
  final List<String> _searchTypes = ['All', 'Name'];
  final Set<String> _subscribedEmployeeIds = {};
  // Stores name/image for ALL employees (including [0,0]) for when they check in
  final Map<String, Map<String, String?>> _allEmployeesMeta = {};
  Timer? _retryTimer;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _connectToSocket();
    _getCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestEmployeeLocations();
      _retryTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _employees.isEmpty) _requestEmployeeLocations();
      });
      _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) _requestEmployeeLocations();
      });
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _refreshTimer?.cancel();
    _unsubscribeAllEmployeeListeners();
    try {
      SocketServices().socket.off('employee-live-location::snapshot');
      SocketServices().socket.off('employee-live-location');
      SocketServices().socket.off('connect');
    } catch (e) {
      print('Error removing socket listeners: $e');
    }
    _searchController.dispose();
    super.dispose();
  }

  void _requestEmployeeLocations() {
    print('🗺️ [Tracking] Socket connected: ${SocketServices().socket.connected}');
    print('🗺️ [Tracking] Emitting employee-live-location...');
    SocketServices().socket.emit('employee-live-location');
  }

  void _connectToSocket() {
    // Listen to both possible response event names (debug)
    SocketServices().socket.on('employee-live-location::snapshot', (data) {
      print('🗺️ [Tracking] Got employee-live-location::snapshot → $data');
      _updateEmployeeLocations(data);
    });

    SocketServices().socket.on('employee-live-location', (data) {
      print('🗺️ [Tracking] Got employee-live-location (no suffix) → $data');
      _updateEmployeeLocations(data);
    });

    // Re-request on reconnect
    SocketServices().socket.on('connect', (_) {
      print('🗺️ [Tracking] Socket reconnected — re-emitting employee-live-location');
      SocketServices().socket.emit('employee-live-location');
    });
  }

  void _subscribeToEmployeeLocations(List<Employee> employees) {
    _unsubscribeAllEmployeeListeners();
    for (final employee in employees) {
      if (employee.id.isEmpty) continue;
      _subscribedEmployeeIds.add(employee.id);
      SocketServices().socket.on('location::${employee.id}', (data) {
        _onEmployeeLocationUpdate(employee.id, data);
      });
    }
  }

  void _unsubscribeAllEmployeeListeners() {
    for (final id in _subscribedEmployeeIds) {
      SocketServices().socket.off('location::$id');
    }
    _subscribedEmployeeIds.clear();
  }

  void _onEmployeeLocationUpdate(String employeeId, dynamic data) {
    if (!mounted) return;
    if (data is! Map<String, dynamic>) return;

    double lat = 0.0, lng = 0.0;

    // Format 1: GeoJSON — {coordinates: [lng, lat]}
    final coords = data['coordinates'] as List<dynamic>?;
    if (coords != null && coords.length >= 2) {
      lng = coords[0]?.toDouble() ?? 0.0;
      lat = coords[1]?.toDouble() ?? 0.0;
    }

    // Format 2: direct — {latitude: x, longitude: y}
    if (lat == 0.0 && lng == 0.0) {
      lat = (data['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    print('📍 [Tracking] location::$employeeId → lat=$lat, lng=$lng | raw=$data');
    if (lat == 0.0 && lng == 0.0) return;

    setState(() {
      final idx = _employees.indexWhere((e) => e.id == employeeId);
      if (idx != -1) {
        // Existing employee — update location
        final old = _employees[idx];
        _employees[idx] = Employee(
          id: old.id,
          name: old.name,
          location: LatLng(lat, lng),
          image: old.image,
        );
      } else {
        // Employee was [0,0] in snapshot (not yet checked in) — add to map now
        final meta = _allEmployeesMeta[employeeId];
        _employees.add(Employee(
          id: employeeId,
          name: meta?['name'] ?? 'Employee',
          location: LatLng(lat, lng),
          image: meta?['image'],
        ));
      }
      _applyFilter();
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    if (!_controller.isCompleted) return;

    // If employees already loaded, don't override their camera position
    if (_employees.isNotEmpty) {
      setState(() => _applyFilter());
    } else {
      final mapController = await _controller.future;
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 14),
      );
    }
  }

  void _updateEmployeeLocations(dynamic data) {
    print('🗺️ [Tracking] _updateEmployeeLocations called, data type: ${data.runtimeType}, data: $data');
    if (data is! List) {
      print('🗺️ [Tracking] Data is NOT a List — skipping');
      return;
    }

    final newEmployees = <Employee>[];
    final allEmployeesForSubscription = <Employee>[];

    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['id'] ?? '';
      final name = item['fullName'] ?? 'Unknown';
      final image = item['image'];

      final locationData = item['location'] as Map<String, dynamic>?;
      final coordinates = locationData?['coordinates'] as List<dynamic>?;

      double lng = 0.0;
      double lat = 0.0;
      if (coordinates != null && coordinates.length >= 2) {
        lng = coordinates[0]?.toDouble() ?? 0.0;
        lat = coordinates[1]?.toDouble() ?? 0.0;
      }

      final employee = Employee(
        id: id,
        name: name,
        // Use default off-screen location for unset coords — will update on check-in
        location: LatLng(lat, lng),
        image: image,
      );

      allEmployeesForSubscription.add(employee);

      // Save meta for all employees so we can add them to map when they check in
      if (id.isNotEmpty) {
        _allEmployeesMeta[id] = {'name': name, 'image': image};
      }

      // Only show on map if has real location (not 0,0)
      if (lat != 0.0 || lng != 0.0) {
        newEmployees.add(employee);
      }
    }

    setState(() {
      _employees = newEmployees;
      _applyFilter();
    });

    // Subscribe to ALL employees (including [0,0] ones) so we catch check-ins
    _subscribeToEmployeeLocations(allEmployeesForSubscription);
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    _filteredEmployees = _employees.where((e) {
      final withinRadius = _isWithinRadius(e.location);
      if (!withinRadius) return false;
      if (query.isEmpty) return true;
      return e.name.toLowerCase().contains(query);
    }).toList();
  }

  bool _isWithinRadius(LatLng location) {
    final distanceMeters = Geolocator.distanceBetween(
      _currentLocation.latitude,
      _currentLocation.longitude,
      location.latitude,
      location.longitude,
    );
    return (distanceMeters / 1609.34) <= _radius;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.all(16),
            height: 300,
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
                    setSheetState(() => _radius = value);
                    setState(() => _applyFilter());
                  },
                ),
                Spacer(),
                CustomButton(
                  boderColor: Colors.transparent,
                  color: Colors.redAccent,
                  title: "Apply",
                  onpress: () => Navigator.pop(context),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      // Admin's current location
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You'),
      ),
      // Employee markers
      ..._filteredEmployees.map((e) => Marker(
            markerId: MarkerId(e.id.isNotEmpty ? e.id : e.name),
            position: e.location,
            infoWindow: InfoWindow(title: e.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          )),
    };

    final circles = <Circle>{
      Circle(
        circleId: const CircleId('radius_circle'),
        center: _currentLocation,
        radius: _radius * 1609.34,
        fillColor: Colors.blue.withOpacity(0.15),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('Employee Tracking'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh employees',
            onPressed: _requestEmployeeLocations,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
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
            onMapCreated: (c) => _controller.complete(c),
          ),

          // Search bar
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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search by name...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (_) => setState(() => _applyFilter()),
                ),
              ),
            ),
          ),

          // Live / Offline badge
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: SocketServices().socket.connected
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                SocketServices().socket.connected ? 'Live' : 'Offline',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
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

  const Employee({
    required this.id,
    required this.name,
    required this.location,
    this.image,
  });
}
