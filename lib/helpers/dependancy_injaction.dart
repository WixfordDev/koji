import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:koji/controller/auth_controller.dart';
import 'package:koji/controller/chat_controller.dart';
import 'package:koji/controller/admincontroller/admin_home_controller.dart';
import 'package:koji/controller/admincontroller/department_controller.dart';
import 'package:koji/controller/admincontroller/schedule_controller.dart';
import 'package:koji/controller/profile_controller.dart';

import '../controller/notifications_controller.dart';

class DependencyInjection implements Bindings {
  DependencyInjection();

  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => DepartmentController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => AdminHomeController(), fenix: true);
    Get.lazyPut(() => ScheduleController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);

  }

  void lockDevicePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
