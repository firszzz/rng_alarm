part of 'alarms_bloc.dart';

/// Fact reported to the alarm list
sealed class AlarmsEvent with Equatable {
  const AlarmsEvent();

  @override
  List<Object?> get props => [];
}

/// Screen opened the alarm list
final class AlarmsStartedEvent extends AlarmsEvent {
  const AlarmsStartedEvent();
}

/// User switched one alarm on or off
final class AlarmsToggleEvent extends AlarmsEvent {
  const AlarmsToggleEvent(this.id);

  /// Identifier of the alarm to switch
  final String id;

  @override
  List<Object?> get props => [id];
}

/// User removed one alarm
final class AlarmsDeleteEvent extends AlarmsEvent {
  const AlarmsDeleteEvent(this.id);

  /// Identifier of the alarm to remove
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Editor returned an alarm to insert or replace
final class AlarmsUpsertEvent extends AlarmsEvent {
  const AlarmsUpsertEvent(this.alarm);

  /// Alarm to insert or replace by [Alarm.id]
  final Alarm alarm;

  @override
  List<Object?> get props => [alarm];
}
