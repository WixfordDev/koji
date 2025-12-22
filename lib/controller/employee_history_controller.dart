import 'package:flutter/material.dart';
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
      final response = await ApiClient.getData("/tasks/employ/list");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = List<HistoryModel>.from(
          response.body["data"]['attributes']["results"].map(
            (x) => HistoryModel.fromJson(x),
          ),
        );
        taskList.assignAll(data);
        _applyFilter();
        update();

        isLoading.value = false;
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch task list: ${response.statusText}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to fetch task list: ${error.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
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
