import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alarm_dto.g.dart';

/// Stored alarm, including the ring minute the screen never reads
@JsonSerializable()
class AlarmDto with Equatable {
  const AlarmDto({
    required this.id,
    required this.nativeId,
    required this.fromHour,
    required this.fromMinute,
    required this.toHour,
    required this.toMinute,
    required this.name,
    required this.isEnabled,
    required this.vibrates,
    this.ringHour,
    this.ringMinute,
    this.scheduledAt,
  });

  /// Parses a record written by [toJson]
  factory AlarmDto.fromJson(Map<String, dynamic> json) => _$AlarmDtoFromJson(json);

  /// Identifier of the alarm
  final String id;

  /// Identifier passed to the native alarm scheduler
  ///
  /// Stable for the life of the alarm and different from 0 and -1
  final int nativeId;

  /// Start hour of the window, from 0 through 23
  final int fromHour;

  /// Start minute of the window, from 0 through 59
  final int fromMinute;

  /// End hour of the window, from 0 through 23
  final int toHour;

  /// End minute of the window, from 0 through 59
  final int toMinute;

  /// Name entered by the user
  ///
  /// Empty when the user left the name blank
  final String name;

  /// Whether the alarm is switched on
  final bool isEnabled;

  /// Whether the alarm vibrates while it rings
  final bool vibrates;

  /// Hour of the chosen ring minute
  ///
  /// Null when the alarm is not scheduled
  final int? ringHour;

  /// Minute of the chosen ring minute
  ///
  /// Null when the alarm is not scheduled
  final int? ringMinute;

  /// Local instant when this alarm is due to ring
  ///
  /// Null when the alarm is not scheduled
  final DateTime? scheduledAt;

  /// Serializes this record
  Map<String, dynamic> toJson() => _$AlarmDtoToJson(this);

  @override
  List<Object?> get props => [
    id,
    nativeId,
    fromHour,
    fromMinute,
    toHour,
    toMinute,
    name,
    isEnabled,
    vibrates,
    ringHour,
    ringMinute,
    scheduledAt,
  ];
}
