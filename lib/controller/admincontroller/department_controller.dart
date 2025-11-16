import 'dart:convert';
import 'dart:io';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:koji/core/app_constants.dart';
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

  }











