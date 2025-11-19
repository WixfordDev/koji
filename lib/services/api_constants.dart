class ApiConstants {
  // static const String baseUrl = "http://192.168.10.80:8080/api/v1";
  // static const String imageBaseUrl = "http://192.168.10.80:8080";
  static const String baseUrl = "https://koji.sobhoy.com/api/v1/";
  static const String imageBaseUrl = "https://koji.sobhoy.com";
  static const String socketUrl = "https://koji.sobhoy.com";

  static const String signUpEndPoint = "/auth/register";
  static const String loginUpEndPoint = "/auth/login";
  static const String changePassword = "/auth/change-password";
  static const String verifyEmailEndPoint = "/auth/verify-email";
  static const String forgotPasswordEndPoint = "/auth/forgot-password";
  static const String resetPasswordEndPoint = "/auth/reset-password";


  /// ==============================> Admin Api =======================================>

  static const String createTaskEndPoint = "/departments";
  static const String getAllDepartmentEndPoint = "/departments/list?sortBy=createdAt:desc";
  static const String getAllCategoriesEndPoint = "/categories/list?sortBy=createdAt:desc";
  static const String getAllEmployeeEndPoint = "/users/list?role=employee&page=1&limit=10&sortBy=createdAt:desc";
  static const String getAllServiceListEndPoint = "/services/list?sortBy=createdAt:desc";
  static const String taskEndPoint = "/tasks";
  static const String getAttendanceEndPoint = "/info/attendance/status";






}
