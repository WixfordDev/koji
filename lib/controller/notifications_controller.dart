import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../services/api_client.dart';
import '../services/api_constants.dart';
import '../services/socket_services.dart';

class NotificationController extends GetxController {

  RxBool getNotificationLoading = false.obs;
  Rx<NotificationsModel> notification = NotificationsModel().obs;

  void setupSocketListener() {
    try {
      SocketServices().socket
        ..off('notification')
        ..on('notification', (_) {
          debugPrint('========> Socket notification received');
          _fetchAndShowPopup();
        });
    } catch (e) {
      debugPrint('Socket notification listener error: $e');
    }
  }

  Future<void> _fetchAndShowPopup() async {
    await getNotification();
    final list = notification.value.notifications;
    if (list != null && list.isNotEmpty) {
      final latest = list.first;
      Get.snackbar(
        latest.title ?? 'New Notification',
        latest.content ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF162238),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.notifications, color: Colors.white),
      );
    }
  }

  getNotification() async {
    getNotificationLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.notificationsEndPoint);

      if (response.statusCode == 200) {
        notification.value = NotificationsModel.fromJson(response.body['data']['attributes']);
        getNotificationLoading(false);
      } else if (response.statusCode == 404) {
        getNotificationLoading(false);
      } else {
        getNotificationLoading(false);
      }
    } catch (e) {
      getNotificationLoading(false);
    }
  }
}