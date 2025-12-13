import 'package:get/get_connect/http/src/response/response.dart';
import '../models/task_report_model.dart';
import '../services/api_client.dart';
import '../services/api_constants.dart';

class TaskReportService {
  // Get task report by ID
  static Future<TaskReportModel> getTaskReport(String taskId) async {
    try {
      final response = await ApiClient.getData(
        '${ApiConstants.taskReportEndPoint}$taskId',
      );

      if (response.statusCode == 200 && response.body != null) {
        return TaskReportModel.fromJson(response.body);
      } else {
        throw Exception(response.statusText ?? 'Failed to load task report');
      }
    } catch (e) {
      throw Exception('Error fetching task report: $e');
    }
  }
}