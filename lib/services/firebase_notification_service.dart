import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:koji/core/app_constants.dart';
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
      debugPrint("📩 App opened from foreground message: ${message.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("📩 App opened from notification: ${message.data}");
    });
  }

  /// **Handle foreground FCM messages and show local notification**
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      "📩 Received foreground notification: ${message.notification?.title}",
    );

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    // iOS part
    AppleNotification? apple = message.notification?.apple;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: android != null
              ? AndroidNotificationDetails(
            'reservation_channel',
            'Pet Attix',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          )
              : null,

          iOS: apple != null
              ? DarwinNotificationDetails(
            presentBadge: true,
            presentAlert: true,
            presentSound: true,
          )
              : null,
        ),
      );
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