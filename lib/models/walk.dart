import 'package:cloud_firestore/cloud_firestore.dart';

/// 산책 기록을 나타내는 데이터 모델 클래스
/// Firestore의 walks 컬렉션에 저장되는 완료된 산책 정보를 정의합니다
class Walk {
  /// 산책 기록 고유 ID
  final String walkId;

  /// 산책을 완료한 사용자 ID
  final String userId;

  /// 산책 완료 시간
  final DateTime completedAt;

  /// 사용자가 요청한 목표 거리 (미터 단위)
  final double requestedDistance;

  /// 실제로 걸은 거리 (미터 단위)
  final double actualDistance;

  /// 산책에 소요된 시간 (초 단위)
  final int durationInSeconds;

  /// 이 산책으로 획득한 포인트
  final int pointsAwarded;

  /// 생성된 산책 경로의 인코딩된 폴리라인
  final String routePolyline;

  /// 사용자가 실제로 걸은 경로의 인코딩된 폴리라인
  final String userTrackPolyline;

  /// Walk 생성자
  const Walk({
    required this.walkId,
    required this.userId,
    required this.completedAt,
    required this.requestedDistance,
    required this.actualDistance,
    required this.durationInSeconds,
    required this.pointsAwarded,
    required this.routePolyline,
    required this.userTrackPolyline,
  });

  /// Firestore 문서에서 Walk 객체로 변환하는 팩토리 생성자
  factory Walk.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Walk(
      walkId: doc.id,
      userId: data['userId'] ?? '',
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      requestedDistance: (data['requestedDistance'] ?? 0.0).toDouble(),
      actualDistance: (data['actualDistance'] ?? 0.0).toDouble(),
      durationInSeconds: data['durationInSeconds'] ?? 0,
      pointsAwarded: data['pointsAwarded'] ?? 0,
      routePolyline: data['routePolyline'] ?? '',
      userTrackPolyline: data['userTrackPolyline'] ?? '',
    );
  }

  /// JSON Map에서 Walk 객체를 생성하는 팩토리 생성자
  factory Walk.fromJson(Map<String, dynamic> json) {
    return Walk(
      walkId: json['walkId'],
      userId: json['userId'],
      completedAt: DateTime.fromMillisecondsSinceEpoch(json['completedAt']),
      requestedDistance: json['requestedDistance'].toDouble(),
      actualDistance: json['actualDistance'].toDouble(),
      durationInSeconds: json['durationInSeconds'],
      pointsAwarded: json['pointsAwarded'],
      routePolyline: json['routePolyline'],
      userTrackPolyline: json['userTrackPolyline'],
    );
  }

  /// Walk 객체를 Firestore에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'completedAt': Timestamp.fromDate(completedAt),
      'requestedDistance': requestedDistance,
      'actualDistance': actualDistance,
      'durationInSeconds': durationInSeconds,
      'pointsAwarded': pointsAwarded,
      'routePolyline': routePolyline,
      'userTrackPolyline': userTrackPolyline,
    };
  }

  /// Walk 객체를 JSON Map으로 변환
  Map<String, dynamic> toJson() {
    return {
      'walkId': walkId,
      'userId': userId,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'requestedDistance': requestedDistance,
      'actualDistance': actualDistance,
      'durationInSeconds': durationInSeconds,
      'pointsAwarded': pointsAwarded,
      'routePolyline': routePolyline,
      'userTrackPolyline': userTrackPolyline,
    };
  }

  /// 산책 시간을 사람이 읽기 쉬운 형태로 반환
  String get formattedDuration {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;
    return '${minutes}분 ${seconds}초';
  }

  /// 요청 거리와 실제 거리의 차이 비율을 반환 (0.0 ~ 1.0)
  double get accuracyRate {
    if (requestedDistance == 0) return 0.0;
    final difference = (actualDistance - requestedDistance).abs();
    return 1.0 - (difference / requestedDistance);
  }

  /// 평균 속도를 반환 (km/h)
  double get averageSpeed {
    if (durationInSeconds == 0) return 0.0;
    final hours = durationInSeconds / 3600.0;
    final kilometers = actualDistance / 1000.0;
    return kilometers / hours;
  }

  /// Walk 객체의 특정 필드를 업데이트한 새 객체를 반환
  Walk copyWith({
    String? walkId,
    String? userId,
    DateTime? completedAt,
    double? requestedDistance,
    double? actualDistance,
    int? durationInSeconds,
    int? pointsAwarded,
    String? routePolyline,
    String? userTrackPolyline,
  }) {
    return Walk(
      walkId: walkId ?? this.walkId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      requestedDistance: requestedDistance ?? this.requestedDistance,
      actualDistance: actualDistance ?? this.actualDistance,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      routePolyline: routePolyline ?? this.routePolyline,
      userTrackPolyline: userTrackPolyline ?? this.userTrackPolyline,
    );
  }

  @override
  String toString() {
    return 'Walk(walkId: $walkId, userId: $userId, actualDistance: ${actualDistance.toStringAsFixed(0)}m, points: $pointsAwarded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Walk &&
        other.walkId == walkId &&
        other.userId == userId &&
        other.completedAt == completedAt &&
        other.requestedDistance == requestedDistance &&
        other.actualDistance == actualDistance &&
        other.durationInSeconds == durationInSeconds &&
        other.pointsAwarded == pointsAwarded;
  }

  @override
  int get hashCode {
    return walkId.hashCode ^
        userId.hashCode ^
        completedAt.hashCode ^
        requestedDistance.hashCode ^
        actualDistance.hashCode ^
        durationInSeconds.hashCode ^
        pointsAwarded.hashCode;
  }
}