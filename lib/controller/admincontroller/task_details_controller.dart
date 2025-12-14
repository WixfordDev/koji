import 'package:get/get.dart';
import 'package:koji/models/task_model.dart';
import 'package:koji/services/api_client.dart';
import 'package:koji/services/api_constants.dart';

class TaskDetailsController extends GetxController {
  final String taskId;

  final Rx<TaskModel?> taskDetails = Rx<TaskModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  TaskDetailsController({required this.taskId});

  @override
  void onInit() {
    super.onInit();
    fetchTaskDetails();
  }

  Future<void> fetchTaskDetails() async {
    isLoading.value = true;
    try {
      final response = await ApiClient.getData('${ApiConstants.taskEndPoint}/$taskId');
      if (response.statusCode == 200 && response.body != null) {
        taskDetails.value = TaskModel.fromJson(
          response.body['data']["attributes"],
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load task details',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error fetching task details: $e');
      Get.snackbar(
        'Error',
        'Failed to load task details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptTask() async {
    isSubmitting.value = true;
    try {
      final response = await ApiClient.postData(
        '${ApiConstants.taskEndPoint}/$taskId/accept',
        {},
      );
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Task accepted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Refresh task details
        await fetchTaskDetails();
      } else {
        Get.snackbar(
          'Error',
          'Failed to accept task',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error accepting task: $e');
      Get.snackbar(
        'Error',
        'Failed to accept task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitTask() async {
    isSubmitting.value = true;
    try {
      final response = await ApiClient.postData(
        '${ApiConstants.taskEndPoint}/$taskId/submit',
        {},
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Task submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Refresh task details
        await fetchTaskDetails();
        // Optionally, navigate back to calendar
        // Get.back();
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit task',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error submitting task: $e');
      Get.snackbar(
        'Error',
        'Failed to submit task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void refresh() {
    fetchTaskDetails();
  }
}