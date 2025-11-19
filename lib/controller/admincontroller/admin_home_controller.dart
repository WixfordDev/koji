import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../../models/admin-model/all_attendance_model.dart';


class AdminHomeController extends GetxController {

  /// ============================ Get All Attendance Summary =====================================

  RxBool getAllAttendanceLoading = false.obs;
  Rx<AllAttendanceSummaryModel> allAttendanceSummary = AllAttendanceSummaryModel().obs;

  getAllAttendanceSummary({String? date}) async {
    getAllAttendanceLoading(true);
    try {
      // Build the endpoint with the date parameter if provided
      String endpoint = ApiConstants.getAttendanceEndPoint;
      if (date != null) {
        endpoint = "$endpoint?date=$date";
      }

      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        allAttendanceSummary.value = AllAttendanceSummaryModel.fromJson(response.body['data']['attributes']);
        getAllAttendanceLoading(false);
      } else if (response.statusCode == 404) {
        getAllAttendanceLoading(false);
        // Handle 404 error case
        print("Attendance data not found for the specified date");
      } else {
        getAllAttendanceLoading(false);
        // Handle other error cases
        print("Error getting attendance: ${response.statusCode}");
      }
    } catch (e) {
      getAllAttendanceLoading(false);
      print("Exception in getAllAttendanceSummary: $e");
    }
  }

}

