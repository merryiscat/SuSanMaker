// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePoint _$RoutePointFromJson(Map<String, dynamic> json) => RoutePoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$RoutePointToJson(RoutePoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'altitude': instance.altitude,
      'description': instance.description,
      'timestamp': instance.timestamp?.toIso8601String(),
    };
