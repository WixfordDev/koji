import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../../models/admin-model/all_attendance_model.dart';
import '../../models/admin-model/all_task_summary_model.dart';


class AdminHomeController extends GetxController {

  /// ============================ Get All Attendance Summary =====================================

  RxBool getAllAttendanceLoading = false.obs;
  Rx<AllAttendanceSummaryModel> allAttendanceSummary = AllAttendanceSummaryModel().obs;

  getAllAttendanceSummary({String? date}) async {
    getAllAttendanceLoading(true);
    try {
      String formattedDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      String endpoint = "${ApiConstants.getAttendanceEndPoint}?date=$formattedDate";

      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        allAttendanceSummary.value = AllAttendanceSummaryModel.fromJson(response.body['data']['attributes']);
        getAllAttendanceLoading(false);
      } else if (response.statusCode == 404) {
        getAllAttendanceLoading(false);
        print("Attendance data not found for the specified date");
      } else {
        getAllAttendanceLoading(false);
        print("Error getting attendance: ${response.statusCode}");
      }
    } catch (e) {
      getAllAttendanceLoading(false);
      print("Exception in getAllAttendanceSummary: $e");
    }
  }

  /// ============================ Get All Task Summary =====================================


  RxBool getAllTaskSummaryLoading = false.obs;
  Rx<AllTaskSummaryModel> allTaskSummary = AllTaskSummaryModel().obs;

  getAllTaskSummary() async {
    getAllTaskSummaryLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getTaskSummaryEndPoint);

      if (response.statusCode == 200) {

        allTaskSummary.value = AllTaskSummaryModel.fromJson(response.body['data']['attributes']);
        getAllTaskSummaryLoading(false);
      } else if (response.statusCode == 404) {
        getAllTaskSummaryLoading(false);
      } else {
        getAllTaskSummaryLoading(false);
      }
    } catch (e) {
      getAllTaskSummaryLoading(false);
    }
  }






}

