import 'dart:math' as dart_math;
import 'package:json_annotation/json_annotation.dart';

part 'route_point.g.dart';

/// 경로상의 한 지점을 나타내는 모델
/// 설계 문서 섹션 2.2: 무작위 경로 생성을 위한 좌표 데이터
@JsonSerializable()
class RoutePoint {
  /// 위도
  final double latitude;

  /// 경도
  final double longitude;

  /// 고도 (선택사항)
  final double? altitude;

  /// 이 지점에서의 메모나 설명 (선택사항)
  final String? description;

  /// 이 지점이 기록된 시간 (위치 추적용)
  final DateTime? timestamp;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.description,
    this.timestamp,
  });

  /// JSON에서 RoutePoint 객체 생성
  factory RoutePoint.fromJson(Map<String, dynamic> json) =>
      _$RoutePointFromJson(json);

  /// RoutePoint 객체를 JSON으로 변환
  Map<String, dynamic> toJson() => _$RoutePointToJson(this);

  /// 다른 RoutePoint와의 거리 계산 (Haversine 공식, km 단위)
  double distanceTo(RoutePoint other) {
    return _calculateDistance(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }

  /// Haversine 공식을 사용한 거리 계산
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    const double toRadians = 3.141592653589793 / 180;

    final lat1Rad = lat1 * toRadians;
    final lat2Rad = lat2 * toRadians;
    final deltaLatRad = (lat2 - lat1) * toRadians;
    final deltaLonRad = (lon2 - lon1) * toRadians;

    final a = (deltaLatRad / 2).sin() * (deltaLatRad / 2).sin() +
        lat1Rad.cos() *
            lat2Rad.cos() *
            (deltaLonRad / 2).sin() *
            (deltaLonRad / 2).sin();

    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());

    return earthRadius * c;
  }

  /// 객체 복사 (일부 필드 수정)
  RoutePoint copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    String? description,
    DateTime? timestamp,
  }) {
    return RoutePoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'RoutePoint(lat: ${latitude.toStringAsFixed(6)}, lng: ${longitude.toStringAsFixed(6)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoutePoint &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.altitude == altitude &&
        other.description == description &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        altitude.hashCode ^
        description.hashCode ^
        timestamp.hashCode;
  }
}

/// 확장 함수 - double에 sin/cos/atan2 메서드 추가 (math import 없이 사용)
extension MathExtensions on double {
  double sin() => dart_math.sin(this);
  double cos() => dart_math.cos(this);
  double sqrt() => dart_math.sqrt(this);
  double atan2(double x) => dart_math.atan2(this, x);
}