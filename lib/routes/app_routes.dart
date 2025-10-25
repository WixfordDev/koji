import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:koji/features/authentication/presentation/forgot_password_screen.dart';
import 'package:koji/features/authentication/presentation/login_screen.dart';
import 'package:koji/features/authentication/presentation/onboarding_screen.dart';
import 'package:koji/features/authentication/presentation/reset_password_screen.dart';
import 'package:koji/features/authentication/presentation/signup_screen.dart';
import 'package:koji/features/authentication/presentation/splash_screen.dart';
import 'package:koji/features/employee_home/presentation/employee_home_screen.dart';
import 'package:koji/features/message/presentation/message_screen.dart';
import 'package:koji/features/notification/presentation/notification_screen.dart';

import '../features/admin_home/presentation/admin_attendance_screen.dart';
import '../features/admin_schedule/presentation/admin_complete_task_screen.dart';
import '../features/admin_schedule/presentation/admin_schedule.dart';
import '../features/bottom_navbar/presentation/bottom_navbar_screen.dart';
import '../features/employee_history/presentation/employee_history_screen.dart';
import '../features/employee_history/presentation/taskreport_screen.dart';
import '../features/employee_schedule/presentation/calendar_screen.dart';
import '../features/employee_schedule/presentation/my_task_screen.dart';
import '../features/employee_schedule/presentation/submit_task_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/profile/presentation/help_support_screen.dart';
import '../features/profile/presentation/my_profile_screen.dart';
import '../features/profile/presentation/privacy_policy_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/terms_condition_screen.dart';

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
  static GoRouter build() {
    return GoRouter(
      initialLocation: '/sign-in',
      debugLogDiagnostics: true,

      // refreshListenable: GoRouterRefreshStream(authBloc.stream),
      // redirect: (context, state) {
      // final isLoggedIn = false;
      //
      // final goingToSignIn = state.matchedLocation == '/sign-in';
      //
      // if (!isLoggedIn && !goingToSignIn) {
      //   return '/sign-up'; // 👈 this causes the redirect
      // }
      //
      // return null;
      // final status = authBloc.state.status;
      // final loggingIn = state.matchedLocation == '/sign-in';
      //
      // if (status == AuthStatus.unknown) {
      //   return state.matchedLocation == '/splash' ? null : '/splash';
      // }
      //
      // if (status == AuthStatus.unauthenticated) {
      //   return loggingIn ? null : '/sign-in';
      // }
      //
      // if (status == AuthStatus.authenticated) {
      //   if (loggingIn || state.matchedLocation == '/splash') return '/home';
      // }
      // String? token = LocalStorage.getToken();
      // print(token);
      // return token != null ? '/home' : '/applyForm-in';
      //   return '/splash';
      // },
      routes: [
        GoRoute(path: '/splash', builder: (_, x) => const SplashScreen()),
        GoRoute(path: '/sign-in', builder: (_, x) => LoginScreen()),
        GoRoute(
          path: '/sign-up',
          builder: (_, x) => const RegistrationScreen(),
        ),
        GoRoute(path: '/onboarding', builder: (_, x) => OnboardingScreen()),
        GoRoute(
          path: '/forgotPassword',
          builder: (_, x) => ForgotPasswordScreen(),
        ),

        GoRoute(
          path: '/resetPassword',
          builder: (_, x) => ResetPasswordScreen(),
        ),

        GoRoute(
          path: '/employeeHomeScreen',
          builder: (_, _) => EmployeeHomeScreen(),
        ),

        GoRoute(
          path: '/messageListScreen',
          builder: (_, _) => MessageListScreen(),
        ),

        GoRoute(
          path: '/notificationScreen',
          builder: (_, _) => NotificationScreen(),
        ),


        GoRoute(
          path: '/submitTaskScreen',
          builder: (_, _) => SubmitTaskScreen(),
        ),

        GoRoute(
          path: '/myTaskScreen',
          builder: (_, _) => MyTaskScreen(),
        ),
        GoRoute(
          path: '/historyScreen',
          builder: (_, _) => HistoryScreen(),
        ),
        GoRoute(
          path: '/taskReportScreen',
          builder: (_, _) => TaskReportScreen(),
        ),
        GoRoute(
          path: '/profileScreen',
          builder: (_, _) => ProfileScreen(),
        ),
        GoRoute(
          path: '/myProfileScreen',
          builder: (_, _) => MyProfileScreen(),
        ),
        GoRoute(
          path: '/changePasswordScreen',
          builder: (_, _) => ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/privacyPolicyScreen',
          builder: (_, _) => PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/termsConditionScreen',
          builder: (_, _) => TermsConditionScreen(),
        ),
        GoRoute(
          path: '/helpSupportScreen',
          builder: (_, _) => HelpSupportScreen(),
        ),
        GoRoute(
          path: '/calendarScreen',
          builder: (_, _) => CalendarScreen(),
        ),
        GoRoute(
          path: '/bottomNavBar',
          builder: (_, _) => BottomNavBar(),
        ),
        GoRoute(
          path: '/adminScheduleScreen',
          builder: (_, _) => AdminScheduleScreen(),
        ),
        GoRoute(
          path: '/adminCompleteTaskScreen',
          builder: (_, _) => AdminCompleteTaskScreen(),
        ),
        GoRoute(
          path: '/adminAttendanceScreen',
          builder: (_, _) => AdminAttendanceScreen(),
        ),



      ],
    );
  }
}
