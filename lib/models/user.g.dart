// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      createdAt: User._timestampFromJson(json['createdAt']),
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      stats: json['stats'] == null
          ? const UserStats()
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      equippedItems: (json['equippedItems'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'createdAt': User._timestampToJson(instance.createdAt),
      'pointsBalance': instance.pointsBalance,
      'stats': instance.stats,
      'equippedItems': instance.equippedItems,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
      totalWalks: (json['totalWalks'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      maxStreak: (json['maxStreak'] as num?)?.toInt() ?? 0,
      lastWalkDate: UserStats._dateTimeFromJson(json['lastWalkDate']),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'totalDistance': instance.totalDistance,
      'totalWalks': instance.totalWalks,
      'currentStreak': instance.currentStreak,
      'maxStreak': instance.maxStreak,
      'lastWalkDate': UserStats._dateTimeToJson(instance.lastWalkDate),
    };
