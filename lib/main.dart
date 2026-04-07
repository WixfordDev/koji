import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:koji/helpers/dependancy_injaction.dart';
import 'package:koji/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:koji/services/firebase_notification_service.dart';
import 'package:toastification/toastification.dart';
import 'helpers/toast_message_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await FirebaseMessaging.instance;
  // FirebaseNotificationService.instance;
  // FirebaseNotificationService.getFCMToken();
  // FirebaseNotificationService.printFCMToken();

  PlatformDispatcher.instance.onAccessibilityFeaturesChanged = () {};
  DependencyInjection di = DependencyInjection();
  di.dependencies();

  di.lockDevicePortrait();

  await Firebase.initializeApp();
  await FirebaseMessaging.instance;
  // Print FCM Token
  await FirebaseNotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // final authBloc = context.read<AuthBloc>();
    _router = AppRouter.build();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _getPhoneDesignSize(),
      child: ToastificationWrapper(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Koji',
          // theme: AppThemes.defaultTheme,
          routerConfig: _router,
        ),
      ),
    );
  }

  Size _getPhoneDesignSize() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const Size(390, 844);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return const Size(412, 915);
    }
    return const Size(360, 800);
  }
}

// cd C:\Android\emulator
// emulator -avd Pixel_6_API_34