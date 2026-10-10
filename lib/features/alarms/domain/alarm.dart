import 'package:equatable/equatable.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';

/// Alarm
class Alarm with Equatable {
  const Alarm({
    required this.id,
    required this.from,
    required this.to,
    required this.name,
    required this.isEnabled,
    required this.vibrates,
  });

  /// Identifier of the alarm
  final String id;

  /// First minute of the window, inclusive
  final AlarmTime from;

  /// Last minute of the window, inclusive
  final AlarmTime to;

  /// Name entered by the user
  ///
  /// Empty when the user left the name blank
  final String name;

  /// Whether the alarm is switched on
  final bool isEnabled;

  /// Whether the alarm vibrates while it rings
  final bool vibrates;

  /// Copy with the given fields replaced
  ///
  /// A null argument keeps the current value
  Alarm copyWith({AlarmTime? from, AlarmTime? to, String? name, bool? isEnabled, bool? vibrates}) {
    return Alarm(
      id: id,
      from: from ?? this.from,
      to: to ?? this.to,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      vibrates: vibrates ?? this.vibrates,
    );
  }

  @override
  List<Object?> get props => [id, from, to, name, isEnabled, vibrates];
}
