import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

class RouteHelper {
  // Auth Navigation
  static void goToSignIn(BuildContext context) {
    context.pushNamed(RoutePaths.signIn);
  }

  static void goToSignUp(BuildContext context) {
    context.pushNamed(RoutePaths.signUp);
  }

  static void goToForgotPassword(BuildContext context, {String? email}) {
    context.pushNamed(RoutePaths.forgotPassword, extra: {"email": email});
  }

  static void goToVerifyScreen(
    BuildContext context, {
    required String email,
    required String screenType,
  }) {
    context.pushNamed(
      RoutePaths.verifyScreen,
      extra: {"email": email, "screenType": screenType},
    );
  }

  static void goToResetPassword(BuildContext context) {
    context.pushNamed(RoutePaths.resetPassword);
  }

  // Employee Navigation
  static void goToEmployeeHome(BuildContext context) {
    context.pushNamed(RoutePaths.employeeHomeScreen);
  }

  static void goToEmployeeBottomNav(BuildContext context) {
    context.pushReplacement(RoutePaths.employeeBottomNavBar);
  }

  static void goToEmployeeCalendar(BuildContext context) {
    context.pushNamed(RoutePaths.employeeCalendarScreen);
  }

  static void goToEmployeeMyTask(BuildContext context) {
    context.pushNamed(RoutePaths.employeeMyTaskScreen);
  }

  static void goToEmployeeSubmitTask(BuildContext context) {
    context.pushNamed(RoutePaths.employeeSubmitTaskScreen);
  }

  static void goToEmployeeHistory(BuildContext context) {
    context.pushNamed(RoutePaths.employeeHistoryScreen);
  }

  static void goToEmployeeTaskReport(BuildContext context) {
    context.pushNamed(RoutePaths.employeeTaskReportScreen);
  }

  // Admin Navigation
  static void goToAdminBottomNav(BuildContext context) {
    context.pushNamed(RoutePaths.adminBottomNavBar);
  }

  static void goToAdminSchedule(BuildContext context) {
    context.pushNamed(RoutePaths.adminScheduleScreen);
  }

  static void goToAdminCompleteTask(BuildContext context) {
    context.pushNamed(RoutePaths.adminCompleteTaskScreen);
  }

  static void goToAdminAttendance(BuildContext context) {
    context.pushNamed(RoutePaths.adminAttendanceScreen);
  }

  // Profile Navigation
  static void goToProfile(BuildContext context) {
    context.pushNamed(RoutePaths.profileScreen);
  }

  static void goToMyProfile(BuildContext context) {
    context.pushNamed(RoutePaths.myProfileScreen);
  }

  static void goToChangePassword(BuildContext context) {
    context.pushNamed(RoutePaths.changePasswordScreen);
  }

  static void goToPrivacyPolicy(BuildContext context) {
    context.pushNamed(RoutePaths.privacyPolicyScreen);
  }

  static void goToTermsCondition(BuildContext context) {
    context.pushNamed(RoutePaths.termsConditionScreen);
  }

  static void goToHelpSupport(BuildContext context) {
    context.pushNamed(RoutePaths.helpSupportScreen);
  }

  // Common Navigation
  static void goToNotifications(BuildContext context) {
    context.pushNamed(RoutePaths.notificationScreen);
  }

  static void goToMessages(BuildContext context) {
    context.pushNamed(RoutePaths.messageListScreen);
  }

  // Helper Methods
  static void goBack(BuildContext context) {
    context.pop();
  }

  static void goToAndRemoveUntil(BuildContext context, String routeName) {
    context.go(routeName);
  }

  static void replaceWith(BuildContext context, String routeName) {
    context.pushReplacementNamed(routeName);
  }

  static void popUntilFirstRoute(BuildContext context) {
    context.go(RoutePaths.splash);
  }
}
