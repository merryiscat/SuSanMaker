import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// 사용자 모델 (섹션 4.1: /users/{userId})
/// 설계 문서에 따른 통계 및 장착된 아이템 정보 포함
@JsonSerializable()
class User {
  /// Firebase Auth UID
  final String uid;

  /// 사용자 이메일
  final String email;

  /// 표시 이름
  final String displayName;

  /// 계정 생성 시간
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  /// 현재 포인트 잔액 (게임 내 재화)
  final int pointsBalance;

  /// 통계 데이터 (섹션 4.1의 stats Map)
  final UserStats stats;

  /// 장착된 아이템 (빠른 아바타 렌더링을 위한 비정규화, 섹션 4.1)
  final Map<String, String> equippedItems;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.pointsBalance = 0,
    this.stats = const UserStats(),
    this.equippedItems = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    int? pointsBalance,
    UserStats? stats,
    Map<String, String>? equippedItems,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      stats: stats ?? this.stats,
      equippedItems: equippedItems ?? this.equippedItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.createdAt == createdAt &&
        other.pointsBalance == pointsBalance &&
        other.stats == stats;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        createdAt.hashCode ^
        pointsBalance.hashCode ^
        stats.hashCode;
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, pointsBalance: $pointsBalance, stats: $stats)';
  }

  // Helper methods for Firestore timestamp conversion
  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

/// 사용자 통계 (섹션 4.1의 stats Map 구조화)
@JsonSerializable()
class UserStats {
  /// 총 누적 거리 (km)
  final double totalDistance;

  /// 총 완료된 산책 수
  final int totalWalks;

  /// 현재 연속 산책 기록
  final int currentStreak;

  /// 최고 연속 기록
  final int maxStreak;

  /// 마지막 산책 날짜
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? lastWalkDate;

  const UserStats({
    this.totalDistance = 0.0,
    this.totalWalks = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.lastWalkDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  UserStats copyWith({
    double? totalDistance,
    int? totalWalks,
    int? currentStreak,
    int? maxStreak,
    DateTime? lastWalkDate,
  }) {
    return UserStats(
      totalDistance: totalDistance ?? this.totalDistance,
      totalWalks: totalWalks ?? this.totalWalks,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      lastWalkDate: lastWalkDate ?? this.lastWalkDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
        other.totalDistance == totalDistance &&
        other.totalWalks == totalWalks &&
        other.currentStreak == currentStreak &&
        other.maxStreak == maxStreak &&
        other.lastWalkDate == lastWalkDate;
  }

  @override
  int get hashCode {
    return totalDistance.hashCode ^
        totalWalks.hashCode ^
        currentStreak.hashCode ^
        maxStreak.hashCode ^
        lastWalkDate.hashCode;
  }

  @override
  String toString() {
    return 'UserStats(totalDistance: $totalDistance, totalWalks: $totalWalks, currentStreak: $currentStreak, maxStreak: $maxStreak)';
  }

  // Helper methods for nullable DateTime conversion
  static DateTime? _dateTimeFromJson(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  static dynamic _dateTimeToJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}