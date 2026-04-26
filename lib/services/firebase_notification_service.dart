import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:koji/core/app_constants.dart';
import 'package:koji/features/admin_home/presentation/admin_my_task_details_screen.dart';
import 'package:koji/features/employee_schedule/presentation/task_details_screen.dart';
import 'package:koji/controller/notifications_controller.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // ✅ Static socket instance (Ensure it's initialized properly)
  static late IO.Socket socket;

  // Singleton pattern
  FirebaseNotificationService._privateConstructor();
  static final FirebaseNotificationService instance =
  FirebaseNotificationService._privateConstructor();

  /// **Initialize Firebase Notifications and Socket**
  static Future<void> initialize() async {
    // Request notification permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint("🚫 Notification permission denied");
      return;
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Handle FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
      debugPrint("📩 Foreground FCM: ${message.data}");
      _refreshNotifications();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📩 App opened from notification: ${message.data}");
      _refreshNotifications();
      _navigateFromNotification(message.data);
    });

    // Handle cold-start: app launched by tapping a notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("📩 Cold-start notification: ${initialMessage.data}");
      await Future.delayed(const Duration(milliseconds: 1000));
      _navigateFromNotification(initialMessage.data);
    }
  }

  /// **Handle foreground FCM messages and show local notification**
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint("📩 Foreground notification: ${message.notification?.title}");

    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reservation_channel',
          'Koji',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentBadge: true,
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  static void _refreshNotifications() {
    try {
      Get.find<NotificationController>().getNotification();
    } catch (_) {}
  }

  static void _navigateFromNotification(Map<String, dynamic> data) async {
    final taskId = data['taskId'] as String?;
    if (taskId == null || taskId.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 300));
    final context = Get.context;
    if (context == null) return;

    try {
      final prefs = await _getRole();
      if (prefs == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminMyTaskDetailsScreen(taskId: taskId),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailsScreen(taskId: taskId),
          ),
        );
      }
    } catch (e) {
      debugPrint('Navigate from notification error: $e');
    }
  }

  static Future<String> _getRole() async {
    try {
      return await PrefsHelper.getString(AppConstants.role);
    } catch (_) {
      return '';
    }
  }

  /// **Retrieve FCM Token**
  static Future<String?> getFCMToken() async {
    String? fcmToken = await _firebaseMessaging.getToken();

    if (fcmToken!.isNotEmpty) {
      return fcmToken;
    } else {
      return null;
    }
  }

  /// **Print FCM Token & Store it in Preferences**
  static Future<void> printFCMToken() async {
    String token = await PrefsHelper.getString(AppConstants.fcmToken);
    if (token.isNotEmpty) {
      debugPrint("🔑 FCM Token (Stored): $token");
    } else {
      token = await getFCMToken() ?? '';
      PrefsHelper.setString(AppConstants.fcmToken, token);
      debugPrint("🔑 FCM Token (New): $token");
    }
  }

  /// **Emit Socket Events from Anywhere**
  static void sendSocketEvent(String eventName, dynamic data) {
    if (socket.connected) {
      socket.emit(eventName, data);
      debugPrint('📤 Socket emit: $eventName - $data');
    } else {
      debugPrint('⚠️ Socket is not connected!');
    }
  }
}