import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/services/socket_services.dart';
import 'package:koji/helpers/prefs_helper.dart';

class AdminMapScreen extends StatefulWidget {
  @override
  _AdminMapScreenState createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  double _radius = 2.0; // miles

  LatLng _currentLocation = const LatLng(23.8103, 90.4125); // default Dhaka
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  List<Employee> _suggestions = [];
  bool _showSuggestions = false;
  String? _trackedEmployeeId; // which employee is currently being tracked
  final Map<String, BitmapDescriptor> _markerIcons = {}; // cached custom icons

  @override
  void initState() {
    super.initState();
    SocketServices().socket.emit('employee-live-location');
    _getCurrentLocation();
    _connectToSocket();

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    try {
      SocketServices().socket.off('employee-live-location::snapshot');
    } catch (_) {}
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _connectToSocket() {
    SocketServices().socket.on('employee-live-location::snapshot', (data) {
      _updateEmployeeLocations(data);
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    if (_controller.isCompleted) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 14),
      );
    }
  }

  void _updateEmployeeLocations(dynamic data) {
    if (data is! List) return;

    final List<Employee> newEmployees = [];
    for (var item in data) {
      if (item is Map<String, dynamic>) {
        final locationData = item['location'] as Map<String, dynamic>?;
        final coordinates = locationData?['coordinates'] as List<dynamic>?;

        if (coordinates != null && coordinates.length >= 2) {
          final double lng = coordinates[0]?.toDouble() ?? 0.0;
          final double lat = coordinates[1]?.toDouble() ?? 0.0;
          if (lat != 0.0 || lng != 0.0) {
            newEmployees.add(Employee(
              id: item['id'] ?? '',
              name: item['fullName'] ?? 'Unknown',
              location: LatLng(lat, lng),
              image: item['image'],
            ));
          }
        }
      }
    }

    // Generate custom marker icons for new employees
    for (final emp in newEmployees) {
      final key = emp.id.isNotEmpty ? emp.id : emp.name;
      if (!_markerIcons.containsKey(key)) {
        _buildEmployeeMarkerIcon(emp.name, isTracked: false).then((icon) {
          _markerIcons[key] = icon;
          if (mounted) setState(() {});
        });
      }
    }

    setState(() {
      _employees = newEmployees;
      _applyFilter(_searchController.text);
    });

    // If we are tracking a specific employee, keep camera on them
    if (_trackedEmployeeId != null) {
      final tracked = _employees
          .where((e) => e.id == _trackedEmployeeId)
          .toList();
      if (tracked.isNotEmpty) {
        _moveCameraTo(tracked.first.location);
      }
    }
  }

  /// Draws a custom pin marker: coloured circle with initials + name label.
  Future<BitmapDescriptor> _buildEmployeeMarkerIcon(
    String name, {
    bool isTracked = false,
  }) async {
    const double size = 120;
    const double circleR = 36;
    const double pinTip = 12;
    const double labelPad = 6;

    final Color bg = isTracked ? const Color(0xFFF48201) : AppColor.primaryColor;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // ── Drop shadow ──────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
    canvas.drawCircle(
        const Offset(size / 2 + 2, circleR + 2), circleR, shadowPaint);

    // ── Circle background ─────────────────────────────────────────
    final circlePaint = Paint()..color = bg;
    canvas.drawCircle(const Offset(size / 2, circleR), circleR, circlePaint);

    // ── White border ──────────────────────────────────────────────
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(size / 2, circleR), circleR, borderPaint);

    // ── Pin triangle ──────────────────────────────────────────────
    final pinPaint = Paint()..color = bg;
    final path = Path()
      ..moveTo(size / 2 - 10, circleR * 2 - 4)
      ..lineTo(size / 2 + 10, circleR * 2 - 4)
      ..lineTo(size / 2, circleR * 2 + pinTip)
      ..close();
    canvas.drawPath(path, pinPaint);

    // ── Initials text ─────────────────────────────────────────────
    final initials = _initialsFrom(name);
    final textPainter = TextPainter(
      text: TextSpan(
        text: initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        size / 2 - textPainter.width / 2,
        circleR - textPainter.height / 2,
      ),
    );

