import 'package:get/get.dart';

import 'package:tic_tac_toe/app/controllers/game_controller.dart';
import 'package:tic_tac_toe/app/controllers/setting_controller.dart';
import 'package:tic_tac_toe/app/services/hive_service.dart';
import 'package:tic_tac_toe/app/services/activity_log_service.dart';
import 'package:tic_tac_toe/app/controllers/history_controller.dart';
import 'package:tic_tac_toe/app/controllers/stats_controller.dart';

import 'package:tic_tac_toe/app/services/app_rating_service.dart';
import 'package:tic_tac_toe/app/services/purchase_service.dart';
import 'package:tic_tac_toe/app/controllers/premium_controller.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PurchaseService>()) {
      Get.put(PurchaseService(), permanent: true);
    }

    if (!Get.isRegistered<PremiumController>()) {
      Get.lazyPut(() => PremiumController());
    }

    if (!Get.isRegistered<HiveService>()) {
      Get.put(HiveService(), permanent: true);
    }

    if (!Get.isRegistered<GameController>()) {
      Get.put(GameController(), permanent: true);
    }

    if (!Get.isRegistered<SettingController>()) {
      Get.put(SettingController(), permanent: true);
    }

    if (!Get.isRegistered<ActivityLogService>()) {
      Get.put(ActivityLogService(), permanent: true);
    }

    if (!Get.isRegistered<HistoryController>()) {
      Get.lazyPut(() => HistoryController());
    }

    if (!Get.isRegistered<StatsController>()) {
      Get.lazyPut(() => StatsController());
    }

    if (!Get.isRegistered<AppRatingService>()) {
      Get.put(AppRatingService(), permanent: true);
    }
  }
}
