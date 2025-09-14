import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/walk.dart';
import '../models/generated_route.dart';
import '../models/route_point.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';
import 'bonus_provider.dart';

part 'walk_provider.g.dart';

/// LocationService 인스턴스를 제공하는 Provider
@riverpod
LocationService locationService(LocationServiceRef ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// 사용자의 산책 기록을 관리하는 Provider
/// 설계 문서 섹션 2.3: 산책 추적 및 기록
@riverpod
Stream<List<Walk>> userWalks(UserWalksRef ref) async* {
  final currentUser = ref.watch(currentUserProvider);

  await for (final user in currentUser) {
    if (user == null) {
      yield [];
    } else {
      final firestoreService = ref.read(firestoreServiceProvider);
      yield* firestoreService.getUserWalksStream(user.uid);
    }
  }
}

/// 실시간 산책 통계를 제공하는 StreamProvider
@riverpod
Stream<Map<String, dynamic>> walkStats(WalkStatsRef ref) async* {
  final locationService = ref.watch(locationServiceProvider);
  yield* locationService.walkStatsStream;
}

/// 현재 위치 스트림을 제공하는 StreamProvider
@riverpod
Stream<RoutePoint> currentLocation(CurrentLocationRef ref) async* {
  final locationService = ref.watch(locationServiceProvider);
  yield* locationService.locationStream;
}

/// 현재 진행 중인 산책 상태를 관리하는 NotifierProvider
@riverpod
class ActiveWalk extends _$ActiveWalk {
  GeneratedRoute? _plannedRoute;

  @override
  AsyncValue<Walk?> build() {
    return const AsyncValue.data(null);
  }

  /// 새로운 산책 시작
  Future<void> startWalk({
    required GeneratedRoute plannedRoute,
  }) async {
    try {
      state = const AsyncValue.loading();

      _plannedRoute = plannedRoute;
      final now = DateTime.now();

      // LocationService 시작
      final locationService = ref.read(locationServiceProvider);
      await locationService.startTracking();

      final initialWalk = Walk(
        walkId: 'temp_${now.millisecondsSinceEpoch}',
        userId: '', // 나중에 현재 사용자 ID로 업데이트
        completedAt: now,
        requestedDistance: plannedRoute.totalDistance,
        actualDistance: 0.0,
        durationInSeconds: 0,
        pointsAwarded: 0,
        routePolyline: plannedRoute.encodedPolyline,
        userTrackPolyline: '',
      );

      state = AsyncValue.data(initialWalk);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 산책 진행 상황 실시간 업데이트
  void updateFromLocationService() {
    final currentWalk = state.value;
    if (currentWalk == null) return;

    final locationService = ref.read(locationServiceProvider);

    state = AsyncValue.data(currentWalk.copyWith(
      actualDistance: locationService.totalDistance,
      durationInSeconds: locationService.elapsedSeconds,
      userTrackPolyline: _encodeTrackPoints(locationService.trackPoints),
    ));
  }

  /// 경로 준수 확인
  bool isOnRoute() {
    if (_plannedRoute == null) return true;

    final locationService = ref.read(locationServiceProvider);
    return locationService.isOnRoute(_plannedRoute!.polylinePoints);
  }

  /// 산책 완료 확인
  bool isWalkCompleted() {
    if (_plannedRoute == null) return false;

    final locationService = ref.read(locationServiceProvider);
    return locationService.isWalkCompleted(_plannedRoute!.startPoint);
  }

  /// 산책 완료 및 저장
  Future<void> completeWalk() async {
    final currentWalk = state.value;
    if (currentWalk == null) return;

    try {
      state = const AsyncValue.loading();

      // 위치 추적 중지
      final locationService = ref.read(locationServiceProvider);
      await locationService.stopTracking();

      // 최종 데이터 수집
      final trackingData = locationService.exportTrackingData();

      final currentUser = ref.read(currentUserProvider);
      await for (final user in currentUser.take(1)) {
        if (user != null) {
          // 보너스 시스템을 활용한 포인트 계산 (설계 문서 섹션 3.1)
          final bonusSystem = ref.read(bonusSystemProvider.notifier);
          final isFirstToday = await bonusSystem.isFirstWalkToday();
          final currentStreak = await bonusSystem.getCurrentStreak();

          final points = bonusSystem.calculatePointsWithBonus(
            distance: trackingData['totalDistance'] ?? 0.0,
            durationInSeconds: trackingData['elapsedSeconds'] ?? 0,
            isFirstWalkToday: isFirstToday,
            currentStreak: currentStreak,
          );

          final completedWalk = currentWalk.copyWith(
            walkId: 'walk_${DateTime.now().millisecondsSinceEpoch}',
            userId: user.uid,
            completedAt: DateTime.now(),
            actualDistance: trackingData['totalDistance'] ?? 0.0,
            durationInSeconds: trackingData['elapsedSeconds'] ?? 0,
            pointsAwarded: points,
            userTrackPolyline: _encodeTrackPoints(locationService.trackPoints),
          );

          // Firestore에 저장
          final firestoreService = ref.read(firestoreServiceProvider);
          await firestoreService.saveWalk(completedWalk);

          // 사용자 통계 업데이트 (포인트, 거리, 횟수)
          await firestoreService.updateWalkStats(user.uid, trackingData['totalDistance'] ?? 0.0, points);

          // 상태 초기화
          state = const AsyncValue.data(null);
          _plannedRoute = null;
          break;
        }
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 산책 취소
  Future<void> cancelWalk() async {
    final locationService = ref.read(locationServiceProvider);
    await locationService.stopTracking();

    state = const AsyncValue.data(null);
    _plannedRoute = null;
  }


  /// 추적 포인트들을 폴리라인으로 인코딩
  String _encodeTrackPoints(List<RoutePoint> points) {
    // google_polyline_algorithm 패키지 사용 예정
    // 현재는 단순한 좌표 문자열로 대체
    return points
        .map((point) => '${point.latitude},${point.longitude}')
        .join('|');
  }
}