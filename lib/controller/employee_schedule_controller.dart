import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koji/models/task_model.dart';
import 'package:koji/services/api_client.dart';
import 'package:koji/services/employee_task_service.dart';

class EmployeeScheduleController extends GetxController {
  final RxList<TaskModel> _tasks = <TaskModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedDate = ''.obs;
  final Rx<TaskModel?> _selectedTask = Rx<TaskModel?>(null);

  RxList<TaskModel> get tasks => _tasks;
  RxBool get isLoading => _isLoading.value.obs;
  String get selectedDate => _selectedDate.value;
  Rx<TaskModel?> get selectedTask => _selectedTask;

  @override
  void onInit() {
    super.onInit();
    _selectedDate.value = DateTime.now().toString().split(' ')[0];
  }

  // Method to fetch tasks for a specific date
  Future<void> fetchTasksForDate(String date) async {
    _isLoading.value = true;
    try {
      final response = await ApiClient.getData(
        "/tasks/employ/list?date=${date}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = List<TaskModel>.from(
          response.body["data"]['attributes']["results"].map(
            (x) => TaskModel.fromJson(x),
          ),
        );

        _tasks.assignAll(data);
      } else {
        Get.snackbar(
          'Error',
          'Failed to load tasks for date: $date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error fetching tasks for date $date: $e');
      Get.snackbar(
        'Error',
        'Failed to load tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // New method to fetch single task details (for TaskDetailsScreen)
  Future<void> fetchTaskById(String taskId) async {
    _isLoading.value = true;
    try {
      // Find the task from the loaded tasks list
      final task = _tasks.firstWhere(
        (element) => element.id == taskId,
        orElse: () => TaskModel(
          id: '',
          createdBy: '',
          department: Department(name: ''),
          serviceCategory: Department(name: ''),
          customerName: '',
          customerNumber: '',
          customerAddress: '',
          assignDate: DateTime.now(),
          deadline: DateTime.now(),
          services: [],
          assignTo: '',
          otherAmount: 0,
          totalAmount: 0,
          status: '',
          attachments: [],
          notes: '',
          isDeleted: false,
          v: 0,
          difficulty: '',
          priority: '',
          progressPercent: 0,
          submitedDoc: [],
          isSubmited: false,
        ),
      );

      if (task.id!.isNotEmpty) {
        _selectedTask.value = task;
      } else {
        // If task is not found locally, try to fetch it from API
        // This would require an API endpoint to fetch individual task
        print("Task with ID $taskId not found locally");
      }
    } catch (e) {
      print('Error fetching task details: $e');
      Get.snackbar(
        'Error',
        'Failed to load task details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Accept task method (for TaskDetailsScreen)
  Future<void> acceptTask(String taskId) async {
    try {
      // Implementation would be in TaskDetailsController
      print('Accepting task: $taskId');
    } catch (e) {
      print('Error accepting task: $e');
      Get.snackbar(
        'Error',
        'Failed to accept task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Submit task method (for TaskDetailsScreen)
  Future<void> submitTask(String taskId) async {
    try {
      // Implementation would be in TaskDetailsController
      print('Submitting task: $taskId');
    } catch (e) {
      print('Error submitting task: $e');
      Get.snackbar(
        'Error',
        'Failed to submit task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Helper method to filter tasks by status
  List<TaskModel> getFilteredTasks(String status) {
    if (status.toLowerCase() == 'all') {
      return _tasks.toList();
    }
    return _tasks
        .where((task) => task.status?.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // Get count of tasks by status for tab display
  int getTaskCountByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _tasks.length;
    }
    return _tasks
        .where((task) => task.status?.toLowerCase() == status.toLowerCase())
        .length;
  }

  // Get all tasks for selected date regardless of status
  List<TaskModel> getAllTasksForSelectedDate() {
    return _tasks.toList();
  }
}
