import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/features/authentication/presentation/forgot_password_screen.dart';
import 'package:koji/features/authentication/presentation/login_screen.dart';
import 'package:koji/features/authentication/presentation/onboarding_screen.dart';
import 'package:koji/features/authentication/presentation/reset_password_screen.dart';
import 'package:koji/features/authentication/presentation/signup_screen.dart';
import 'package:koji/features/authentication/presentation/splash_screen.dart';

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
      initialLocation: '/splash',
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
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/sign-in', builder: (_, _) => LoginScreen()),
        GoRoute(
          path: '/sign-up',
          builder: (_, _) => const RegistrationScreen(),
        ),
        GoRoute(path: '/onboarding', builder: (_, _) => OnboardingScreen()),
        GoRoute(
          path: '/forgotPassword',
          builder: (_, _) => ForgotPasswordScreen(),
        ),

        GoRoute(
          path: '/resetPassword',
          builder: (_, _) => ResetPasswordScreen(),
        ),
      ],
    );
  }
}
