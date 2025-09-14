import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/generated_route.dart';
import '../services/route_service.dart';

part 'route_provider.g.dart';

/// RouteService 인스턴스를 제공하는 Provider
@riverpod
RouteService routeService(RouteServiceRef ref) {
  return RouteService();
}

/// 현재 위치를 관리하는 Provider
@riverpod
Future<Position> currentPosition(CurrentPositionRef ref) async {
  // 위치 권한 확인
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('위치 서비스가 비활성화되어 있습니다');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('위치 권한이 거부되었습니다');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
  }

  // 현재 위치 가져오기
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

/// 경로 생성을 관리하는 NotifierProvider
@riverpod
class RouteGenerator extends _$RouteGenerator {
  @override
  AsyncValue<GeneratedRoute?> build() {
    return const AsyncValue.data(null);
  }

  /// 무작위 경로 생성
  /// [targetDistance] 목표 거리 (km)
  /// [targetTime] 목표 시간 (분, 선택사항)
  Future<void> generateRoute({
    required double targetDistance,
    int? targetTime,
  }) async {
    state = const AsyncValue.loading();

    try {
      // 현재 위치 가져오기
      final position = await ref.read(currentPositionProvider.future);

      // RouteService로 경로 생성
      final routeService = ref.read(routeServiceProvider);
      final route = await routeService.generateRandomRoute(
        startPoint: position,
        targetDistance: targetDistance,
        targetTime: targetTime,
      );

      state = AsyncValue.data(route);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 경로 초기화
  void clearRoute() {
    state = const AsyncValue.data(null);
  }

  /// 경로 재생성 (같은 조건으로)
  Future<void> regenerateRoute() async {
    final currentRoute = state.value;
    if (currentRoute != null) {
      await generateRoute(
        targetDistance: currentRoute.totalDistance,
        targetTime: currentRoute.estimatedDuration,
      );
    }
  }
}

/// 경로 생성 히스토리를 관리하는 Provider
@riverpod
class RouteHistory extends _$RouteHistory {
  @override
  List<GeneratedRoute> build() {
    return [];
  }

  /// 히스토리에 경로 추가
  void addRoute(GeneratedRoute route) {
    state = [...state, route];
  }

  /// 히스토리에서 경로 제거
  void removeRoute(String routeId) {
    state = state.where((route) => route.routeId != routeId).toList();
  }

  /// 히스토리 초기화
  void clearHistory() {
    state = [];
  }

  /// 최근 경로 가져오기
  GeneratedRoute? get latestRoute {
    return state.isEmpty ? null : state.last;
  }

  /// 특정 경로 찾기
  GeneratedRoute? getRoute(String routeId) {
    try {
      return state.firstWhere((route) => route.routeId == routeId);
    } catch (e) {
      return null;
    }
  }
}

/// 위치 권한 상태를 관리하는 Provider
@riverpod
Future<LocationPermission> locationPermission(LocationPermissionRef ref) async {
  return await Geolocator.checkPermission();
}

/// 위치 서비스 활성화 상태를 확인하는 Provider
@riverpod
Future<bool> locationServiceEnabled(LocationServiceEnabledRef ref) async {
  return await Geolocator.isLocationServiceEnabled();
}

/// 실시간 위치 스트림 Provider (산책 중 사용)
@riverpod
Stream<Position> positionStream(PositionStreamRef ref) {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5, // 5미터 이동 시마다 업데이트
  );

  return Geolocator.getPositionStream(locationSettings: locationSettings);
}

/// 두 지점 간의 거리를 계산하는 유틸리티 Provider
@riverpod
double calculateDistance(
  CalculateDistanceRef ref,
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000; // km 단위
}