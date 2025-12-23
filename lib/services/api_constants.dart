class ApiConstants {
  // static const String baseUrl = "http://192.168.10.80:8080/api/v1";
  // static const String imageBaseUrl = "http://192.168.10.80:8080";

  // static const String baseUrl = "https://koji.sobhoy.com/api/v1/";
  // static const String imageBaseUrl = "https://koji.sobhoy.com";
  // static const String socketUrl = "https://wskogi.sobhoy.com";

  static const String baseUrl = "https://koji.sobhoy.com/api/v1/";
  static const String imageBaseUrl = "https://koji.sobhoy.com";
  static const String socketUrl = "https://koji.sobhoy.com";

  static const String signUpEndPoint = "/auth/register";
  static const String loginUpEndPoint = "/auth/login";
  static const String changePassword = "/auth/change-password";
  static const String verifyEmailEndPoint = "/auth/verify-email";
  static const String forgotPasswordEndPoint = "/auth/forgot-password";
  static const String resetPasswordEndPoint = "/auth/reset-password";

  // Attendance Endpoints
  static const String attendanceEmployeeList = "/attendances/employee-list";
  static const String attendanceCheckIn = "/attendances/check-in";
  static const String attendanceCheckOut = "/attendances/check-out";

  /// ==============================> Admin Api =======================================>

  static const String createTaskEndPoint = "/tasks";

  /// end point???????????
  static const String getAllDepartmentEndPoint =
      "/departments/list?sortBy=createdAt:desc";
  static const String getAllCategoriesEndPoint =
      "/categories/list?sortBy=createdAt:desc";
  static const String getAllEmployeeEndPoint =
      "/users/list?role=employee&page=1&limit=10&sortBy=createdAt:desc";
  static const String getAllServiceListEndPoint =
      "/services/list?sortBy=createdAt:desc";
  static const String taskEndPoint = "/tasks";

  static const String getAttendanceEndPoint = "/info/attendance/status";

  static const String employeeTaskList = "/tasks/employ/list";

  // Task Report Endpoints
  static const String taskReportEndPoint = "/tasks/";
  static const String getAllAttendanceEndPoint = "/attendances/list";
  static const String getTaskSummaryEndPoint = "/info/task/summary";
  static const String getAllTaskEndPoint = "/tasks/list?sortBy=createdAt:desc";
  static const String getEmployeeUserListEndPoint =
      "/users/list?role=employee&page=1&limit=10";
  static const String getProfileEndPoint = "/users/self/in";
  static const String updateProfileEndPoint = "/users/self/update";

  static const String helpSupportEndPoint = "/info/support";
  static const String transactionsEndPoint = "/info/transactions";
  static const String privacyPolicyEndPoint = "/info/privacy-policy";
  static const String termsConditionsEndPoint = "/info/terms-condition";
  static const String aboutUsEndPoint = "/info/about-us";

  static const String updateDepartmentEndPoint = "/departments/";
  static const String vehicleListEndPoint =
      "/vehicles/list?sortBy=createdAt:desc";
  static const String updateVehicleEndPoint = "/vehicles/";
  static const String updateDepartmentsEndPoint = "/departments/";
  static const String updateServiceEndPoint = "/services/";
  static const String deleteServiceEndPoint = "/services/";
  static const String updateCategoryEndPoint = "/categories/";
  static const String approveProfileEndPoint = "/users/approved/";
  static const String taskMonthEndPoint = "/tasks/monthly-summary";
  static const String allEmployeeTaskEndPoint =
      "/tasks/all-employee-task-status";
  static const String allListTaskEndPointTemplate = "/tasks/employ/list?";
  static const String taskDetailsEndPointTemplate = "/tasks/";
  static const String notificationsEndPoint = "/info/notifications";
}
