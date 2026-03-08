import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:tic_tac_toe/app/utils/app_constants.dart';

abstract class AppReviewClient {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing({String? appStoreId});
}

class _InAppReviewClient implements AppReviewClient {
  _InAppReviewClient(this._inAppReview);

  final InAppReview _inAppReview;

  @override
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  @override
  Future<void> openStoreListing({String? appStoreId}) {
    return _inAppReview.openStoreListing(appStoreId: appStoreId);
  }

  @override
  Future<void> requestReview() => _inAppReview.requestReview();
}

abstract class RatingPromptTracker {
  Future<void> init();
  bool get shouldOpenDialog;
  Future<void> callEvent(RateMyAppEventType eventType);
  Future<void> reset();
}

class _RateMyAppTracker implements RatingPromptTracker {
  _RateMyAppTracker(this._rateMyApp);

  final RateMyApp _rateMyApp;

  @override
  Future<void> callEvent(RateMyAppEventType eventType) {
    return _rateMyApp.callEvent(eventType);
  }

  @override
  Future<void> init() => _rateMyApp.init();

  @override
  Future<void> reset() => _rateMyApp.reset();

  @override
  bool get shouldOpenDialog => _rateMyApp.shouldOpenDialog;
}

class AppRatingService extends GetxService {
  AppRatingService({
    AppReviewClient? inAppReviewClient,
    RatingPromptTracker? ratingPromptTracker,
  }) : _inAppReviewClient =
           inAppReviewClient ?? _InAppReviewClient(InAppReview.instance),
       _ratingPromptTracker =
           ratingPromptTracker ?? _createRatingPromptTracker();

  static AppRatingService get to => Get.find();

  final AppReviewClient _inAppReviewClient;
  RatingPromptTracker _ratingPromptTracker;

  static RatingPromptTracker _createRatingPromptTracker() {
    return _RateMyAppTracker(
      RateMyApp(
        preferencesPrefix: RateMyAppConfig.PREFIX,
        minDays: RateMyAppConfig.MIN_DAYS,
        minLaunches: RateMyAppConfig.MIN_LAUNCHES,
        remindDays: RateMyAppConfig.REMIND_DAYS,
        remindLaunches: RateMyAppConfig.REMIND_LAUNCHES,
        googlePlayIdentifier: AppUrls.PACKAGE_NAME,
        appStoreIdentifier: RateMyAppConfig.APP_STORE_ID,
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowRating();
    });
  }

  Future<void> checkAndShowRating() async {
    await _ratingPromptTracker.init();
    if (_ratingPromptTracker.shouldOpenDialog) {
      try {
        if (!await _inAppReviewClient.isAvailable()) {
          return;
        }
        await _inAppReviewClient.requestReview();
        await _ratingPromptTracker.callEvent(
          RateMyAppEventType.rateButtonPressed,
        );
      } catch (e) {
        debugPrint('인앱 리뷰 요청 실패: $e');
      }
    }
  }

  Future<void> openStoreListing() async {
    try {
      if (Platform.isIOS) {
        await _inAppReviewClient.openStoreListing(
          appStoreId: RateMyAppConfig.APP_STORE_ID,
        );
      } else {
        await _inAppReviewClient.openStoreListing();
      }
    } catch (e) {
      debugPrint('스토어 열기 실패: $e');
    }
  }

  Future<void> resetRatingConditions() async {
    await _ratingPromptTracker.reset();
    _ratingPromptTracker = _createRatingPromptTracker();
    await _ratingPromptTracker.init();
  }
}