    // ── Name label below pin ──────────────────────────────────────
    final namePainter = TextPainter(
      text: TextSpan(
        text: name.split(' ').first, // first name only
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size);

    // draw label background pill
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          size / 2,
          circleR * 2 + pinTip + labelPad + namePainter.height / 2 + 4,
        ),
        width: namePainter.width + 12,
        height: namePainter.height + 6,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(labelRect, Paint()..color = bg);
    namePainter.paint(
      canvas,
      Offset(
        size / 2 - namePainter.width / 2,
        circleR * 2 + pinTip + labelPad + 3,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  String _initialsFrom(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _applyFilter(String query) {
    if (query.isEmpty) {
      // No search — apply radius filter
      _filteredEmployees = _employees.where((e) {
        final distanceMeters = Geolocator.distanceBetween(
          _currentLocation.latitude, _currentLocation.longitude,
          e.location.latitude, e.location.longitude,
        );
        return (distanceMeters / 1609.34) <= _radius;
      }).toList();
      _suggestions = [];
      _showSuggestions = false;
    } else {
      // Search — show ALL matching employees regardless of radius
      final matches = _employees
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _filteredEmployees = matches;
      _suggestions = matches;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _applyFilter(query);
      _showSuggestions = query.isNotEmpty && _suggestions.isNotEmpty;
      if (query.isEmpty) _trackedEmployeeId = null;
    });
  }

  /// When a suggestion is tapped → move camera + open InfoWindow
  Future<void> _selectEmployee(Employee employee) async {
    final key = employee.id.isNotEmpty ? employee.id : employee.name;

    // Rebuild marker icon in orange (tracked state)
    final trackedIcon =
        await _buildEmployeeMarkerIcon(employee.name, isTracked: true);
    _markerIcons[key] = trackedIcon;

    _searchController.text = employee.name;
    setState(() {
      _trackedEmployeeId = employee.id;
      _filteredEmployees = [employee];
      _suggestions = [];
      _showSuggestions = false;
    });
    _searchFocus.unfocus();
    await _moveCameraTo(employee.location, zoom: 16);

    // Open InfoWindow for that marker
    final controller = await _controller.future;
    controller.showMarkerInfoWindow(MarkerId(key));
  }

  Future<void> _moveCameraTo(LatLng target, {double zoom = 16}) async {
    if (_controller.isCompleted) {
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _trackedEmployeeId = null;
      _showSuggestions = false;
      _applyFilter('');
    });
  }

  void _openFilterScreen() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        double tempRadius = _radius;
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(20.w),
            height: 300.h,
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Filter by Radius',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Divider(height: 24.h),
                Text(
                  'Radius: ${tempRadius.toStringAsFixed(1)} miles',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
                Slider(
                  min: 1,
                  max: 20,
                  divisions: 19,
                  activeColor: AppColor.primaryColor,
                  value: tempRadius,
                  onChanged: (value) =>
                      setModalState(() => tempRadius = value),
                ),
                const Spacer(),
                CustomButton(
                  boderColor: Colors.transparent,
                  color: AppColor.primaryColor,
                  title: "Apply",
                  onpress: () {
                    setState(() {
                      _radius = tempRadius;
                      _applyFilter(_searchController.text);
                    });
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        });
      },
    );
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Location Services Disabled"),
        content:
            const Text("Please enable location services to use this feature."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"))
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Location Permission Denied"),
        content: const Text(
            "Location permission is needed to show your location on the map."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"))
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Permanently Denied"),
        content: const Text(
            "Location permission is permanently denied. Please enable it in app settings."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = _filteredEmployees.map((e) {
      final key = e.id.isNotEmpty ? e.id : e.name;
      return Marker(
        markerId: MarkerId(key),
        position: e.location,
        infoWindow: InfoWindow(
          title: e.name,
          snippet: _distanceLabel(e.location),
        ),
        icon: _markerIcons[key] ??
            BitmapDescriptor.defaultMarkerWithHue(
              e.id == _trackedEmployeeId
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueGreen,
            ),
      );
    }).toSet();

    markers.add(Marker(
      markerId: const MarkerId("current_location"),
      position: _currentLocation,
      icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: "You"),
    ));

    final Set<Circle> circles = {
      Circle(
        circleId: const CircleId("radius_circle"),
        center: _currentLocation,
        radius: _radius * 1609.34,
        fillColor: Colors.blue.withOpacity(0.10),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        leading: const SizedBox(),
        title: Text(
          "Employee Tracking",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _openFilterScreen,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Map ──────────────────────────────────────────────
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
              onTap: (_) {
                // dismiss suggestions when tapping map
                if (_showSuggestions) {
                  setState(() => _showSuggestions = false);
                  _searchFocus.unfocus();
                }
              },
            ),

            // ── Live / Offline chip ───────────────────────────────
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: SocketServices().socket.connected
                      ? Colors.green
                      : Colors.redAccent,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.h,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      SocketServices().socket.connected ? "Live" : "Offline",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar + suggestions ──────────────────────────
            Positioned(
              top: 12.h,
              left: 12.w,
              right: 70.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: TextStyle(fontSize: 14.sp),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search,
                            color: AppColor.primaryColor, size: 20.r),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close,
                                    color: Colors.grey, size: 18.r),
                                onPressed: _clearSearch,
                              )
                            : null,
                        hintText: "Search employee...",
                        hintStyle: TextStyle(
                            fontSize: 13.sp, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 14.h),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),

                  // Suggestions dropdown
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      constraints: BoxConstraints(maxHeight: 220.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 52.w,
                            color: Colors.grey[200],
                          ),
                          itemBuilder: (context, index) {
                            final emp = _suggestions[index];
                            final dist = _distanceLabel(emp.location);
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16.r,
                                backgroundColor: AppColor.primaryColor,
                                child: Text(
                                  emp.name.isNotEmpty
                                      ? emp.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              title: Text(
                                emp.name,
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                dist,
                                style: TextStyle(
                                    fontSize: 11.sp, color: Colors.grey[500]),
                              ),
                              trailing: Icon(Icons.my_location,
                                  size: 16.r, color: AppColor.primaryColor),
                              onTap: () => _selectEmployee(emp),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Employee count chip ───────────────────────────────
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    _trackedEmployeeId != null
                        ? "Tracking: ${_filteredEmployees.firstOrNull?.name ?? ''}"
                        : "${_filteredEmployees.length} employee${_filteredEmployees.length == 1 ? '' : 's'} in view",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _distanceLabel(LatLng employeeLocation) {
    final meters = Geolocator.distanceBetween(
      _currentLocation.latitude, _currentLocation.longitude,
      employeeLocation.latitude, employeeLocation.longitude,
    );
    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m away";
    } else {
      return "${(meters / 1000).toStringAsFixed(1)} km away";
    }
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
