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
  // Attendance Endpoints
  static const String attendanceEmployeeList = "/attendances/employee-list";
  static const String attendanceCheckIn = "/attendances/check-in";
  static const String attendanceCheckOut = "/attendances/check-out";
}
