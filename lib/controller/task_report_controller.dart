import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_report_model.dart';
import '../services/task_report_service.dart';

class TaskReportController extends GetxController {
  var taskReport = Rxn<TaskReportAttributes>();
  var isLoading = true.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchTaskReport(String taskId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final response = await TaskReportService.getTaskReport(taskId);
      taskReport.value = response.data.attributes;
    } catch (e, s) {
      error.value = e.toString();
      // Using a more explicit snackbar configuration to avoid null reference errors
      print('Error fetching task report: $e\n$s');
      Get.snackbar(
        "Error",
        "Failed to fetch task report: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
