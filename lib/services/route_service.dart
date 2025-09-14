import 'dart:math';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../models/route_point.dart';
import '../models/generated_route.dart';

/// 무작위 산책로 생성 서비스
/// 설계 문서 섹션 2.2: 무작위 경로 생성 알고리즘 구현
class RouteService {
  final Dio _dio = Dio();
  final Random _random = Random();

  /// 현재 위치 기반으로 무작위 산책로를 생성합니다
  /// [startPoint] 시작점 좌표
  /// [targetDistance] 목표 거리 (km)
  /// [targetTime] 목표 시간 (분, 선택사항)
  Future<GeneratedRoute> generateRandomRoute({
    required Position startPoint,
    required double targetDistance,
    int? targetTime,
  }) async {
    try {
      // 1단계: 시드 포인트 생성 (Random Walk 알고리즘)
      final waypoints = _generateSeedPoints(
        startPoint,
        targetDistance,
      );

      // 2단계: 경로 탐색 API 호출 (TMap API 또는 테스트용 더미 데이터)
      final routeData = await _callRoutingAPI(
        startPoint,
        waypoints,
      );

      // 3단계: 검증 및 반복 (거리 체크)
      if (_validateRouteDistance(routeData.totalDistance, targetDistance)) {
        return routeData;
      } else {
        // 거리가 맞지 않으면 재시도 (최대 3회)
        return await _retryRouteGeneration(
          startPoint,
          targetDistance,
          targetTime,
          attempt: 1,
        );
      }
    } catch (e) {
      throw Exception('경로 생성 실패: $e');
    }
  }

  /// 시드 포인트 생성 (설계 문서의 Random Walk 알고리즘)
  List<RoutePoint> _generateSeedPoints(
    Position startPoint,
    double targetDistance,
  ) {
    final waypoints = <RoutePoint>[];
    const int numberOfWaypoints = 3; // 3-5개 경유지 중 3개 사용

    // 목표 거리에 비례한 반경 계산 (예: 3km 산책 → 0.5-1km 반경)
    final radiusKm = targetDistance * 0.3; // 30% 반경

    for (int i = 0; i < numberOfWaypoints; i++) {
      // 원형 패턴으로 경유지 생성
      final angle = (2 * pi * i / numberOfWaypoints) +
                   (_random.nextDouble() * pi / 3); // 약간의 랜덤성 추가

      final distance = radiusKm * (0.5 + _random.nextDouble() * 0.5); // 50-100% 거리

      final latOffset = distance * cos(angle) / 111.0; // 위도 1도 ≈ 111km
      final lngOffset = distance * sin(angle) / (111.0 * cos(startPoint.latitude * pi / 180));

      waypoints.add(RoutePoint(
        latitude: startPoint.latitude + latOffset,
        longitude: startPoint.longitude + lngOffset,
      ));
    }

    return waypoints;
  }

