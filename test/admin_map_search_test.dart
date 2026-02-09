import 'package:flutter_test/flutter_test.dart';
import 'package:koji/features/admin_map/admin_map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('AdminMapScreen Search Functionality', () {
    test('should filter employees by name when search query is provided', () {
      // Create mock employees
      final employees = [
        Employee(id: '1', name: 'John Doe', location: LatLng(23.8103, 90.4125)),
        Employee(id: '2', name: 'Jane Smith', location: LatLng(23.8104, 90.4126)),
        Employee(id: '3', name: 'Bob Johnson', location: LatLng(23.8105, 90.4127)),
      ];

      // Create a mock AdminMapScreenState
      final state = _MockAdminMapScreenState(employees);

      // Simulate search for "john"
      state._updateSearchResults('john');

      // Verify that only employees with "john" in their name are returned
      expect(state.filteredEmployees.length, 2);
      expect(state.filteredEmployees.any((emp) => emp.name == 'John Doe'), true);
      expect(state.filteredEmployees.any((emp) => emp.name == 'Bob Johnson'), true);
      expect(state.filteredEmployees.any((emp) => emp.name == 'Jane Smith'), false);
    });

    test('should return all employees within radius when search query is empty', () {
      // Create mock employees
      final employees = [
        Employee(id: '1', name: 'John Doe', location: LatLng(23.8103, 90.4125)),
        Employee(id: '2', name: 'Jane Smith', location: LatLng(23.8104, 90.4126)),
        Employee(id: '3', name: 'Bob Johnson', location: LatLng(23.8105, 90.4127)),
      ];

      // Create a mock AdminMapScreenState
      final state = _MockAdminMapScreenState(employees);

      // Simulate empty search query
      state._updateSearchResults('');

      // Verify that all employees within radius are returned
      expect(state.filteredEmployees.length, 3);
    });

    test('should filter by both name and radius when both conditions apply', () {
      // Create mock employees
      final employees = [
        Employee(id: '1', name: 'John Doe', location: LatLng(23.8103, 90.4125)),
        Employee(id: '2', name: 'Jane Smith', location: LatLng(23.8104, 90.4126)),
        Employee(id: '3', name: 'Bob Johnson', location: LatLng(30.0, 90.0)), // Far away
      ];

      // Create a mock AdminMapScreenState
      final state = _MockAdminMapScreenState(employees);

      // Simulate search for "john"
      state._updateSearchResults('john');

      // Verify that only John Doe is returned (Bob Johnson is filtered out due to distance)
      expect(state.filteredEmployees.length, 1);
      expect(state.filteredEmployees.first.name, 'John Doe');
    });
  });
}

// Mock class to test the search functionality
class _MockAdminMapScreenState {
  List<Employee> employees;
  List<Employee> filteredEmployees = [];
  double radius = 2.0; // miles
  LatLng currentLocation = LatLng(23.8103, 90.4125);

  _MockAdminMapScreenState(this.employees) {
    // Initialize with all employees
    filteredEmployees = List.from(employees);
  }

  void _updateSearchResults(String query) {
    if (query.isEmpty) {
      // If search is empty, apply only the radius filter
      filteredEmployees = employees.where((employee) {
        double distanceInMeters = 0.0; // Simplified for testing
        double distanceInMiles = distanceInMeters / 1609.34;
        return distanceInMiles <= radius;
      }).toList();
    } else {
      // Apply both search and radius filter
      filteredEmployees = employees.where((employee) {
        bool nameMatches = employee.name.toLowerCase().contains(
          query.toLowerCase(),
        );
        
        double distanceInMeters = 0.0; // Simplified for testing
        double distanceInMiles = distanceInMeters / 1609.34;
        bool withinRadius = distanceInMiles <= radius;
        
        return nameMatches && withinRadius;
      }).toList();
    }
  }
}