import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koji/services/api_client.dart';
import '../services/employee_task_service.dart';
import '../models/history_model.dart';

class EmployeeHistoryController extends GetxController {
  var taskList = <HistoryModel>[].obs;
  var isLoading = true.obs;
  var selectedStatus = 'pending'.obs; // Default to pending

  Future<void> fetchTaskList({String? status}) async {
    try {
      isLoading.value = true;
      final response = await ApiClient.getData(
        "/tasks/employ/list?stats=${status ?? "pending"}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = List<HistoryModel>.from(
          response.body["data"]['attributes']["results"].map(
            (x) => HistoryModel.fromJson(x),
          ),
        );
        taskList.assignAll(data);
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
    fetchTaskList();
  }
}
