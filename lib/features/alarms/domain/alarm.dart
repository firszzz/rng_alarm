import 'package:equatable/equatable.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';

/// Alarm
class Alarm with Equatable {
  const Alarm({required this.id, required this.time, required this.name, required this.isEnabled, required this.vibrates});

  /// Identifier of the alarm
  final String id;

  /// Clock time of the alarm
  final AlarmTime time;

  /// Name entered by the user
  ///
  /// Empty when the user left the name blank
  final String name;

  /// Whether the alarm is switched on
  final bool isEnabled;

  /// Whether the alarm vibrates while it rings
  final bool vibrates;

  Alarm copyWith({AlarmTime? time, String? name, bool? isEnabled, bool? vibrates}) {
    return Alarm(
      id: id,
      time: time ?? this.time,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      vibrates: vibrates ?? this.vibrates,
    );
  }

  @override
  List<Object?> get props => [id, time, name, isEnabled, vibrates];
}
