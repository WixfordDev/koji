import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/employee_task_service.dart';

class EmployeeHistoryController extends GetxController {
  var taskList = <TaskModel>[].obs;
  var isLoading = true.obs;
  var selectedStatus = 'pending'.obs; // Default to pending

  @override
  void onInit() {
    super.onInit();
    fetchTaskList();
  }

  Future<void> fetchTaskList({String? status}) async {
    try {
      isLoading.value = true;
      final actualStatus = status ?? selectedStatus.value;
      final response = await EmployeeTaskService.getEmployeeTaskList(
        status: _mapStatusForApi(actualStatus),
      );
      taskList.assignAll(response.data.attributes.results);
    } catch (error) {
      Get.snackbar("Error", "Failed to fetch task list: ${error.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Map UI status values to API status values
  String _mapStatusForApi(String status) {
    switch (status) {
      case 'pending':
        return 'pending';
      case 'completed':
      case 'done':
        return 'completed';
      case 'in_progress':
      case 'progress':
        return 'progress';
      default:
        return ''; // For 'all' status
    }
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    fetchTaskList(status: status);
  }
}