  /// 경로 탐색 API 호출 (현재는 테스트용 더미 구현)
  Future<GeneratedRoute> _callRoutingAPI(
    Position startPoint,
    List<RoutePoint> waypoints,
  ) async {
    // TODO: 실제 구현에서는 TMap API 호출
    // 현재는 테스트용 더미 데이터 반환

    await Future.delayed(const Duration(milliseconds: 500)); // API 호출 시뮬레이션

    // 더미 폴리라인 생성 (시작점 → 경유지들 → 시작점)
    final polylinePoints = <RoutePoint>[
      RoutePoint(latitude: startPoint.latitude, longitude: startPoint.longitude),
      ...waypoints,
      RoutePoint(latitude: startPoint.latitude, longitude: startPoint.longitude),
    ];

    // 더미 거리 계산 (실제로는 API에서 반환)
    double totalDistance = 0.0;
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        polylinePoints[i],
        polylinePoints[i + 1],
      );
    }

    return GeneratedRoute(
      routeId: 'route_${DateTime.now().millisecondsSinceEpoch}',
      startPoint: RoutePoint(
        latitude: startPoint.latitude,
        longitude: startPoint.longitude,
      ),
      waypoints: waypoints,
      polylinePoints: polylinePoints,
      totalDistance: totalDistance,
      estimatedDuration: (totalDistance / 5.0 * 60).round(), // 5km/h 가정
      createdAt: DateTime.now(),
    );
  }

  /// 생성된 경로의 거리 검증
  bool _validateRouteDistance(double actualDistance, double targetDistance) {
    const double tolerance = 0.1; // 10% 허용 오차
    final minDistance = targetDistance * (1 - tolerance);
    final maxDistance = targetDistance * (1 + tolerance);

    return actualDistance >= minDistance && actualDistance <= maxDistance;
  }

  /// 경로 생성 재시도 로직
  Future<GeneratedRoute> _retryRouteGeneration(
    Position startPoint,
    double targetDistance,
    int? targetTime, {
    required int attempt,
  }) async {
    const int maxAttempts = 3;

    if (attempt >= maxAttempts) {
      // 최대 시도 횟수 초과 시 가장 가까운 거리로 반환
      return await _generateBestEffortRoute(startPoint, targetDistance);
    }

    // 시드 포인트를 조정하여 재시도
    final adjustedWaypoints = _generateAdjustedSeedPoints(
      startPoint,
      targetDistance,
      attempt,
    );

    final routeData = await _callRoutingAPIWithWaypoints(
      startPoint,
      adjustedWaypoints,
    );

    if (_validateRouteDistance(routeData.totalDistance, targetDistance)) {
      return routeData;
    } else {
      return await _retryRouteGeneration(
        startPoint,
        targetDistance,
        targetTime,
        attempt: attempt + 1,
      );
    }
  }

  /// 조정된 시드 포인트 생성 (재시도용)
  List<RoutePoint> _generateAdjustedSeedPoints(
    Position startPoint,
    double targetDistance,
    int attempt,
  ) {
    // 시도 횟수에 따라 반경 조정
    final radiusKm = targetDistance * (0.2 + attempt * 0.1);

    return _generateSeedPoints(startPoint, targetDistance);
  }

  /// 경로 탐색 API 호출 (경유지 포함)
  Future<GeneratedRoute> _callRoutingAPIWithWaypoints(
    Position startPoint,
    List<RoutePoint> waypoints,
  ) async {
    return await _callRoutingAPI(startPoint, waypoints);
  }

  /// 최선 노력 경로 생성 (재시도 실패 시)
  Future<GeneratedRoute> _generateBestEffortRoute(
    Position startPoint,
    double targetDistance,
  ) async {
    // 단순한 원형 경로 생성
    final circlePoints = _generateCircularRoute(startPoint, targetDistance);

    return GeneratedRoute(
      routeId: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      startPoint: RoutePoint(
        latitude: startPoint.latitude,
        longitude: startPoint.longitude,
      ),
      waypoints: [],
      polylinePoints: circlePoints,
      totalDistance: targetDistance, // 목표 거리로 설정
      estimatedDuration: (targetDistance / 5.0 * 60).round(),
      createdAt: DateTime.now(),
    );
  }

  /// 원형 경로 생성 (폴백용)
  List<RoutePoint> _generateCircularRoute(
    Position startPoint,
    double targetDistance,
  ) {
    final points = <RoutePoint>[];
    const int numPoints = 16; // 16개 점으로 원형 생성

    final radius = targetDistance / (2 * pi); // 원의 반지름

    for (int i = 0; i <= numPoints; i++) {
      final angle = 2 * pi * i / numPoints;
      final latOffset = radius * cos(angle) / 111.0;
      final lngOffset = radius * sin(angle) / (111.0 * cos(startPoint.latitude * pi / 180));

      points.add(RoutePoint(
        latitude: startPoint.latitude + latOffset,
        longitude: startPoint.longitude + lngOffset,
      ));
    }

    return points;
  }

  /// 두 지점 간 거리 계산 (Haversine 공식)
  double _calculateDistance(RoutePoint point1, RoutePoint point2) {
    const double earthRadius = 6371; // 지구 반지름 (km)

    final lat1Rad = point1.latitude * pi / 180;
    final lat2Rad = point2.latitude * pi / 180;
    final deltaLatRad = (point2.latitude - point1.latitude) * pi / 180;
    final deltaLngRad = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// 실제 TMap API 호출 구현 (향후 구현 예정)
  Future<GeneratedRoute> _callTMapAPI(
    Position startPoint,
    List<RoutePoint> waypoints,
  ) async {
    // TODO: 실제 TMap API 구현
    // const String apiKey = 'YOUR_TMAP_API_KEY';
    // const String baseUrl = 'https://apis.openapi.sk.com/tmap/routes/pedestrian';

    throw UnimplementedError('TMap API 연동 예정');
  }

  /// 리소스 정리
  void dispose() {
    _dio.close();
  }
}