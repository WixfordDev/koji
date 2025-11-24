import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:koji/services/api_client.dart';
import 'package:koji/services/api_constants.dart';

class AttendanceService {
  /// Get employee attendance list for given month (format: YYYY-MM)
  static Future<Response> getEmployeeList({required String date}) async {
    final uri = ApiConstants.attendanceEmployeeList + "?date=$date";
    return await ApiClient.getData(uri);
  }

  /// Check-in with ISO 8601 datetime string
  static Future<Response> checkIn({required String clockIn}) async {
    final body = jsonEncode({"clockIn": clockIn});
    return await ApiClient.postData(ApiConstants.attendanceCheckIn, body);
  }

  /// Check-out with ISO 8601 datetime string and optional notes
  static Future<Response> checkOut({
    required String clockOut,
    String? notes,
  }) async {
    final body = jsonEncode({
      "clockOut": clockOut,
      if (notes != null) "notes": notes,
    });
    return await ApiClient.postData(ApiConstants.attendanceCheckOut, body);
  }
}
