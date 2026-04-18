import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koji/models/task_model.dart';
import 'package:koji/services/api_client.dart';

class EmployeeScheduleController extends GetxController {
  final RxList<TaskModel> _tasks = <TaskModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedDate = ''.obs;
  final Rx<TaskModel?> _selectedTask = Rx<TaskModel?>(null);

  // Cache: date string -> task list (used for calendar indicators on all dates)
  final Map<String, List<TaskModel>> _tasksByDate = {};
  final Set<String> _fetchedMonths = {};

  RxList<TaskModel> get tasks => _tasks;
  RxBool get isLoading => _isLoading;
  String get selectedDate => _selectedDate.value;
  Rx<TaskModel?> get selectedTask => _selectedTask;

  @override
  void onInit() {
    super.onInit();
    _selectedDate.value = DateTime.now().toString().split(' ')[0];
  }

  // Fetch tasks for a specific date (selected day)
  Future<void> fetchTasksForDate(String date) async {
    _selectedDate.value = date;
    _isLoading.value = true;
    update();
    try {
      final response = await ApiClient.getData(
        "/tasks/employ/list?date=$date",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = List<TaskModel>.from(
          response.body["data"]['attributes']["results"].map(
            (x) => TaskModel.fromJson(x),
          ),
        );
        _tasks.assignAll(data);
        _tasksByDate[date] = data; // cache for calendar indicators
      } else {
        _tasks.clear();
        _tasksByDate[date] = [];
        Get.snackbar(
          'Error',
          'Failed to load tasks for date: $date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _tasks.clear();
      _tasksByDate[date] = [];
      Get.snackbar(
        'Error',
        'Failed to load tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // Fetch all dates of a month in background for calendar indicators
  Future<void> fetchMonthTasks(int year, int month) async {
    final monthKey = '$year-${month.toString().padLeft(2, '0')}';
    if (_fetchedMonths.contains(monthKey)) return;
    _fetchedMonths.add(monthKey);

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<String> datesToFetch = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      if (!_tasksByDate.containsKey(date)) {
        datesToFetch.add(date);
      }
    }

    // Fetch in batches of 5 to avoid overwhelming server
    for (int i = 0; i < datesToFetch.length; i += 5) {
      final batch = datesToFetch.sublist(
        i,
        i + 5 > datesToFetch.length ? datesToFetch.length : i + 5,
      );
      await Future.wait(batch.map((d) => _fetchAndCacheDate(d)));
      update();
    }
  }

  Future<void> _fetchAndCacheDate(String date) async {
    try {
      final response = await ApiClient.getData(
        '/tasks/employ/list?date=$date',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = List<TaskModel>.from(
          response.body['data']['attributes']['results'].map(
            (x) => TaskModel.fromJson(x),
          ),
        );
        _tasksByDate[date] = data;
      } else {
        _tasksByDate[date] = [];
      }
    } catch (_) {
      _tasksByDate[date] = [];
    }
  }

  // Fetch single task details via API (populated assignTo + vehicle)
  Future<void> fetchTaskById(String taskId) async {
    _isLoading.value = true;
    update();
    try {
      final response = await ApiClient.getData('/tasks/$taskId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body['data']?['attributes'] ?? response.body['data'];
        if (data != null) {
          _selectedTask.value = TaskModel.fromJson(data);
        }
      } else {
        _safeSnackbar('Error', 'Failed to load task details');
      }
    } catch (e) {
      debugPrint('fetchTaskById error: $e');
      _safeSnackbar('Error', 'Failed to load task details');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void _safeSnackbar(String title, String message) {
    try {
      if (Get.isOverlaysOpen || Get.key.currentContext != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {
      debugPrint('Snackbar error suppressed: $title — $message');
    }
  }

  // Accept task method
  Future<bool> acceptTask(String taskId) async {
    try {
      final response = await ApiClient.postData('/tasks/$taskId/accept', {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update selectedTask locally so UI reflects new status immediately
        final current = _selectedTask.value;
        if (current != null) {
          _selectedTask.value = TaskModel(
            customerSignature: current.customerSignature,
            id: current.id,
            createdBy: current.createdBy,
            department: current.department,
            serviceCategory: current.serviceCategory,
            vehicle: current.vehicle,
            customerName: current.customerName,
            customerNumber: current.customerNumber,
            customerAddress: current.customerAddress,
            customerEmail: current.customerEmail,
            assignDate: current.assignDate,
            deadline: current.deadline,
            services: current.services,
            priority: current.priority,
            difficulty: current.difficulty,
            assignTo: current.assignTo,
            otherAmount: current.otherAmount,
            totalAmount: current.totalAmount,
            status: 'progress',
            attachments: current.attachments,
            submitedDoc: current.submitedDoc,
            isSubmited: current.isSubmited,
            notes: current.notes,
            isDeleted: current.isDeleted,
            invoicePath: current.invoicePath,
            createdAt: current.createdAt,
            updatedAt: current.updatedAt,
            v: current.v,
            progressPercent: current.progressPercent,
          );
        }
        if (_selectedDate.value.isNotEmpty) {
          fetchTasksForDate(_selectedDate.value);
        }
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.statusText ?? 'Failed to accept task',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Submit task method
  Future<void> submitTask(String taskId) async {
    try {
      print('Submitting task: $taskId');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  List<TaskModel> getFilteredTasks(String status) {
    if (status.toLowerCase() == 'all') return _tasks.toList();
    return _tasks
        .where((task) => task.status?.toLowerCase() == status.toLowerCase())
        .toList();
  }

  int getTaskCountByStatus(String status) {
    if (status.toLowerCase() == 'all') return _tasks.length;

    if (status.toLowerCase() == 'complete') {
      return _tasks.where((task) {
        final s = task.status?.toLowerCase() ?? '';
        return s == 'complete' || s == 'completed' || s == 'done';
      }).length;
    }

    if (status.toLowerCase() == 'inprogress') {
      return _tasks.where((task) {
        final s = task.status?.toLowerCase() ?? '';
        return s == 'inprogress' || s == 'in progress' || s == 'progress';
      }).length;
    }

    return _tasks.where((task) {
      return task.status?.toLowerCase() == status.toLowerCase();
    }).length;
  }

  List<TaskModel> getAllTasksForSelectedDate() => _tasks.toList();

  // Uses cache so all calendar dates show indicators
  List<TaskModel> getTasksForDay(DateTime day) {
    final formattedDate =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _tasksByDate[formattedDate] ?? [];
  }
}
