// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratedRoute _$GeneratedRouteFromJson(Map<String, dynamic> json) =>
    GeneratedRoute(
      routeId: json['routeId'] as String,
      startPoint:
          RoutePoint.fromJson(json['startPoint'] as Map<String, dynamic>),
      waypoints: (json['waypoints'] as List<dynamic>)
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      polylinePoints: (json['polylinePoints'] as List<dynamic>)
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      createdAt:
          GeneratedRoute._dateTimeFromJson((json['createdAt'] as num).toInt()),
      description: json['description'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GeneratedRouteToJson(GeneratedRoute instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'startPoint': instance.startPoint,
      'waypoints': instance.waypoints,
      'polylinePoints': instance.polylinePoints,
      'totalDistance': instance.totalDistance,
      'estimatedDuration': instance.estimatedDuration,
      'createdAt': GeneratedRoute._dateTimeToJson(instance.createdAt),
      'description': instance.description,
      'difficulty': instance.difficulty,
    };
