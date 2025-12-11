import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth Screens
import 'package:koji/features/authentication/presentation/forgot_password_screen.dart';
import 'package:koji/features/authentication/presentation/login_screen.dart';
import 'package:koji/features/authentication/presentation/onboarding_screen.dart';
import 'package:koji/features/authentication/presentation/reset_password_screen.dart';
import 'package:koji/features/authentication/presentation/signup_screen.dart';
import 'package:koji/features/authentication/presentation/splash_screen.dart';
import 'package:koji/features/authentication/presentation/verify_screen/verify_screen.dart';
import 'package:koji/models/chat_model.dart';

// Admin Screens
import '../features/admin_bottom_navbar/admin_bottom_navbar.dart';
import '../features/admin_home/presentation/admin_attendance_screen.dart';
import '../features/admin_home/presentation/admin_create_task_screen.dart';
import '../features/admin_home/presentation/admin_employee_request_screen.dart';
import '../features/admin_home/presentation/admin_mytask_screen.dart';
import '../features/admin_schedule/presentation/admin_complete_task_screen.dart';
import '../features/admin_schedule/presentation/admin_schedule.dart';
import '../features/admin_map/admin_map_screen.dart';

// Employee Screens
import '../features/bottom_navbar/presentation/bottom_navbar_screen.dart';
import '../features/employee_home/presentation/employee_home_screen.dart';
import '../features/employee_history/presentation/employee_history_screen.dart';
import '../features/employee_history/presentation/taskreport_screen.dart';
import '../features/employee_schedule/presentation/calendar_screen.dart';
import '../features/employee_schedule/presentation/my_task_screen.dart';
import '../features/employee_schedule/presentation/submit_task_screen.dart';

// Profile Screens
import '../features/profile/presentation/change_password_screen.dart';
import '../features/profile/presentation/help_support_screen.dart';
import '../features/profile/presentation/my_profile_screen.dart';
import '../features/profile/presentation/privacy_policy_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/terms_condition_screen.dart';

// Common Screens
import '../features/message/presentation/chat_screen.dart';
import '../features/message/presentation/message_screen.dart';
import '../features/notification/presentation/notification_screen.dart';

// Route Paths
import './route_paths.dart';

/* Helper to let GoRouter refresh when Bloc state changes */
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _sub;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // sub = stream.asBroadcastStream().listen(() => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/* Central router builder you can call from main.dart */
class AppRouter {
  static final List<GoRoute> _authRoutes = [
    GoRoute(path: RoutePaths.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: RoutePaths.signIn, builder: (_, __) => LoginScreen()),
    GoRoute(
      path: RoutePaths.signUp,
      builder: (_, __) => const RegistrationScreen(),
    ),
    GoRoute(
      path: RoutePaths.onboarding,
      builder: (_, __) => OnboardingScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      builder: (_, __) => ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.resetPassword,
      builder: (_, __) => ResetPasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.verifyScreen,
      builder: (_, __) => const VerifyScreen(),
    ),
  ];

  static final List<GoRoute> _employeeRoutes = [
    GoRoute(
      path: RoutePaths.employeeHomeScreen,
      builder: (_, __) => EmployeeHomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.employeeHistoryScreen,
      builder: (_, __) => HistoryScreen(),
    ),
    GoRoute(
      path: RoutePaths.employeeTaskReportScreen,
      builder: (_, __) => TaskReportScreen(),
    ),
    GoRoute(
      path: RoutePaths.employeeCalendarScreen,
      builder: (_, __) => CalendarScreen(),
    ),
    GoRoute(
      path: RoutePaths.employeeMyTaskScreen,
      builder: (_, __) => MyTaskScreen(),
    ),
    GoRoute(
      path: RoutePaths.employeeSubmitTaskScreen,
      builder: (_, __) => SubmitTaskScreen(),
    ),
    GoRoute(
      path: RoutePaths.employeeBottomNavBar,
      builder: (_, __) => BottomNavBar(),
    ),
  ];

  static final List<GoRoute> _adminRoutes = [
    GoRoute(
      path: RoutePaths.adminBottomNavBar,
      builder: (_, __) => AdminBottomNavBar(),
    ),
    GoRoute(
      path: RoutePaths.adminScheduleScreen,
      builder: (_, __) => AdminScheduleScreen(),
    ),
    GoRoute(
      path: RoutePaths.adminCompleteTaskScreen,
      builder: (_, __) => AdminCompleteTaskScreen(),
    ),
    GoRoute(
      path: RoutePaths.adminAttendanceScreen,
      builder: (_, __) => AdminAttendanceScreen(),
    ),
  ];

