import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../../helpers/toast_message_helper.dart';
import '../../models/admin-model/all_categories_model.dart' show AllCategoriesModel;
import '../../models/admin-model/all_department_model.dart';
import '../../models/admin-model/all_employee_model.dart';
import '../../models/admin-model/all_serviceList_model.dart';

class DepartmentController extends GetxController {

 /// ============================ Department =====================================

  RxBool getAllDepartmentModelLoading = false.obs;
  Rx<AllDepartmentModel> allDepartment = AllDepartmentModel().obs;

  getAllDepartment() async {
    getAllDepartmentModelLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getAllDepartmentEndPoint);

      if (response.statusCode == 200) {

        allDepartment.value = AllDepartmentModel.fromJson(response.body['data']['attributes']);
        getAllDepartmentModelLoading(false);



      } else if (response.statusCode == 404) {
        getAllDepartmentModelLoading(false);

      } else {
        getAllDepartmentModelLoading(false);

      }
    } catch (e) {
      getAllDepartmentModelLoading(false);

    }
  }

/// ================================== Categories =======================

  RxBool getCategoriesLoading = false.obs;
  Rx<AllCategoriesModel> categories = AllCategoriesModel().obs;

  getAllCategories() async {
    getCategoriesLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getAllCategoriesEndPoint);

      if (response.statusCode == 200) {

        categories.value = AllCategoriesModel.fromJson(response.body['data']['attributes']);
        getCategoriesLoading(false);



      } else if (response.statusCode == 404) {
        getCategoriesLoading(false);

      } else {
        getCategoriesLoading(false);

      }
    } catch (e) {
      getCategoriesLoading(false);

    }
  }


  /// ================================== All Employee =======================

  RxBool getEmployeeLoading = false.obs;
  Rx<AllEmployeeModel> employee = AllEmployeeModel().obs;

  getAllEmployee() async {
    getEmployeeLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getAllEmployeeEndPoint);

      if (response.statusCode == 200) {

        employee.value = AllEmployeeModel.fromJson(response.body['data']['attributes']);
        getEmployeeLoading(false);



      } else if (response.statusCode == 404) {
        getEmployeeLoading(false);

      } else {
        getEmployeeLoading(false);

      }
    } catch (e) {
      getEmployeeLoading(false);

    }
  }




  /// ================================== All Service List =======================

  RxBool getServiceLoading = false.obs;
  Rx<AllServiceListModel> serviceList = AllServiceListModel().obs;

  getAllServiceList() async {
    getServiceLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getAllServiceListEndPoint);

      if (response.statusCode == 200) {

        serviceList.value = AllServiceListModel.fromJson(response.body['data']['attributes']);
        getServiceLoading(false);



      } else if (response.statusCode == 404) {
        getServiceLoading(false);

      } else {
        getServiceLoading(false);

      }
    } catch (e) {
      getServiceLoading(false);

    }
  }



  /// ============================ Employee Request =====================================

  RxBool getEmployeeRequestLoading = false.obs;
  Rx<AllEmployeeModel> employeeRequest = AllEmployeeModel().obs;

  getEmployeeRequest() async {
    getEmployeeRequestLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getEmployeeUserListEndPoint);

      if (response.statusCode == 200) {
        employeeRequest.value = AllEmployeeModel.fromJson(response.body['data']['attributes']);
        getEmployeeRequestLoading(false);
      } else if (response.statusCode == 404) {
        getEmployeeRequestLoading(false);
      } else {
        getEmployeeRequestLoading(false);
      }
    } catch (e) {
      getEmployeeRequestLoading(false);
    }
  }

  //// ----------------------------------- Create Task --------------------------------

  var createNewLoading = false.obs;

  Future<String?> createNewTask({
    required String department,
    required String serviceCategory,
    required String customerName,
    required String customerNumber,
    required String customerAddress,
    required String assignDate,
    required String deadline,
    required List<String> services,
    required double otherAmount,
    required double totalAmount,
    required File? attachmentFile,
    required String assignTo,
    required String notes,
    required String priority,
    required String difficulty,
  }) async {
    createNewLoading(true);

    try {
      // Prepare the request body - Convert all values to String
      Map<String, String> body = {
        "department": department,
        "serviceCategory": serviceCategory,
        "customerName": customerName,
        "customerNumber": customerNumber,
        "customerAddress": customerAddress,
        "assignDate": assignDate, // ISO format: 2025-11-05T00:00:00.000Z
        "deadline": deadline, // ISO format: 2025-11-10T00:00:00.000Z
        "services": jsonEncode(services), // Convert array to JSON string
        "otherAmount": otherAmount.toString(),
        "totalAmount": totalAmount.toString(),
        "assignTo": assignTo,
        "notes": notes,
        "priority": priority, // 'low', 'medium', 'high'
        "difficulty": difficulty, // 'very easy', 'easy', 'moderate', 'hard', 'very hard'
      };

      // Prepare multipart body for file attachment
      List<MultipartBody> multipartBody = [];
      if (attachmentFile != null) {
        multipartBody.add(MultipartBody("attachments", attachmentFile));
      }

      // Make API call
      var response = await ApiClient.postMultipartData(
        ApiConstants.createTaskEndPoint,
        body,
        multipartBody: multipartBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        createNewLoading(false);
        ToastMessageHelper.showToastMessage("Task created successfully!");
        return "success";
      } else {
        createNewLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to create task. Please try again.",
          title: "Attention",
        );
        return null;
      }
    } catch (e) {
      createNewLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred: ${e.toString()}",
        title: "Error",
      );
      return null;
    }
  }











  /// ====== State variables for AdminCreateTaskScreen ======
  
  // Images for attachment
  RxList<File?> selectedImages = <File?>[].obs;
  
  // Selected values
  RxString selectedDepartment = ''.obs;
  RxString selectedCategory = ''.obs;
  RxList<String> selectedRoles = <String>[].obs;
  RxString selectedPriority = ''.obs;
  RxString selectedDifficulty = ''.obs;
  
  // Date and time
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);
  
  // Service list
  RxList<ServiceItemWithQuantity> selectedServiceList = <ServiceItemWithQuantity>[].obs;
  
  // Initialize
  @override
  void onInit() {
    super.onInit();
    // Initialize with 3 null image slots
    selectedImages.assignAll([null, null, null]);
  }
  
  
  // Methods to update state
  void updateImage(int index, File file) {
    selectedImages[index] = file;
    update();
  }
  
  void updateSelectedDepartment(String department) {
    selectedDepartment.value = department;
    update();
  }
  
  void updateSelectedCategory(String category) {
    selectedCategory.value = category;
    update();
  }
  
  void updateSelectedRoles(List<String> roles) {
    selectedRoles.assignAll(roles);
    update();
  }
  
  void addOrRemoveRole(String roleId) {
    if (selectedRoles.contains(roleId)) {
      selectedRoles.remove(roleId);
    } else {
      selectedRoles.add(roleId);
    }
    update();
  }
  
  void updateSelectedPriority(String priority) {
    selectedPriority.value = priority;
    update();
  }
  
  void updateSelectedDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
    update();
  }
  
  void updateSelectedServiceList(List<ServiceItemWithQuantity> serviceList) {
    selectedServiceList.assignAll(serviceList);
    update();
  }
  
  void addServiceItemWithQuantity(ServiceItemWithQuantity serviceItem) {
    selectedServiceList.add(serviceItem);
    update();
  }
  
  void removeServiceItemAt(int index) {
    selectedServiceList.removeAt(index);
    update();
  }
  
  void updateStartDate(DateTime? date) {
    startDate.value = date;
    update();
  }
  
  void updateEndDate(DateTime? date) {
    endDate.value = date;
    update();
  }
  
  void updateStartTime(TimeOfDay? time) {
    startTime.value = time;
    update();
  }
  
  void updateEndTime(TimeOfDay? time) {
    endTime.value = time;
    update();
  }
  
  void resetTaskForm() {
    // Clear text fields would be done in the UI layer
    selectedDepartment.value = '';
    selectedCategory.value = '';
    selectedRoles.clear();
    selectedPriority.value = '';
    selectedDifficulty.value = '';
    selectedServiceList.clear();
    selectedImages.assignAll([null, null, null]);
    startDate.value = null;
    endDate.value = null;
    startTime.value = null;
    endTime.value = null;
    update();
  }
  
  // Format date to ISO string
  String _formatDateToISO(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';

    // Create a DateTime object with the date and time
    DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return dateTime.toIso8601String();
  }
  
  // Calculate total amount based on selected services
  double calculateTotalAmount() {
    double total = 0.0;
    for (var serviceWithQty in selectedServiceList) {
      double price = double.tryParse(serviceWithQty.serviceItem.price ?? '0') ?? 0.0;
      int quantity = serviceWithQty.quantity;
      total += price * quantity;
    }
    return total;
  }
  
  // Validation method
  String? validateTaskForm({
    required String customerName,
    required String customerNumber,
    required String customerAddress,
    required String notes,
  }) {
    if (selectedDepartment.value.isEmpty) {
      return 'Please select a department';
    }

    if (selectedCategory.value.isEmpty) {
      return 'Please select a service category';
    }

    if (customerName.trim().isEmpty) {
      return 'Please enter customer name';
    }

    if (customerNumber.trim().isEmpty) {
      return 'Please enter customer number';
    }

    if (customerAddress.trim().isEmpty) {
      return 'Please enter customer address';
    }

    if (selectedRoles.isEmpty) {
      return 'Please select at least one employee to assign to';
    }

    if (startDate.value == null || startTime.value == null) {
      return 'Please select assign date and time';
    }

    if (endDate.value == null || endTime.value == null) {
      return 'Please select deadline date and time';
    }

    if (selectedPriority.value.isEmpty) {
      return 'Please select a priority';
    }

    if (selectedDifficulty.value.isEmpty) {
      return 'Please select a difficulty level';
    }

    if (selectedServiceList.isEmpty) {
      return 'Please select at least one service';
    }

    return null; // No validation errors
  }
}

// ServiceItemWithQuantity class (moved outside DepartmentController)
class ServiceItemWithQuantity {
  ServiceItem serviceItem;
  int quantity;

  ServiceItemWithQuantity({
    required this.serviceItem,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'name': serviceItem.name,
    'price': serviceItem.price,
    'quantity': quantity,
  };
}