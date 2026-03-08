import 'package:flutter_test/flutter_test.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:tic_tac_toe/app/services/app_rating_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRatingService.checkAndShowRating', () {
    test(
      'should return before requesting review when in-app review is unavailable',
      () async {
        final fakeReviewClient = _FakeAppReviewClient(isAvailableResult: false);
        final fakeRatingTracker = _FakeRatingPromptTracker(
          shouldOpenDialog: true,
        );

        final service = AppRatingService(
          inAppReviewClient: fakeReviewClient,
          ratingPromptTracker: fakeRatingTracker,
        );

        await service.checkAndShowRating();

        expect(fakeRatingTracker.initCallCount, 1);
        expect(fakeReviewClient.isAvailableCallCount, 1);
        expect(fakeReviewClient.requestReviewCallCount, 0);
        expect(fakeRatingTracker.recordedEvents, isEmpty);
      },
    );

    test(
      'should request review and record rate event when in-app review is available',
      () async {
        final fakeReviewClient = _FakeAppReviewClient(isAvailableResult: true);
        final fakeRatingTracker = _FakeRatingPromptTracker(
          shouldOpenDialog: true,
        );

        final service = AppRatingService(
          inAppReviewClient: fakeReviewClient,
          ratingPromptTracker: fakeRatingTracker,
        );

        await service.checkAndShowRating();

        expect(fakeReviewClient.requestReviewCallCount, 1);
        expect(
          fakeRatingTracker.recordedEvents,
          [RateMyAppEventType.rateButtonPressed],
        );
      },
    );
  });
}

class _FakeAppReviewClient implements AppReviewClient {
  _FakeAppReviewClient({required this.isAvailableResult});

  final bool isAvailableResult;
  int isAvailableCallCount = 0;
  int requestReviewCallCount = 0;

  @override
  Future<bool> isAvailable() async {
    isAvailableCallCount += 1;
    return isAvailableResult;
  }

  @override
  Future<void> openStoreListing({String? appStoreId}) async {}

  @override
  Future<void> requestReview() async {
    requestReviewCallCount += 1;
  }
}

class _FakeRatingPromptTracker implements RatingPromptTracker {
  _FakeRatingPromptTracker({required this.shouldOpenDialog});

  @override
  final bool shouldOpenDialog;

  int initCallCount = 0;
  final List<RateMyAppEventType> recordedEvents = <RateMyAppEventType>[];

  @override
  Future<void> callEvent(RateMyAppEventType eventType) async {
    recordedEvents.add(eventType);
  }

  @override
  Future<void> init() async {
    initCallCount += 1;
  }

  @override
  Future<void> reset() async {}
}