  static final List<GoRoute> _profileRoutes = [
    GoRoute(
      path: RoutePaths.profileScreen,
      builder: (_, __) => ProfileScreen(),
    ),
    GoRoute(
      path: RoutePaths.myProfileScreen,
      builder: (_, __) => MyProfileScreen(),
    ),
    GoRoute(
      path: RoutePaths.changePasswordScreen,
      builder: (_, __) => ChangePasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.privacyPolicyScreen,
      builder: (_, __) => PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: RoutePaths.termsConditionScreen,
      builder: (_, __) => TermsConditionScreen(),
    ),
    GoRoute(
      path: RoutePaths.helpSupportScreen,
      builder: (_, __) => HelpSupportScreen(),
    ),
  ];

  static final List<GoRoute> _commonRoutes = [
    GoRoute(
      path: RoutePaths.messageListScreen,
      builder: (_, __) => MessageListScreen(),
    ),
    GoRoute(
      path: RoutePaths.notificationScreen,
      builder: (_, __) => NotificationScreen(),
    ),
  ];

  static GoRouter build() {
    return GoRouter(
      initialLocation: RoutePaths.splash,
      debugLogDiagnostics: true,
      routes: [
        // Auth Routes
        GoRoute(
          path: RoutePaths.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.signIn,
          name: RoutePaths.signIn,
          builder: (_, __) => LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.signUp,
          name: RoutePaths.signUp,
          builder: (_, __) => const RegistrationScreen(),
        ),
        GoRoute(
          path: RoutePaths.onboarding,
          name: RoutePaths.onboarding,
          builder: (_, __) => OnboardingScreen(),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          name: RoutePaths.forgotPassword,
          builder: (_, __) => ForgotPasswordScreen(),
        ),
        GoRoute(
          path: RoutePaths.resetPassword,
          name: RoutePaths.resetPassword,
          builder: (_, __) => ResetPasswordScreen(),
        ),
        GoRoute(
          path: RoutePaths.verifyScreen,
          name: RoutePaths.verifyScreen,
          builder: (_, __) => const VerifyScreen(),
        ),

        // Employee Routes
        GoRoute(
          path: RoutePaths.employeeHomeScreen,
          name: RoutePaths.employeeHomeScreen,
          builder: (_, __) => EmployeeHomeScreen(),
        ),
        GoRoute(
          path: RoutePaths.employeeHistoryScreen,
          name: RoutePaths.employeeHistoryScreen,
          builder: (_, __) => HistoryScreen(),
        ),
        GoRoute(
          path: RoutePaths.employeeTaskReportScreen,
          name: RoutePaths.employeeTaskReportScreen,
          builder: (_, __) => TaskReportScreen(),
        ),
        GoRoute(
          path: RoutePaths.employeeCalendarScreen,
          name: RoutePaths.employeeCalendarScreen,
          builder: (_, __) => CalendarScreen(),
        ),
        GoRoute(
          path: RoutePaths.employeeMyTaskScreen,
          name: RoutePaths.employeeMyTaskScreen,
          builder: (_, __) => MyTaskScreen(),
        ),
        GoRoute(
          path: RoutePaths.employeeSubmitTaskScreen,
          name: RoutePaths.employeeSubmitTaskScreen,
          builder: (_, __) => SubmitTaskScreen(),
        ),
        GoRoute(
          path: RoutePaths.employeeBottomNavBar,
          name: RoutePaths.employeeBottomNavBar,
          builder: (_, __) => BottomNavBar(),
        ),

        // Admin Routes
        GoRoute(
          path: RoutePaths.adminBottomNavBar,
          name: RoutePaths.adminBottomNavBar,
          builder: (_, __) => AdminBottomNavBar(),
        ),
        GoRoute(
          path: RoutePaths.adminScheduleScreen,
          name: RoutePaths.adminScheduleScreen,
          builder: (_, __) => AdminScheduleScreen(),
        ),
        GoRoute(
          path: RoutePaths.adminCompleteTaskScreen,
          name: RoutePaths.adminCompleteTaskScreen,
          builder: (_, __) => AdminCompleteTaskScreen(),
        ),
        GoRoute(
          path: RoutePaths.adminAttendanceScreen,
          name: RoutePaths.adminAttendanceScreen,
          builder: (_, __) => AdminAttendanceScreen(),
        ),

        // Profile Routes
        GoRoute(
          path: RoutePaths.profileScreen,
          name: RoutePaths.profileScreen,
          builder: (_, __) => ProfileScreen(),
        ),
        GoRoute(
          path: RoutePaths.myProfileScreen,
          name: RoutePaths.myProfileScreen,
          builder: (_, __) => MyProfileScreen(),
        ),
        GoRoute(
          path: RoutePaths.changePasswordScreen,
          name: RoutePaths.changePasswordScreen,
          builder: (_, __) => ChangePasswordScreen(),
        ),
        GoRoute(
          path: RoutePaths.privacyPolicyScreen,
          name: RoutePaths.privacyPolicyScreen,
          builder: (_, __) => PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: RoutePaths.termsConditionScreen,
          name: RoutePaths.termsConditionScreen,
          builder: (_, __) => TermsConditionScreen(),
        ),
        GoRoute(
          path: RoutePaths.helpSupportScreen,
          name: RoutePaths.helpSupportScreen,
          builder: (_, __) => HelpSupportScreen(),
        ),

        // Common Routes
        GoRoute(
          path: RoutePaths.messageListScreen,
          name: RoutePaths.messageListScreen,
          builder: (_, __) => MessageListScreen(),
        ),
        GoRoute(
          path: RoutePaths.notificationScreen,

          builder: (_, __) => NotificationScreen(),
        ),
        GoRoute(
          path: RoutePaths.chatScreen,
          name: RoutePaths.chatScreen,
          builder: (_, state) {
            // Get the conversation from the state.extra
            final conversation = state.extra as Conversation?;
            return ChatScreen(conversation: conversation!);
          },
        ),

        //
        // GoRoute(
        //   path: '/employeeHomeScreen',
        //   builder: (_, _) => EmployeeHomeScreen(),
        // ),

        // GoRoute(
        //   path: '/messageListScreen',
        //   builder: (_, _) => MessageListScreen(),
        // ),

        // GoRoute(
        //   path: '/notificationScreen',
        //   builder: (_, _) => NotificationScreen(),
        // ),

        // GoRoute(
        //   path: '/submitTaskScreen',
        //   builder: (_, _) => SubmitTaskScreen(),
        // ),

        // GoRoute(path: '/myTaskScreen', builder: (_, _) => MyTaskScreen()),
        // GoRoute(path: '/historyScreen', builder: (_, _) => HistoryScreen()),
        // GoRoute(
        //   path: '/taskReportScreen',
        //   builder: (_, _) => TaskReportScreen(),
        // ),
        // GoRoute(path: '/profileScreen', builder: (_, _) => ProfileScreen()),
        // GoRoute(path: '/myProfileScreen', builder: (_, _) => MyProfileScreen()),
        // GoRoute(
        //   path: '/changePasswordScreen',
        //   builder: (_, _) => ChangePasswordScreen(),
        // ),
        // GoRoute(
        //   path: '/privacyPolicyScreen',
        //   builder: (_, _) => PrivacyPolicyScreen(),
        // ),
        // GoRoute(path: '/verifyScreen', builder: (_, _) => VerifyScreen()),
        // GoRoute(
        //   path: '/termsConditionScreen',
        //   builder: (_, _) => TermsConditionScreen(),
        // ),
        // GoRoute(
        //   path: '/helpSupportScreen',
        //   builder: (_, _) => HelpSupportScreen(),
        // ),
        GoRoute(
          path: '/adminBottomNavBar',
          builder: (_, _) => AdminBottomNavBar(),
        ),

        GoRoute(

          path: '/adminMyTaskScreen',
          name: 'adminMyTaskScreen',
          builder: (_, _) => AdminMyTaskScreen(),
        ),
        GoRoute(
          path: '/adminCreateTaskScreen',
          name: 'adminCreateTaskScreen',
          builder: (_, _) => AdminCreateTaskScreen(),
        ),

        GoRoute(
          path: '/adminEmployeeRequestScreen',
          name: 'adminEmployeeRequestScreen',
          builder: (_, _) => AdminEmployeeRequestScreen(),
        ),


      ],
    );
  }
}
