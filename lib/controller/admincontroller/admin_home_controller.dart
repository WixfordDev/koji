import 'dart:convert';
import 'dart:io';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../helpers/toast_message_helper.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../../models/admin-model/all_attendance_model.dart';
import '../../models/admin-model/all_attendance_list_model.dart';
import '../../models/admin-model/all_employee_model.dart';
import '../../models/admin-model/all_task_summary_model.dart';
import '../../models/admin-model/billing_docs_model.dart';
import '../../models/admin-model/get_alllist_task_model.dart';
import '../../models/admin-model/transaction_model.dart' hide Result;
import '../../models/admin-model/profile_model.dart';
import '../../models/admin-model/invoice_details_model.dart';


class AdminHomeController extends GetxController {

  /// ============================ Get All Attendance Summary =====================================

  RxBool getAllAttendanceLoading = false.obs;
  Rx<AllAttendanceSummaryModel> allAttendanceSummary = AllAttendanceSummaryModel().obs;

  getAllAttendanceSummary({String? date}) async {
    getAllAttendanceLoading(true);
    try {
      String formattedDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      String endpoint = "${ApiConstants.getAttendanceEndPoint}?date=$formattedDate";

      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        allAttendanceSummary.value = AllAttendanceSummaryModel.fromJson(response.body['data']['attributes']);
        getAllAttendanceLoading(false);
      } else if (response.statusCode == 404) {
        getAllAttendanceLoading(false);
        print("Attendance data not found for the specified date");
      } else {
        getAllAttendanceLoading(false);
        print("Error getting attendance: ${response.statusCode}");
      }
    } catch (e) {
      getAllAttendanceLoading(false);
      print("Exception in getAllAttendanceSummary: $e");
    }
  }

  /// ============================ Get All Task Summary =====================================


  RxBool getAllTaskSummaryLoading = false.obs;
  Rx<AllTaskSummaryModel> allTaskSummary = AllTaskSummaryModel().obs;

  getAllTaskSummary() async {
    getAllTaskSummaryLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getTaskSummaryEndPoint);

      if (response.statusCode == 200) {

        allTaskSummary.value = AllTaskSummaryModel.fromJson(response.body['data']['attributes']);
        getAllTaskSummaryLoading(false);
      } else if (response.statusCode == 404) {
        getAllTaskSummaryLoading(false);
      } else {
        getAllTaskSummaryLoading(false);
      }
    } catch (e) {
      getAllTaskSummaryLoading(false);
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











  /// ============================ Get All Attendance Individual Records =====================================

  RxBool getAdminAllAttendanceLoading = false.obs;
  Rx<AllAttendanceModel> allAttendance = AllAttendanceModel().obs;

  getAdminAllAttendance({int? month, int? year}) async {
    getAdminAllAttendanceLoading(true);
    try {
      String endpoint = ApiConstants.getAllAttendanceEndPoint;
      final params = <String>[];
      if (month != null) params.add('month=$month');
      if (year != null) params.add('year=$year');
      if (params.isNotEmpty) endpoint += '?${params.join('&')}';
      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        allAttendance.value = AllAttendanceModel.fromJson(response.body['data']['attributes']);
        getAdminAllAttendanceLoading(false);
      } else if (response.statusCode == 404) {
        allAttendance.value = AllAttendanceModel(results: [], totalResults: 0);
        getAdminAllAttendanceLoading(false);
      } else {
        allAttendance.value = AllAttendanceModel(results: [], totalResults: 0);
        getAdminAllAttendanceLoading(false);
        print("Error getting attendance: ${response.statusCode}");
      }
    } catch (e) {
      allAttendance.value = AllAttendanceModel(results: [], totalResults: 0);
      getAdminAllAttendanceLoading(false);
      print("Exception in getAdminAllAttendance: $e");
    }
  }



  /// ============================ Get All List Task  =====================================


  RxBool getAllListTaskLoading = false.obs;
  Rx<GetAllListTaskModel> getAllListTask = GetAllListTaskModel().obs;

  getAllListTasks() async {
    getAllListTaskLoading(true);
    try {
      final base = '${ApiConstants.getAllTaskEndPoint}&limit=100&page=1';
      final first = await ApiClient.getData(base);

      if (first.statusCode == 200) {
        final firstModel = GetAllListTaskModel.fromJson(first.body['data']['attributes']);
        final totalPages = firstModel.totalPages ?? 1;
        final allResults = List<Result>.from(firstModel.results ?? []);

        for (int page = 2; page <= totalPages; page++) {
          final res = await ApiClient.getData(
              '${ApiConstants.getAllTaskEndPoint}&limit=100&page=$page');
          if (res.statusCode == 200) {
            final model = GetAllListTaskModel.fromJson(res.body['data']['attributes']);
            allResults.addAll(model.results ?? []);
          }
        }

        getAllListTask.value = GetAllListTaskModel(
          results: allResults,
          page: firstModel.page,
          limit: firstModel.limit,
          totalPages: firstModel.totalPages,
          totalResults: firstModel.totalResults,
        );
      }
    } catch (e) {
      print('getAllListTasks error: $e');
    } finally {
      getAllListTaskLoading(false);
    }
  }



  /// ============================ Update Task =====================================

  RxBool updateTaskLoading = false.obs;

  Future<String?> updateTask({
    required String taskId,
    required String departmentId,
    required String serviceCategoryId,
    String? vehicleId,
    required String customerName,
    required String customerNumber,
    required String customerAddress,
    required List<String> assignTo,
    required String assignDate,
    required String deadline,
    required List<Map<String, dynamic>> services,
    required double otherAmount,
    required double totalAmount,
    required String notes,
    required String priority,
    required String difficulty,
    File? attachmentFile,
  }) async {
    updateTaskLoading(true);
    try {
      Map<String, String> body = {
        "department": departmentId,
        "serviceCategory": serviceCategoryId,
        if (vehicleId != null && vehicleId.isNotEmpty) "vehicle": vehicleId,
        "customerName": customerName,
        "customerNumber": customerNumber,
        "customerAddress": customerAddress,
        "assignDate": assignDate,
        "deadline": deadline,
        "services": jsonEncode(services),
        "otherAmount": otherAmount.toString(),
        "totalAmount": totalAmount.toString(),
        "notes": notes,
        "priority": priority,
        "difficulty": difficulty,
      };

      // Send assignTo as indexed fields (assignTo[0], assignTo[1], ...)
      // because the update endpoint uses Object.assign directly without JSON.parse
      for (int i = 0; i < assignTo.length; i++) {
        body['assignTo[$i]'] = assignTo[i].trim();
      }

      List<MultipartBody> multipartBody = [];
      if (attachmentFile != null) {
        multipartBody.add(MultipartBody("attachments", attachmentFile));
      }

      var response = await ApiClient.patchMultipartData(
        ApiConstants.updateTaskEndPoint(taskId),
        body,
        multipartBody: multipartBody.isEmpty ? null : multipartBody,
      );

      updateTaskLoading(false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessageHelper.showToastMessage("Task updated successfully!");
        getAllListTasks();
        return "success";
      } else {
        String serverError = response.body is Map
            ? response.body['message']?.toString() ?? 'Server error (${response.statusCode})'
            : 'Server error (${response.statusCode})';
        return 'error:$serverError';
      }
    } catch (e) {
      updateTaskLoading(false);
      return 'error:${e.toString()}';
    }
  }

  /// ============================ Get Transactions  =====================================


  RxBool getTransactionLoading = false.obs;
  Rx<TransactionModel> transaction = TransactionModel().obs;

  getTransaction() async {
    getTransactionLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.transactionsEndPoint);

      if (response.statusCode == 200) {

        transaction.value = TransactionModel.fromJson(response.body['data']['attributes']);
        getTransactionLoading(false);
      } else if (response.statusCode == 404) {
        getTransactionLoading(false);
      } else {
        getTransactionLoading(false);
      }
    } catch (e) {
      getTransactionLoading(false);
    }
  }


