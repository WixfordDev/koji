import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/services/socket_services.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/models/task_model.dart';
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
  List<TaskModel> _allTasks = []; // Store all tasks for search
  String _searchType = 'All'; // Current search type
  List<String> _searchTypes = ['All', 'Name', 'Location', 'Department', 'Task Status'];

  @override
  void initState() {
    super.initState();
    SocketServices().socket.emit('employee-live-location');
    _getCurrentLocation();
    _connectToSocket();
    _loadAllTasks(); // Load all tasks for search
  }

  @override
  void dispose() {
    try {
      // Remove all socket listeners
      if (SocketServices().socket != null) {
        SocketServices().socket.off('employee-live-location::snapshot');
        SocketServices().socket.off('connect');
        SocketServices().socket.off('disconnect');
        SocketServices().socket.off('error');
      }
    } catch (e) {
      print('Error disconnecting from socket: $e');
    }
    _searchController.dispose();
    super.dispose();
  }

  void _connectToSocket() {
    // Listen for the location snapshot updates
    SocketServices().socket.on('employee-live-location::snapshot', (data) {
      _updateEmployeeLocations(data);
    });
  }

  Future<void> _loadAllTasks() async {
    // This would typically load tasks from the API
    // For now, we'll simulate loading tasks
    // In a real implementation, you would call an API endpoint
    // Example: final response = await ApiClient.getData(ApiConstants.getAllTaskEndPoint);
    // Then parse the response to populate _allTasks
    
    // Simulated tasks for demonstration
    setState(() {
      _allTasks = [];
    });
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
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 14),
      );
    }
  }

  // Helper method to get user ID from preferences
  Future<String?> _getUserId() async {
    try {
      return await PrefsHelper.getString('userId');
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Helper method to get FCM token
  Future<String?> _getFcmToken() async {
    try {
      return await PrefsHelper.getString('fcmToken');
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
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
            double lng = coordinates[0]?.toDouble() ?? 0.0; // Longitude is the first element
            double lat = coordinates[1]?.toDouble() ?? 0.0; // Latitude is the second element
            String fullName = item['fullName'] ?? 'Unknown Employee';

            // Only add employees with valid coordinates (not 0,0 which indicates default location)
            if (lat != 0.0 || lng != 0.0) {
              newEmployees.add(
                Employee(
                  id: item['id'] ?? '',
                  name: fullName,
                  location: LatLng(lat, lng),
                  image: item['image'],
                  department: item['department'] ?? '', // Assuming department is available in the data
                  status: item['status'] ?? 'active', // Assuming status is available in the data
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
        content: Text(
          "Location permission is needed to show your location on the map.",
        ),
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
        content: Text(
          "Location permission is permanently denied. Please enable it in app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // Enhanced search functionality
  void _performSearch(String query) {
    if (query.isEmpty) {
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
      return;
    }

    List<Employee> searchResults = [];

    switch (_searchType) {
      case 'All':
        searchResults = _employees.where((e) {
          bool matchesName = e.name.toLowerCase().contains(query.toLowerCase());
          bool matchesDepartment = e.department.toLowerCase().contains(query.toLowerCase());
          bool matchesStatus = e.status.toLowerCase().contains(query.toLowerCase());
          
          double distanceInMeters = Geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            e.location.latitude,
            e.location.longitude,
          );
          double distanceInMiles = distanceInMeters / 1609.34;
          
          return (matchesName || matchesDepartment || matchesStatus) && distanceInMiles <= _radius;
        }).toList();
        break;
        
      case 'Name':
        searchResults = _employees.where((e) {
          bool matchesName = e.name.toLowerCase().contains(query.toLowerCase());
          
          double distanceInMeters = Geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            e.location.latitude,
            e.location.longitude,
          );
          double distanceInMiles = distanceInMeters / 1609.34;
          
          return matchesName && distanceInMiles <= _radius;
        }).toList();
        break;
        
      case 'Location':
        // For location search, we could match against location names if available
        // For now, we'll just match against the coordinates
        searchResults = _employees.where((e) {
          // In a real implementation, you might have location names stored
          // For now, we'll just return all employees within the radius
          double distanceInMeters = Geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            e.location.latitude,
            e.location.longitude,
          );
          double distanceInMiles = distanceInMeters / 1609.34;
          
          return distanceInMiles <= _radius;
        }).toList();
        break;
        
      case 'Department':
        searchResults = _employees.where((e) {
          bool matchesDepartment = e.department.toLowerCase().contains(query.toLowerCase());
          
          double distanceInMeters = Geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            e.location.latitude,
            e.location.longitude,
          );
          double distanceInMiles = distanceInMeters / 1609.34;
          
          return matchesDepartment && distanceInMiles <= _radius;
        }).toList();
        break;
        
      case 'Task Status':
        searchResults = _employees.where((e) {
          bool matchesStatus = e.status.toLowerCase().contains(query.toLowerCase());
          
          double distanceInMeters = Geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            e.location.latitude,
            e.location.longitude,
          );
          double distanceInMiles = distanceInMeters / 1609.34;
          
          return matchesStatus && distanceInMiles <= _radius;
        }).toList();
        break;
        
      default:
        searchResults = _employees.where((e) {
          double distanceInMeters = Geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            e.location.latitude,
            e.location.longitude,
          );
          double distanceInMiles = distanceInMeters / 1609.34;
          return distanceInMiles <= _radius;
        }).toList();
        break;
    }

    setState(() {
      _filteredEmployees = searchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = _filteredEmployees
        .map(
          (e) => Marker(
            markerId: MarkerId(e.id.isNotEmpty ? e.id : e.name),
            position: e.location,
            infoWindow: InfoWindow(
              title: e.name,
              snippet: 'Department: ${e.department}\nStatus: ${e.status}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
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

          // Search Field (Floating Style) with enhanced search options
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search type selector
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: DropdownButton<String>(
                        value: _searchType,
                        isExpanded: true,
                        underline: Container(color: Colors.transparent),
                        items: _searchTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _searchType = newValue!;
                            _performSearch(_searchController.text);
                          });
                        },
                      ),
                    ),
                    
                    // Search input field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search by ${_searchType.toLowerCase()}...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) {
                        _performSearch(value);
                      },
                    ),
                  ],
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
                color: SocketServices().socket.connected
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                SocketServices().socket.connected ? "Live" : "Offline",
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
  final String department;
  final String status;

  Employee({
    required this.id,
    required this.name,
    required this.location,
    this.image,
    this.department = '',
    this.status = 'active',
  });
}