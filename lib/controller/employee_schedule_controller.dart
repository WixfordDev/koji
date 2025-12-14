import 'package:get/get.dart';
import 'package:koji/models/task_model.dart';
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
      final response = await EmployeeTaskService.getEmployeeTaskList(date: date);
      if (response.code == 200) {
        _tasks.assignAll(response.data.attributes.results);
      } else {
        Get.snackbar('Error', 'Failed to load tasks for date: $date');
      }
    } catch (e) {
      print('Error fetching tasks for date $date: $e');
      Get.snackbar('Error', 'Failed to load tasks: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // New method to fetch single task details (for TaskDetailsScreen)
  Future<void> fetchTaskById(String taskId) async {
    _isLoading.value = true;
    try {
      // In a real implementation, this would call the API to get a single task
      // For now, we'll just return the first task if needed anywhere else
      print("Fetching task by ID: $taskId");
    } catch (e) {
      print('Error fetching task details: $e');
      Get.snackbar('Error', 'Failed to load task details: ${e.toString()}');
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
      Get.snackbar('Error', 'Failed to accept task: ${e.toString()}');
    }
  }

  // Submit task method (for TaskDetailsScreen)
  Future<void> submitTask(String taskId) async {
    try {
      // Implementation would be in TaskDetailsController
      print('Submitting task: $taskId');
    } catch (e) {
      print('Error submitting task: $e');
      Get.snackbar('Error', 'Failed to submit task: ${e.toString()}');
    }
  }

  // Helper method to filter tasks by status
  List<TaskModel> getFilteredTasks(String status) {
    if (status.toLowerCase() == 'all') {
      return _tasks.toList();
    }
    return _tasks
        .where((task) => task.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // Get count of tasks by status for tab display
  int getTaskCountByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _tasks.length;
    }
    return _tasks
        .where((task) => task.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  // Get all tasks for selected date regardless of status
  List<TaskModel> getAllTasksForSelectedDate() {
    return _tasks.toList();
  }
}
