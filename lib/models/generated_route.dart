import 'package:json_annotation/json_annotation.dart';
import 'route_point.dart';

part 'generated_route.g.dart';

/// 생성된 무작위 산책로를 나타내는 모델
/// 설계 문서 섹션 2.2: 무작위 경로 생성 알고리즘의 결과물
@JsonSerializable()
class GeneratedRoute {
  /// 경로 고유 ID
  final String routeId;

  /// 시작점
  final RoutePoint startPoint;

  /// 경유지들 (Random Walk으로 생성된 시드 포인트들)
  final List<RoutePoint> waypoints;

  /// 실제 경로의 모든 좌표점들 (폴리라인)
  final List<RoutePoint> polylinePoints;

  /// 총 거리 (km)
  final double totalDistance;

  /// 예상 소요 시간 (분)
  final int estimatedDuration;

  /// 경로 생성 시간
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  /// 경로의 설명 (선택사항)
  final String? description;

  /// 경로 난이도 (1-5, 선택사항)
  final int? difficulty;

  const GeneratedRoute({
    required this.routeId,
    required this.startPoint,
    required this.waypoints,
    required this.polylinePoints,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.createdAt,
    this.description,
    this.difficulty,
  });

  /// JSON에서 GeneratedRoute 객체 생성
  factory GeneratedRoute.fromJson(Map<String, dynamic> json) =>
      _$GeneratedRouteFromJson(json);

  /// GeneratedRoute 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$GeneratedRouteToJson(this);

  /// Google Polyline Algorithm으로 인코딩된 폴리라인 문자열 생성
  String get encodedPolyline {
    // google_polyline_algorithm 패키지 사용 예정
    // 현재는 단순한 좌표 문자열로 대체
    return polylinePoints
        .map((point) => '${point.latitude},${point.longitude}')
        .join('|');
  }

  /// 경로의 바운딩 박스 (지도 표시용)
  Map<String, double> get boundingBox {
    if (polylinePoints.isEmpty) {
      return {
        'minLat': startPoint.latitude,
        'maxLat': startPoint.latitude,
        'minLng': startPoint.longitude,
        'maxLng': startPoint.longitude,
      };
    }

    double minLat = polylinePoints.first.latitude;
    double maxLat = polylinePoints.first.latitude;
    double minLng = polylinePoints.first.longitude;
    double maxLng = polylinePoints.first.longitude;

    for (final point in polylinePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }

  /// 경로의 중심점 계산
  RoutePoint get centerPoint {
    final bounds = boundingBox;
    return RoutePoint(
      latitude: (bounds['minLat']! + bounds['maxLat']!) / 2,
      longitude: (bounds['minLng']! + bounds['maxLng']!) / 2,
    );
  }

  /// 예상 칼로리 소모량 계산 (대략적인 값)
  /// 체중 70kg 기준, 시속 4-5km 걷기
  int get estimatedCalories {
    // 1km당 약 50칼로리 소모 가정
    return (totalDistance * 50).round();
  }

  /// 경로 유효성 검증
  bool get isValid {
    return routeId.isNotEmpty &&
           polylinePoints.length >= 2 &&
           totalDistance > 0 &&
           estimatedDuration > 0;
  }

  /// 객체 복사 (일부 필드 수정)
  GeneratedRoute copyWith({
    String? routeId,
    RoutePoint? startPoint,
    List<RoutePoint>? waypoints,
    List<RoutePoint>? polylinePoints,
    double? totalDistance,
    int? estimatedDuration,
    DateTime? createdAt,
    String? description,
    int? difficulty,
  }) {
    return GeneratedRoute(
      routeId: routeId ?? this.routeId,
      startPoint: startPoint ?? this.startPoint,
      waypoints: waypoints ?? this.waypoints,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  String toString() {
    return 'GeneratedRoute(id: $routeId, distance: ${totalDistance.toStringAsFixed(2)}km, '
           'duration: ${estimatedDuration}min, waypoints: ${waypoints.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeneratedRoute &&
        other.routeId == routeId &&
        other.startPoint == startPoint &&
        _listEquals(other.waypoints, waypoints) &&
        _listEquals(other.polylinePoints, polylinePoints) &&
        other.totalDistance == totalDistance &&
        other.estimatedDuration == estimatedDuration &&
        other.createdAt == createdAt &&
        other.description == description &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return routeId.hashCode ^
        startPoint.hashCode ^
        waypoints.hashCode ^
        polylinePoints.hashCode ^
        totalDistance.hashCode ^
        estimatedDuration.hashCode ^
        createdAt.hashCode ^
        description.hashCode ^
        difficulty.hashCode;
  }

  /// DateTime JSON 직렬화 헬퍼
  static DateTime _dateTimeFromJson(int millisecondsSinceEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

  static int _dateTimeToJson(DateTime dateTime) =>
      dateTime.millisecondsSinceEpoch;

  /// List 비교 헬퍼
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }
}