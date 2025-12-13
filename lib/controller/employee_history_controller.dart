import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/employee_task_service.dart';

class EmployeeHistoryController extends GetxController {
  var taskList = <TaskModel>[].obs;
  var isLoading = true.obs;
  var selectedStatus = 'pending'.obs; // Default to pending

  Future<void> fetchTaskList({String? status}) async {
    try {
      isLoading.value = true;
      final response = await EmployeeTaskService.getEmployeeTaskList(
        status: "${status ?? ""}",
      );
      taskList.assignAll(response.data.attributes.results);
    } catch (error) {
      Get.snackbar("Error", "Failed to fetch task list: ${error.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    fetchTaskList();
  }
}
