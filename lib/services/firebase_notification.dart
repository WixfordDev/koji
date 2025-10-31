

// import 'dart:convert';

// import 'package:autorevive/services/socket_services.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/foundation.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../core/app_constants/app_constants.dart';
// import '../helpers/prefs_helper.dart';

// class FirebaseNotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

//   FirebaseNotificationService._privateConstructor();
//   static final FirebaseNotificationService instance = FirebaseNotificationService._privateConstructor();

//   static Future<void> initialize() async {
//     // 🔐 Permission
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.denied) {
//       debugPrint("🚫 Notification permission denied");
//       return;
//     }

//     // ⚙️ Android & iOS initialization
//     const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

//     final InitializationSettings initSettings = InitializationSettings(
//       android: androidInitSettings,
//       iOS: iosSettings,
//     );
//     await _localNotifications.initialize(initSettings);

//     // ✅ Create notification channel
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'reservation_channel',
//       'Auto Revive',
//       description: 'This channel is used for reservation notifications.',
//       importance: Importance.max,
//       playSound: true,
//     );

//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     // 🔔 Foreground message listener
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint("📩 Received foreground message: ${message.data}");
//       _handleForegroundMessage(message);
//     });

//     // 🔔 When opened from background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint("📬 App opened from notification: ${message.data}");
//     });
//   }



//   /// **Handle foreground FCM messages and show local notification**
//   static Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     debugPrint("📩 Received foreground notification: ${message.notification?.title}");

//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     print("--------------------------------------back ground");

//     if (notification != null && android != null) {
//       _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'reservation_channel',
//             'Gestion App',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true,
//             icon: '@mipmap/ic_launcher',
//           ),
//         ),
//       );
//     }
//   }


//   static Future<String?> getFCMToken() async {
//     String? fcmToken = await _firebaseMessaging.getToken();
//     if (fcmToken != null && fcmToken.isNotEmpty) {
//       PrefsHelper.setString(AppConstants.fcmToken, fcmToken);
//       return fcmToken;
//     } else {
//       return null;
//     }
//   }

//   static Future<void> printFCMToken() async {
//     if (await Permission.notification.isDenied) {
//       await Permission.notification.request();
//     }

//     String token = await PrefsHelper.getString(AppConstants.fcmToken);
//     if (token.isNotEmpty) {
//       debugPrint("🔑 FCM Token (Stored): $token");
//     } else {
//       token = await getFCMToken() ?? '';
//       PrefsHelper.setString(AppConstants.fcmToken, token);
//       debugPrint("🔑 FCM Token (New): $token");
//     }
//   }



//  static void listenMessage() async {
//    SocketServices socketServices = SocketServices();
//     socketServices.socket.on("notification", (data) {
//       if (data != null) {

//         var parsed = data is String ? jsonDecode(data) : data;

//         String title = parsed['title'] ?? '🔔 New Notification';
//         String message = parsed['message'] ?? '';

//         // Show notification
//         showTestNotification(title: title, message: message);

//         print('Notification =================   $parsed');
//       }
//     });
//   }



//  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();

//   static Future<void> showTestNotification({String? title, message}) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'reservation_channel', // unique ID
//       'reservation_channel', // channel name
//       channelDescription: 'Channel for manual test notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       icon: '@mipmap/ic_launcher', // ✅ set the icon to prevent NullPointerException
//     );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );

//     await _localNotifications.show(
//       0, // notification ID
//       title ?? '🔔 Notification',
//       message ?? '',
//       notificationDetails,
//     );
//   }


// }