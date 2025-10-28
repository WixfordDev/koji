import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:koji/controller/auth_controller.dart';

class DependencyInjection implements Bindings {
  DependencyInjection();

  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
  }

  void lockDevicePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
