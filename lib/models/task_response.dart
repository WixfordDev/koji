// import 'task_model.dart';
// import 'dart:convert';

// /// Task Response Model for API responses
// class TaskResponse {
//   final int? code;
//   final String? message;
//   final TaskData? data;

//   TaskResponse({
//     this.code,
//     this.message,
//     this.data,
//   });

//   factory TaskResponse.fromJson(String jsonString) {
//     final parsedJson = json.decode(jsonString);
//     return TaskResponse.fromJsonObject(parsedJson);
//   }

//   factory TaskResponse.fromJsonObject(Map<String, dynamic> json) {
//     return TaskResponse(
//       code: json['code'] ?? 200,
//       message: json['message'] ?? 'Success',
//       data: json['data'] != null ? TaskData.fromJson(json['data']) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'code': code,
//       'message': message,
//       'data': data?.toJson(),
//     };
//   }
// }

// /// Contains the actual task data
// class TaskData {
//   final List<TaskModel>? results;
//   final int? page;
//   final int? limit;
//   final int? totalPages;
//   final int? totalResults;

//   TaskData({
//     this.results,
//     this.page,
//     this.limit,
//     this.totalPages,
//     this.totalResults,
//   });

//   factory TaskData.fromJson(Map<String, dynamic> json) {
//     List<TaskModel>? taskResults;
    
//     if (json['results'] != null) {
//       if (json['results'] is List) {
//         taskResults = (json['results'] as List)
//             .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
//             .toList();
//       }
//     }

//     return TaskData(
//       results: taskResults,
//       page: json['page'],
//       limit: json['limit'],
//       totalPages: json['totalPages'],
//       totalResults: json['totalResults'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'results': results?.map((e) => e.toJson()).toList(),
//       'page': page,
//       'limit': limit,
//       'totalPages': totalPages,
//       'totalResults': totalResults,
//     };
//   }
// }