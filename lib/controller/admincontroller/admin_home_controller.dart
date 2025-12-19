import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../../models/admin-model/all_attendance_model.dart';
import '../../models/admin-model/all_attendance_list_model.dart';
import '../../models/admin-model/all_employee_model.dart';
import '../../models/admin-model/all_task_summary_model.dart';
import '../../models/admin-model/get_alllist_task_model.dart';
import '../../models/admin-model/transaction_model.dart';


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





  /// ============================ Employee Request =====================================


  RxBool getEmployeeRequestLoading = false.obs;
  Rx<AllEmployeeModel> employeeRequest = AllEmployeeModel().obs;

  getEmployeeRequest() async {
    getEmployeeRequestLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getEmployeeUserListEndPoint);

      if (response.statusCode == 200) {

        employeeRequest.value = AllEmployeeModel.fromJson(response.body['data']['attributes']);
        getEmployeeRequestLoading(false);
      } else if (response.statusCode == 404) {
        getEmployeeRequestLoading(false);
      } else {
        getEmployeeRequestLoading(false);
      }
    } catch (e) {
      getEmployeeRequestLoading(false);
    }
  }

  /// ============================ Approve Employee  =====================================










  /// ============================ Get All Attendance Individual Records =====================================

  RxBool getAdminAllAttendanceLoading = false.obs;
  Rx<AllAttendanceModel> allAttendance = AllAttendanceModel().obs;

  getAdminAllAttendance() async {
    getAdminAllAttendanceLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getAllAttendanceEndPoint);

      if (response.statusCode == 200) {
        allAttendance.value = AllAttendanceModel.fromJson(response.body['data']['attributes']);
        getAdminAllAttendanceLoading(false);
      } else if (response.statusCode == 404) {
        allAttendance.value = AllAttendanceModel(results: [], totalResults: 0);
        getAdminAllAttendanceLoading(false);
      } else {
        allAttendance.value = AllAttendanceModel(results: [], totalResults: 0);
        getAdminAllAttendanceLoading(false);
        print("Error getting attendance: ${response.statusCode}");
      }
    } catch (e) {
      allAttendance.value = AllAttendanceModel(results: [], totalResults: 0);
      getAdminAllAttendanceLoading(false);
      print("Exception in getAdminAllAttendance: $e");
    }
  }



  /// ============================ Get All List Task  =====================================


  RxBool getAllListTaskLoading = false.obs;
  Rx<GetAllListTaskModel> getAllListTask = GetAllListTaskModel().obs;

  getAllListTasks() async {
    getAllListTaskLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getAllTaskEndPoint);

      if (response.statusCode == 200) {

        getAllListTask.value = GetAllListTaskModel.fromJson(response.body['data']['attributes']);
        getAllListTaskLoading(false);
      } else if (response.statusCode == 404) {
        getAllListTaskLoading(false);
      } else {
        getAllListTaskLoading(false);
      }
    } catch (e) {
      getAllListTaskLoading(false);
    }
  }



  /// ============================ Get Transactions  =====================================


  RxBool getTransactionLoading = false.obs;
  Rx<TransactionModel> transaction = TransactionModel().obs;

  getTransaction() async {
    getTransactionLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.transactionsEndPoint);

      if (response.statusCode == 200) {

        transaction.value = TransactionModel.fromJson(response.body['data']['attributes']);
        getTransactionLoading(false);
      } else if (response.statusCode == 404) {
        getTransactionLoading(false);
      } else {
        getTransactionLoading(false);
      }
    } catch (e) {
      getTransactionLoading(false);
    }
  }




  /// ============================ Approve Employee  =====================================

  RxBool approveEmployeeLoading = false.obs;

  Future<bool> approveEmployee({required String employeeId}) async {
    approveEmployeeLoading(true);
    try {
      var response = await ApiClient.postData(
        "${ApiConstants.approveProfileEndPoint}$employeeId",
        {}, // Empty body for the post request
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        approveEmployeeLoading(false);
        // Refresh the employee request list after successful approval
        getEmployeeRequest();
        return true;
      } else {
        approveEmployeeLoading(false);
        print("Error approving employee: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      approveEmployeeLoading(false);
      print("Exception in approveEmployee: $e");
      return false;
    }
  }
}

