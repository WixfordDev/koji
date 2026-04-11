import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../../helpers/toast_message_helper.dart';
import '../../models/admin-model/all_categories_model.dart'
    show AllCategoriesModel;
import '../../models/admin-model/all_department_model.dart';
import '../../models/admin-model/all_employee_model.dart';
import '../../models/admin-model/all_serviceList_model.dart';
import '../../models/admin-model/vechicle_model.dart';

class DepartmentController extends GetxController {
  /// ============================ Department =====================================

  RxBool getAllDepartmentModelLoading = false.obs;
  Rx<AllDepartmentModel> allDepartment = AllDepartmentModel().obs;

  getAllDepartment() async {
    getAllDepartmentModelLoading(true);
    try {
      var response = await ApiClient.getData(
        ApiConstants.getAllDepartmentEndPoint,
      );

      if (response.statusCode == 200) {
        allDepartment.value = AllDepartmentModel.fromJson(
          response.body['data']['attributes'],
        );
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
      var response = await ApiClient.getData(
        ApiConstants.getAllCategoriesEndPoint,
      );

      if (response.statusCode == 200) {
        categories.value = AllCategoriesModel.fromJson(
          response.body['data']['attributes'],
        );
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
      var response = await ApiClient.getData(
        ApiConstants.getAllEmployeeEndPoint,
      );

      if (response.statusCode == 200) {
        employee.value = AllEmployeeModel.fromJson(
          response.body['data']['attributes'],
        );
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
      var response = await ApiClient.getData(
        ApiConstants.getAllServiceListEndPoint,
      );

      if (response.statusCode == 200) {
        serviceList.value = AllServiceListModel.fromJson(
          response.body['data']['attributes'],
        );
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
      var response = await ApiClient.getData(
        ApiConstants.getEmployeeUserListEndPoint,
      );

      if (response.statusCode == 200) {
        employeeRequest.value = AllEmployeeModel.fromJson(
          response.body['data']['attributes'],
        );
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

  /// ============================ Vehicles =====================================

  RxBool getAllVehiclesModelLoading = false.obs;
  Rx<AllVehicleModel> allVehicles = AllVehicleModel().obs;

  getAllVehicles() async {
    getAllVehiclesModelLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.vehicleListEndPoint);

      if (response.statusCode == 200) {
        // Parse the entire data object, not just attributes
        allVehicles.value = AllVehicleModel.fromJson(
          response.body['data'],
        );
        getAllVehiclesModelLoading(false);
      } else if (response.statusCode == 404) {
        getAllVehiclesModelLoading(false);
      } else {
        getAllVehiclesModelLoading(false);
      }
    } catch (e) {
      print("Error loading vehicles: $e");
      getAllVehiclesModelLoading(false);
    }
  }

  /// ============================ Update Vehicle =====================================

  var updateVehicleLoading = false.obs;

  Future<bool> updateVehicle({
    required String vehicleId,
    required String name,
    String? description,
  }) async {
    updateVehicleLoading(true);
    try {
      var body = {
        "name": name,
        if (description != null) "description": description,
      };

      var response = await ApiClient.patch(
        "${ApiConstants.updateVehicleEndPoint}$vehicleId",
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        updateVehicleLoading(false);
        // Refresh the vehicle list after successful update
        await getAllVehicles();
        ToastMessageHelper.showToastMessage("Vehicle updated successfully!");
        return true;
      } else {
        updateVehicleLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to update vehicle. Please try again.",
          title: "Attention",
        );
        return false;
      }
    } catch (e) {
      updateVehicleLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred: ${e.toString()}",
        title: "Error",
      );
      return false;
    }
  }

  /// ============================ Update Department =====================================

  var updateDepartmentLoading = false.obs;

  Future<bool> updateDepartment({
    required String departmentId,
    required String name,
    String? description,
  }) async {
    updateDepartmentLoading(true);
    try {
      var body = {
        "name": name,
        if (description != null) "description": description,
      };

      var response = await ApiClient.patch(
        "${ApiConstants.updateDepartmentsEndPoint}$departmentId",
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        updateDepartmentLoading(false);
        // Refresh the department list after successful update
        await getAllDepartment();
        ToastMessageHelper.showToastMessage("Department updated successfully!");
        return true;
      } else {
        updateDepartmentLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to update department. Please try again.",
          title: "Attention",
        );
        return false;
      }
    } catch (e) {
      updateDepartmentLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred: ${e.toString()}",
        title: "Error",
      );
      return false;
    }
  }

  /// ============================ Update Service =====================================

  var updateServiceLoading = false.obs;

  Future<bool> updateService({
    required String serviceId,
    required String name,
    required int quantity,
    required String price,
  }) async {
    updateServiceLoading(true);
    try {
      var body = {"name": name, "quantity": quantity, "price": price};

      var response = await ApiClient.patch(
        "${ApiConstants.updateServiceEndPoint}$serviceId",
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        updateServiceLoading(false);
        // Refresh the service list after successful update
        await getAllServiceList();
        ToastMessageHelper.showToastMessage("Service updated successfully!");
        return true;
      } else {
        updateServiceLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to update service. Please try again.",
          title: "Attention",
        );
        return false;
      }
    } catch (e) {
      updateServiceLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred: ${e.toString()}",
        title: "Error",
      );
      return false;
    }
  }

  /// ============================ Update Category =====================================

  var updateCategoryLoading = false.obs;

  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    String? description,
  }) async {
    updateCategoryLoading(true);
    try {
      var body = {
        "name": name,
        if (description != null) "description": description,
      };

      var response = await ApiClient.patch(
        "${ApiConstants.updateCategoryEndPoint}$categoryId",
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        updateCategoryLoading(false);
        // Refresh the category list after successful update
        await getAllCategories();
        ToastMessageHelper.showToastMessage("Category updated successfully!");
        return true;
      } else {
        updateCategoryLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to update category. Please try again.",
          title: "Attention",
        );
        return false;
      }
    } catch (e) {
      updateCategoryLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred: ${e.toString()}",
        title: "Error",
      );
      return false;
    }
  }

  //// ----------------------------------- Create Task --------------------------------

  var createNewLoading = false.obs;

  Future<String?> createNewTask({
    required String departmentId,
    required String serviceCategoryId,
    required String vehicleId,
    required String customerName,
    required String customerNumber,
    required String customerAddress,
    required String assignTo, // Comma-separated string of employee IDs
    required String assignDate,
    required String deadline,
    required List<Map<String, dynamic>> services, // Changed from List<String>
    required double otherAmount,
    required double totalAmount,
    required File? attachmentFile,
    required String notes,
    // required String priority,
    // required String difficulty,
  }) async {
    createNewLoading(true);

    try {
      // Prepare the request body
      Map<String, String> body = {
        "department": departmentId,
        "serviceCategory": serviceCategoryId,
        if (vehicleId.isNotEmpty) "vehicle": vehicleId,
        "customerName": customerName,
        "customerNumber": customerNumber,
        "customerAddress": customerAddress,
        "assignTo": jsonEncode(assignTo.split(',').map((id) => id.trim()).toList()),
        "assignDate": assignDate,
        "deadline": deadline,
        "services": jsonEncode(
          services,
        ), // Already properly formatted as array of objects
        "otherAmount": otherAmount.toString(),
        "totalAmount": totalAmount.toString(),
        "notes": notes,
        // "priority": priority,
        // "difficulty": difficulty,
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
        // Extract clearest possible error from response
        String serverError;
        if (response.body is Map) {
          serverError = response.body['message']?.toString() ??
              response.body['error']?.toString() ??
              response.statusText ??
              'Server error (${response.statusCode})';
        } else {
          serverError = response.statusText?.isNotEmpty == true
              ? response.statusText!
              : 'Server error (${response.statusCode})';
        }
        print('====> createNewTask failed [${ response.statusCode}]: $serverError');
        return 'error:$serverError'; // prefix so caller can detect API error
      }
    } catch (e) {
      createNewLoading(false);
      print('====> createNewTask exception: $e');
      final msg = e.toString().contains('SocketException') || e.toString().contains('Connection')
          ? 'No internet connection. Please try again.'
          : 'Something went wrong. Please try again.';
      return 'error:$msg';
    }
  }

  /// ====== State variables for AdminCreateTaskScreen ======

  // Images for attachment
  RxList<File?> selectedImages = <File?>[].obs;

  // Selected values
  RxString selectedDepartment = ''.obs;
  RxString selectedCategory = ''.obs;
  RxString selectedVehicle = ''.obs; // New vehicle selection
  RxString selectedDepartmentId = ''.obs;
  RxString selectedCategoryId = ''.obs;
  RxString selectedVehicleId = ''.obs;
  RxList<String> selectedRoles = <String>[].obs;
  RxString selectedPriority = ''.obs;
  RxString selectedDifficulty = ''.obs;

  // Date and time
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);
  Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  // Service list
  RxList<ServiceItemWithQuantity> selectedServiceList =
      <ServiceItemWithQuantity>[].obs;

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

  void updateSelectedDepartment(String departmentId, String departmentName) {
    selectedDepartmentId.value = departmentId;
    selectedDepartment.value = departmentName;
    update();
  }

  void updateSelectedCategory(String categoryId, String categoryName) {
    selectedCategoryId.value = categoryId;
    selectedCategory.value = categoryName;
    update();
  }

  void updateSelectedVehicle(String vehicleId, String vehicleName) {
    selectedVehicleId.value = vehicleId;
    selectedVehicle.value = vehicleName;
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
    selectedVehicle.value = ''; // Reset selected vehicle
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
    DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dateTime.toIso8601String();
  }

  // Calculate total amount based on selected services
  double calculateTotalAmount() {
    double total = 0.0;
    for (var serviceWithQty in selectedServiceList) {
      double price =
          double.tryParse(serviceWithQty.serviceItem.price ?? '0') ?? 0.0;
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
    if (selectedDepartmentId.value.isEmpty) {
      return 'department'; // field key — screen shows friendly message
    }
    if (selectedCategoryId.value.isEmpty) {
      return 'category';
    }
    if (customerName.trim().isEmpty) {
      return 'customerName';
    }
    if (customerNumber.trim().isEmpty) {
      return 'customerNumber';
    }
    if (customerNumber.trim().length < 10) {
      return 'customerNumberLength';
    }
    if (customerAddress.trim().isEmpty) {
      return 'customerAddress';
    }
    if (selectedServiceList.isEmpty) {
      return 'services';
    }
    // if (selectedPriority.value.isEmpty) {
    //   return 'priority';
    // }

    return null;
  }

  /// ====== Task Creation Logic ======

  /// Method to format datetime to ISO string for API
  String formatDateTimeToISO(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';

    // Create a DateTime object with the date and time
    DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dateTime.toIso8601String();
  }

  /// Method to create a new task with all required info
  Future<String?> createNewTaskFromInputs({
    required String customerName,
    required String customerNumber,
    required String customerAddress,
    required String notes,
  }) async {
    createNewLoading(true);

    try {
      // Validate form first
      String? validationError = validateTaskForm(
        customerName: customerName,
        customerNumber: customerNumber,
        customerAddress: customerAddress,
        notes: notes,
      );

      if (validationError != null) {
        createNewLoading(false);
        return validationError;
      }

      // Format dates to ISO string
      String assignDate = formatDateTimeToISO(startDate.value, startTime.value);
      String deadlineDate = formatDateTimeToISO(endDate.value, endTime.value);

      // Prepare services list
      List<String> services = selectedServiceList
          .map((item) => '${item.serviceItem.name} (Qty: ${item.quantity})')
          .toList();

      // Calculate amounts
      double totalAmount = calculateTotalAmount();
      double otherAmount =
          0.0; // This might be for additional costs not included in services

      // Get the first selected attachment (or null if none selected)
      File? attachmentFile = selectedImages.firstWhere(
        (image) => image != null,
        orElse: () => null,
      );

      // Join all selected roles for assignTo (if multiple employees can be assigned)
      String assignTo = selectedRoles.join(
        ',',
      ); // Join with comma if multiple roles, or use first if single assignment needed

      // Prepare the request body
      Map<String, String> body = {
        "department": selectedDepartmentId.value, // Use ID instead of name
        "serviceCategory": selectedCategoryId.value, // Use ID instead of name
        if (selectedVehicleId.value.isNotEmpty)
          "vehicle": selectedVehicleId
              .value, // Use ID instead of name, only if not empty
        "customerName": customerName,
        "customerNumber": customerNumber,
        "customerAddress": customerAddress,
        "assignDate": assignDate, // ISO format: 2025-11-05T00:00:00.000Z
        "deadline": deadlineDate, // ISO format: 2025-11-10T00:00:00.000Z
        "services": jsonEncode(services), // Convert array to JSON string
        "otherAmount": otherAmount.toString(),
        "totalAmount": totalAmount.toString(),
        "assignTo": assignTo, // Send as comma-separated string
        "notes": notes,
        "priority": selectedPriority.value
            .toLowerCase(), // Convert to lowercase to match expected format
        "difficulty": selectedDifficulty.value
            .toLowerCase(), // Convert to lowercase to match expected format
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
        // Reset the form after successful creation
        resetTaskForm();
        return "success";
      } else {
        createNewLoading(false);
        return "Failed to create task. Please try again.";
      }
    } catch (e) {
      createNewLoading(false);
      return "An error occurred: ${e.toString()}";
    }
  }

  /// ============================ Delete Service =====================================

  var deleteServiceLoading = false.obs;

  Future<bool> deleteService({required String serviceId}) async {
    deleteServiceLoading(true);
    try {
      var response = await ApiClient.deleteData(
        "${ApiConstants.deleteServiceEndPoint}$serviceId",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        deleteServiceLoading(false);
        // Refresh the service list after successful deletion
        await getAllServiceList();
        ToastMessageHelper.showToastMessage("Service deleted successfully!");
        return true;
      } else {
        deleteServiceLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to delete service. Please try again.",
          title: "Attention",
        );
        return false;
      }
    } catch (e) {
      deleteServiceLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred: ${e.toString()}",
        title: "Error",
      );
      return false;
    }
  }
}

// ServiceItemWithQuantity class (moved outside DepartmentController)
class ServiceItemWithQuantity {
  ServiceItem serviceItem;
  int quantity;

  ServiceItemWithQuantity({required this.serviceItem, required this.quantity});

  Map<String, dynamic> toJson() => {
    'name': serviceItem.name,
    'price': serviceItem.price,
    'quantity': quantity,
  };
}
