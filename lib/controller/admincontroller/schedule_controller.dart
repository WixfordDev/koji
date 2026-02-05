import 'package:get/get.dart';
import 'package:koji/models/admin-model/all_month_model.dart';
import 'package:koji/models/admin-model/all_employee_task_model.dart';
import 'package:koji/models/admin-model/get_alllist_task_model.dart';
import 'package:koji/services/api_client.dart';
import 'package:koji/services/api_constants.dart';

import '../../models/admin-model/task_details_model.dart';

class ScheduleController extends GetxController {
  // Variables to store API response data
  Rx<AllMonthModel?> allMonthData = Rx<AllMonthModel?>(null);
  Rx<AllEmployeeTaskModel?> allEmployeeTaskData = Rx<AllEmployeeTaskModel?>(null);
  Rx<GetAllListTaskModel?> allTaskListData = Rx<GetAllListTaskModel?>(null);

  // Loading states
  RxBool monthDataLoading = false.obs;
  RxBool employeeTaskDataLoading = false.obs;
  RxBool allTaskListDataLoading = false.obs;

  /// Fetch monthly task summary data
  /// [date] - The date to fetch data for in YYYY-MM format (e.g., "2025-11")
  Future<AllMonthModel?> getMonthlyTaskSummary(String date) async {
    monthDataLoading(true);
    try {
      String endpoint = "${ApiConstants.taskMonthEndPoint}?date=$date";
      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        allMonthData.value = AllMonthModel.fromJson(response.body);
        return allMonthData.value;
      } else {
        print("Error getting monthly task summary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception in getMonthlyTaskSummary: $e");
      return null;
    } finally {
      monthDataLoading(false);
    }
  }

  /// Fetch employee task data
  /// [date] - The specific date in YYYY-MM-DD format (e.g., "2025-12-16")
  /// [page] - Page number for pagination (default is 1)
  /// [limit] - Number of results per page (default is 10)
  Future<AllEmployeeTaskModel?> getEmployeeTaskData({
    required String date,
    int page = 1,
    int limit = 10,
  }) async {
    employeeTaskDataLoading(true);
    try {
      String endpoint = "${ApiConstants.allEmployeeTaskEndPoint}?date=$date&page=$page&limit=$limit";
      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        allEmployeeTaskData.value = AllEmployeeTaskModel.fromJson(response.body);
        return allEmployeeTaskData.value;
      } else {
        print("Error getting employee task data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception in getEmployeeTaskData: $e");
      return null;
    } finally {
      employeeTaskDataLoading(false);
    }
  }

  /// Fetch tasks for a specific employee on a specific date
  /// [date] - The specific date in YYYY-MM-DD format (e.g., "2025-12-16")
  /// [assignTo] - The employee ID to filter tasks for
  /// [page] - Page number for pagination (default is 1)
  /// [limit] - Number of results per page (default is 10)
  Future<GetAllListTaskModel?> getEmployeeTasks({
    required String date,
    required String assignTo,
    int page = 1,
    int limit = 10,
  }) async {
    allTaskListDataLoading(true);
    try {
      String endpoint = "${ApiConstants.allListTaskEndPointTemplate}date=$date&assignTo=$assignTo&page=$page&limit=$limit";
      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        // Fix: Access the nested data.attributes path
        if (response.body['data'] != null && response.body['data']['attributes'] != null) {
          allTaskListData.value = GetAllListTaskModel.fromJson(response.body['data']['attributes']);
        } else {
          allTaskListData.value = null;
        }
        return allTaskListData.value;
      } else {
        print("Error getting employee tasks: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception in getEmployeeTasks: $e");
      return null;
    } finally {
      allTaskListDataLoading(false);
    }
  }








  // Task details
  Rx<TaskDetailsModel?> taskDetailsData = Rx<TaskDetailsModel?>(null);
  RxBool taskDetailsLoading = false.obs;

  /// Fetch details for a specific task
  /// [taskId] - The ID of the task to get details for
  Future<TaskDetailsModel?> getTaskDetails(String taskId) async {
    taskDetailsLoading(true);
    try {
      String endpoint = "${ApiConstants.taskDetailsEndPointTemplate}$taskId";
      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        taskDetailsData.value = TaskDetailsModel.fromJson(response.body["data"]["attributes"]);
        return taskDetailsData.value;
      } else {
        print("Error getting task details: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception in getTaskDetails: $e");
      return null;
    } finally {
      taskDetailsLoading(false);
    }
  }
}