// In admin_home_controller.dart

  RxBool getBillingDocsLoading = false.obs;
  Rx<BillingDocsModel> billingDocs = BillingDocsModel().obs;  // ✅ BillingDocsModel

  getBillingDocs({String type = ''}) async {
    getBillingDocsLoading(true);
    try {
      final String base = type.isEmpty
          ? '/info/billing-docs?sortBy=createdAt:desc'
          : '/info/billing-docs?type=$type&sortBy=createdAt:desc';

      // Fetch page 1 to get totalPages
      final first = await ApiClient.getData('$base&limit=100&page=1');
      if (first.statusCode != 200) return;

      final firstModel = BillingDocsModel.fromJson(first.body['data']['attributes']);
      final totalPages = firstModel.totalPages ?? 1;
      final allResults = List<BillingDocResult>.from(firstModel.results ?? []);

      // Fetch remaining pages if any
      for (int page = 2; page <= totalPages; page++) {
        final res = await ApiClient.getData('$base&limit=100&page=$page');
        if (res.statusCode == 200) {
          final model = BillingDocsModel.fromJson(res.body['data']['attributes']);
          allResults.addAll(model.results ?? []);
        }
      }

      billingDocs.value = BillingDocsModel(
        results: allResults,
        page: firstModel.page,
        limit: firstModel.limit,
        totalPages: firstModel.totalPages,
        totalResults: firstModel.totalResults,
      );
    } catch (e) {
      print('getBillingDocs error: $e');
    } finally {
      getBillingDocsLoading(false);
    }
  }

  /// ============================ Approve Employee  =====================================

  RxBool approveEmployeeLoading = false.obs;

  Future<bool> approveEmployee({required String employeeId}) async {
    approveEmployeeLoading(true);
    try {
      var response = await ApiClient.postData(
        "${ApiConstants.approveProfileEndPoint}$employeeId",
        {}, // Empty body for the post request
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        approveEmployeeLoading(false);
        // Refresh the employee request list after successful approval
        getEmployeeRequest();
        return true;
      } else {
        approveEmployeeLoading(false);
        print("Error approving employee: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      approveEmployeeLoading(false);
      print("Exception in approveEmployee: $e");
      return false;
    }
  }


  /// ============================ Delete Employee  =====================================

  RxBool deleteEmployeeLoading = false.obs;

  Future<bool> deleteEmployee({required String employeeId}) async {
    deleteEmployeeLoading(true);
    try {
      var response = await ApiClient.deleteData(
        ApiConstants.deleteUserEndPoint(employeeId),
      );
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        deleteEmployeeLoading(false);
        getEmployeeRequest();
        return true;
      } else {
        deleteEmployeeLoading(false);
        print("Error deleting employee: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      deleteEmployeeLoading(false);
      print("Exception in deleteEmployee: $e");
      return false;
    }
  }

  /// ============================ Update Employee (Approve) =====================================

  RxBool updateEmployeeLoading = false.obs;

  Future<bool> updateEmployeeApproval({
    required String employeeId,
    required Map<String, dynamic> body,
  }) async {
    updateEmployeeLoading(true);
    try {
      var response = await ApiClient.patch(
        ApiConstants.updateUserEndPoint(employeeId),
        body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        updateEmployeeLoading(false);
        getEmployeeRequest();
        return true;
      } else {
        updateEmployeeLoading(false);
        print("Error updating employee: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      updateEmployeeLoading(false);
      print("Exception in updateEmployeeApproval: $e");
      return false;
    }
  }

  /// ============================ Create Invoice  =====================================

  RxBool createInvoiceLoading = false.obs;
  String? invoicePdfPath; // Store PDF path from invoice creation response

  Future<Map<String, dynamic>?> createInvoice(Map<String, dynamic> requestBody) async {
    createInvoiceLoading(true);
    try {
      var response = await ApiClient.postData(
        ApiConstants.invoiceEndPoint,
        requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        createInvoiceLoading(false);
        print("Invoice created successfully");
        // Extract and store PDF path from response
        invoicePdfPath = response.body['data']?['attributes']?['pdfPath'];
        // Refresh transaction list after successful creation
        getTransaction();
        return response.body;
      } else {
        createInvoiceLoading(false);
        print("Error creating invoice: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      createInvoiceLoading(false);
      print("Exception in createInvoice: $e");
      return null;
    }
  }

  /// ============================ Create Quotation  =====================================

  RxBool createQuotationLoading = false.obs;
  String? quotationPdfPath; // Store PDF path from quotation creation response

  Future<Map<String, dynamic>?> createQuotation(Map<String, dynamic> requestBody) async {
    createQuotationLoading(true);
    try {
      var response = await ApiClient.postData(
        ApiConstants.quotationEndPoint,
        requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        createQuotationLoading(false);
        print("Quotation created successfully");
        // Extract and store PDF path from response
        quotationPdfPath = response.body['data']?['attributes']?['pdfPath'];
        // Refresh transaction list after successful creation
        getTransaction();
        return response.body;
      } else {
        createQuotationLoading(false);
        print("Error creating quotation: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      createQuotationLoading(false);
      print("Exception in createQuotation: $e");
      return null;
    }
  }


  /// ============================ Get Profile =====================================

  RxBool getProfileLoading = false.obs;
  Rx<ProfileModel> profileData = ProfileModel().obs;

  getProfile() async {
    getProfileLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getProfileEndPoint);

      if (response.statusCode == 200) {
        profileData.value = ProfileModel.fromJson(response.body['data']['attributes']);
        getProfileLoading(false);
      } else if (response.statusCode == 404) {
        getProfileLoading(false);
      } else {
        getProfileLoading(false);
      }
    } catch (e) {
      getProfileLoading(false);
    }
  }


  /// ============================ Get Billing Details =====================================

  RxBool getBillingDetailsLoading = false.obs;
  Rx<InvoiceDetailsModel> billingDetails = InvoiceDetailsModel().obs; // Using the new model

  getBillingDetails(String id) async {
    getBillingDetailsLoading(true);
    try {
      String endpoint = "/info/billing/$id";
      var response = await ApiClient.getData(endpoint);

      if (response.statusCode == 200) {
        billingDetails.value = InvoiceDetailsModel.fromJson(response.body['data']['attributes']);
        getBillingDetailsLoading(false);
      } else if (response.statusCode == 404) {
        getBillingDetailsLoading(false);
      } else {
        getBillingDetailsLoading(false);
      }
    } catch (e) {
      getBillingDetailsLoading(false);
    }
  }

}

