// import '../models/task_response.dart';
// import '../services/api_client.dart';

// class EmployeeTaskService {
//   // Get employee task list
//   static Future<TaskResponse> getEmployeeTaskList({String status = '', String date = ''}) async {
//     try {
//       String queryParams = '';
//       if (status.isNotEmpty) {
//         queryParams += 'status=$status';
//       }

//       if (date.isNotEmpty) {
//         if (queryParams.isNotEmpty) {
//           queryParams += '&date=$date';
//         } else {
//           queryParams = 'date=$date';
//         }
//       }

//       final response = await ApiClient.getData(
//         '/tasks/employ/list?$queryParams',
//       );

//       if (response.statusCode == 200 && response.body != null) {
//         return TaskResponse.fromJson(response.body);
//       } else {
//         throw Exception(response.statusText ?? 'Failed to load tasks');
//       }
//     } catch (e) {
//       throw Exception('Error fetching task list: $e');
//     }
//   }
// }
