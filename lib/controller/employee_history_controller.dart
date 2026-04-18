import 'package:get/get.dart';
import 'package:koji/services/api_client.dart';
import '../services/employee_task_service.dart';
import '../models/history_model.dart';

class EmployeeHistoryController extends GetxController {
  var taskList = <HistoryModel>[].obs;
  var filteredTaskList = <HistoryModel>[].obs;
  var isLoading = true.obs;
  var selectedStatus = ''.obs; // Empty string means "All"

  Future<void> fetchTaskList() async {
    try {
      isLoading.value = true;
      const base = '/tasks/employ/list?limit=100&page=1';
      final first = await ApiClient.getData(base);
      if (first.statusCode == 200 || first.statusCode == 201) {
        final attrs = first.body["data"]['attributes'];
        final totalPages = attrs['totalPages'] ?? 1;
        final allResults = List<HistoryModel>.from(
          attrs["results"].map((x) => HistoryModel.fromJson(x)),
        );

        for (int page = 2; page <= totalPages; page++) {
          final res = await ApiClient.getData(
              '/tasks/employ/list?limit=100&page=$page');
          if (res.statusCode == 200 || res.statusCode == 201) {
            final more = res.body["data"]['attributes']["results"];
            allResults.addAll(
              List<HistoryModel>.from(more.map((x) => HistoryModel.fromJson(x))),
            );
          }
        }

        taskList.assignAll(allResults);
        _applyFilter();
        update();
      } else {
        print("fetchTaskList error: ${first.statusCode} ${first.statusText}");
      }
    } catch (error) {
      print("fetchTaskList exception: $error");
    } finally {
      isLoading.value = false;
    }
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedStatus.value.isEmpty) {
      // Show all tasks
      filteredTaskList.assignAll(taskList);
    } else {
      List<HistoryModel> filtered = [];
      switch (selectedStatus.value.toLowerCase()) {
        case 'pending':
          filtered = taskList.where((task) =>
            task.status?.toLowerCase() == 'pending' ||
            task.status?.toLowerCase() == 'assigned'
          ).toList();
          break;
        case 'completed':
        case 'done':
          filtered = taskList.where((task) =>
            task.status?.toLowerCase() == 'completed' ||
            task.status?.toLowerCase() == 'done' ||
            task.status?.toLowerCase() == 'finished'
          ).toList();
          break;
        case 'in_progress':
          filtered = taskList.where((task) =>
            task.status?.toLowerCase() == 'in_progress' ||
            task.status?.toLowerCase() == 'in progress' ||
            task.status?.toLowerCase() == 'progress' ||
            task.status?.toLowerCase() == 'working'
          ).toList();
          break;
        default:
          filtered = taskList;
          break;
      }
      filteredTaskList.assignAll(filtered);
    }
  }

  int get totalTasks => taskList.length;

  int get completedTasksCount =>
    taskList.where((task) =>
      task.status?.toLowerCase() == 'completed' ||
      task.status?.toLowerCase() == 'done' ||
      task.status?.toLowerCase() == 'finished'
    ).length;

  int get pendingTasksCount =>
    taskList.where((task) =>
      task.status?.toLowerCase() == 'pending' ||
      task.status?.toLowerCase() == 'assigned'
    ).length;

  int get inProgressTasksCount =>
    taskList.where((task) =>
      task.status?.toLowerCase() == 'in_progress' ||
      task.status?.toLowerCase() == 'in progress' ||
      task.status?.toLowerCase() == 'progress' ||
      task.status?.toLowerCase() == 'working'
    ).length;
}
