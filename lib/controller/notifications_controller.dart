import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/notification_model.dart';
import '../services/api_client.dart';
import '../services/api_constants.dart';

class NotificationController extends GetxController {

  RxBool getNotificationLoading = false.obs;
  Rx<NotificationsModel> notification = NotificationsModel().obs;

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