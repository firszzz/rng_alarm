// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlarmDto _$AlarmDtoFromJson(Map<String, dynamic> json) => AlarmDto(
  id: json['id'] as String,
  nativeId: (json['nativeId'] as num).toInt(),
  fromHour: (json['fromHour'] as num).toInt(),
  fromMinute: (json['fromMinute'] as num).toInt(),
  toHour: (json['toHour'] as num).toInt(),
  toMinute: (json['toMinute'] as num).toInt(),
  name: json['name'] as String,
  isEnabled: json['isEnabled'] as bool,
  vibrates: json['vibrates'] as bool,
  ringHour: (json['ringHour'] as num?)?.toInt(),
  ringMinute: (json['ringMinute'] as num?)?.toInt(),
  scheduledAt: json['scheduledAt'] == null ? null : DateTime.parse(json['scheduledAt'] as String),
);

Map<String, dynamic> _$AlarmDtoToJson(AlarmDto instance) => <String, dynamic>{
  'id': instance.id,
  'nativeId': instance.nativeId,
  'fromHour': instance.fromHour,
  'fromMinute': instance.fromMinute,
  'toHour': instance.toHour,
  'toMinute': instance.toMinute,
  'name': instance.name,
  'isEnabled': instance.isEnabled,
  'vibrates': instance.vibrates,
  'ringHour': instance.ringHour,
  'ringMinute': instance.ringMinute,
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
};
