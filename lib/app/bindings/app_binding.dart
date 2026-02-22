import 'package:get/get.dart';

import 'package:tic_tac_toe/app/controllers/game_controller.dart';
import 'package:tic_tac_toe/app/services/hive_service.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HiveService>()) {
      Get.put(HiveService(), permanent: true);
    }

    if (!Get.isRegistered<GameController>()) {
      Get.put(GameController(), permanent: true);
    }
  }
}
