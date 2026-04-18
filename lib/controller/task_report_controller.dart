import 'package:get/get.dart';
import '../models/task_report_model.dart';
import '../services/task_report_service.dart';

class TaskReportController extends GetxController {
  var taskReport = Rxn<TaskReportAttributes>();
  var isLoading = true.obs;
  var error = ''.obs;

  Future<void> fetchTaskReport(String taskId) async {
    try {
      isLoading.value = true;
      error.value = '';
      final response = await TaskReportService.getTaskReport(taskId);
      taskReport.value = response.data.attributes;
    } catch (e, s) {
      error.value = e.toString();
      print('Error fetching task report: $e\n$s');
    } finally {
      isLoading.value = false;
    }
  }
}
