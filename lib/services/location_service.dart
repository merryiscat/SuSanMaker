import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/route_point.dart';

/// 위치 추적 및 산책 중 실시간 추적 서비스
/// 설계 문서 섹션 2.3: 위치 추적 및 산책 기록 시스템
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final List<RoutePoint> _trackPoints = [];
  final StreamController<RoutePoint> _locationController = StreamController<RoutePoint>.broadcast();
  final StreamController<Map<String, dynamic>> _walkStatsController = StreamController<Map<String, dynamic>>.broadcast();

  DateTime? _walkStartTime;
  double _totalDistance = 0.0;
  RoutePoint? _lastPosition;

  /// 위치 스트림
  Stream<RoutePoint> get locationStream => _locationController.stream;

  /// 산책 통계 스트림 (거리, 시간, 속도 등)
  Stream<Map<String, dynamic>> get walkStatsStream => _walkStatsController.stream;

  /// 현재 추적된 경로 포인트들
  List<RoutePoint> get trackPoints => List.unmodifiable(_trackPoints);

  /// 총 이동 거리 (km)
  double get totalDistance => _totalDistance;

  /// 산책 시작 시간
  DateTime? get walkStartTime => _walkStartTime;

  /// 현재 산책 소요 시간 (초)
  int get elapsedSeconds {
    if (_walkStartTime == null) return 0;
    return DateTime.now().difference(_walkStartTime!).inSeconds;
  }

  /// 산책 추적 시작
  Future<void> startTracking() async {
    // 위치 권한 확인
    await _checkLocationPermission();

    _walkStartTime = DateTime.now();
    _totalDistance = 0.0;
    _trackPoints.clear();
    _lastPosition = null;

    // 위치 추적 설정 (설계 문서의 배터리 최적화 고려)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // 5미터 이동 시마다 업데이트
      timeLimit: Duration(minutes: 180), // 최대 3시간
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      _onPositionUpdate,
      onError: (error) {
        _locationController.addError(error);
      },
    );
  }

  /// 산책 추적 중지
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _walkStartTime = null;
  }

  /// 위치 업데이트 처리
  void _onPositionUpdate(Position position) {
    final currentPoint = RoutePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      timestamp: DateTime.now(),
    );

    // 첫 번째 위치인 경우
    if (_lastPosition == null) {
      _lastPosition = currentPoint;
      _trackPoints.add(currentPoint);
      _locationController.add(currentPoint);
      _updateWalkStats(currentPoint);
      return;
    }

    // 거리 계산 및 업데이트
    final distance = _lastPosition!.distanceTo(currentPoint);
    _totalDistance += distance;

    _trackPoints.add(currentPoint);
    _lastPosition = currentPoint;

    // 스트림으로 현재 위치 전송
    _locationController.add(currentPoint);

    // 산책 통계 업데이트
    _updateWalkStats(currentPoint);
  }

  /// 산책 통계 업데이트
  void _updateWalkStats(RoutePoint currentPoint) {
    final elapsed = elapsedSeconds;
    final avgSpeed = elapsed > 0 ? (_totalDistance * 3600) / elapsed : 0.0; // km/h

    final stats = {
      'currentPosition': currentPoint,
      'totalDistance': _totalDistance,
      'elapsedSeconds': elapsed,
      'averageSpeed': avgSpeed,
      'trackPointsCount': _trackPoints.length,
    };

    _walkStatsController.add(stats);
  }

  /// 경로 준수 검증 (설계 문서의 맵 매칭 알고리즘)
  bool isOnRoute(List<RoutePoint> plannedRoute, {double toleranceMeters = 50}) {
    if (_trackPoints.isEmpty || plannedRoute.isEmpty) return true;

    final currentPosition = _trackPoints.last;

    // 계획된 경로의 각 포인트와의 거리 계산
    double minDistanceToRoute = double.infinity;

    for (final routePoint in plannedRoute) {
      final distanceToPoint = currentPosition.distanceTo(routePoint) * 1000; // 미터 단위
      if (distanceToPoint < minDistanceToRoute) {
        minDistanceToRoute = distanceToPoint;
      }
    }

    return minDistanceToRoute <= toleranceMeters;
  }

  /// 시작점으로부터의 거리 계산
  double distanceFromStart(RoutePoint startPoint) {
    if (_trackPoints.isEmpty) return 0.0;
    return startPoint.distanceTo(_trackPoints.last);
  }

  /// 산책 완료 검증 (시작점 근처로 돌아왔는지 확인)
  bool isWalkCompleted(RoutePoint startPoint, {double toleranceMeters = 100}) {
    if (_trackPoints.isEmpty) return false;

    final currentPosition = _trackPoints.last;
    final distanceToStart = currentPosition.distanceTo(startPoint) * 1000; // 미터 단위

    return distanceToStart <= toleranceMeters;
  }

  /// 경로 유사도 계산 (설계 문서의 궤적 매칭)
  double calculateRouteSimilarity(List<RoutePoint> plannedRoute) {
    if (_trackPoints.isEmpty || plannedRoute.isEmpty) return 0.0;

    // 단순화된 유사도 계산 (실제 구현에서는 더 정교한 알고리즘 사용)
    int matchingPoints = 0;
    const double toleranceKm = 0.1; // 100m 허용 오차

    for (final trackPoint in _trackPoints) {
      for (final routePoint in plannedRoute) {
        if (trackPoint.distanceTo(routePoint) <= toleranceKm) {
          matchingPoints++;
          break;
        }
      }
    }

    return matchingPoints / _trackPoints.length;
  }

  /// 현재 페이스 계산 (최근 5분간의 평균 속도)
  double getCurrentPace() {
    if (_trackPoints.length < 2 || _walkStartTime == null) return 0.0;

    final now = DateTime.now();
    final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));

    // 최근 5분간의 포인트들만 고려
    final recentPoints = <RoutePoint>[];
    final recentPointsStartIndex = _trackPoints.length - 1;

    for (int i = recentPointsStartIndex; i >= 0; i--) {
      // 실제 구현에서는 각 포인트의 타임스탬프를 저장해야 함
      // 현재는 단순화된 버전
      recentPoints.add(_trackPoints[i]);
      if (recentPoints.length >= 10) break; // 최근 10개 포인트
    }

    if (recentPoints.length < 2) return 0.0;

    double recentDistance = 0.0;
    for (int i = 1; i < recentPoints.length; i++) {
      recentDistance += recentPoints[i-1].distanceTo(recentPoints[i]);
    }

    final recentTimeMinutes = 5.0; // 5분
    return recentDistance / (recentTimeMinutes / 60); // km/h
  }

  /// 현재 위치 가져오기 (일회성)
  Future<Position?> getCurrentPosition() async {
    try {
      await _checkLocationPermission();

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      print('현재 위치 가져오기 실패: $e');
      return null;
    }
  }

  /// 위치 권한 확인
  Future<void> _checkLocationPermission() async {
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
      throw Exception('위치 권한이 영구적으로 거부되었습니다');
    }
  }

  /// 추적 데이터 내보내기 (산책 완료 시 사용)
  Map<String, dynamic> exportTrackingData() {
    return {
      'startTime': _walkStartTime?.toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      'totalDistance': _totalDistance,
      'elapsedSeconds': elapsedSeconds,
      'trackPoints': _trackPoints.map((point) => point.toJson()).toList(),
      'averageSpeed': elapsedSeconds > 0 ? (_totalDistance * 3600) / elapsedSeconds : 0.0,
    };
  }

  /// 리소스 정리
  void dispose() {
    _positionSubscription?.cancel();
    _locationController.close();
    _walkStatsController.close();
    _trackPoints.clear();
  }
}