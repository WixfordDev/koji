import '../models/task_model.dart';
import '../services/api_client.dart';

class EmployeeTaskService {
  // Get employee task list
  static Future<TaskResponse> getEmployeeTaskList({String status = ''}) async {
    try {
      final response = await ApiClient.getData(
        '/tasks/employ/list?status=$status',
      );

      if (response.statusCode == 200 && response.body != null) {
        return TaskResponse.fromJson(response.body);
      } else {
        throw Exception(response.statusText ?? 'Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Error fetching task list: $e');
    }
  }
}
