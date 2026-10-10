part of 'alarms_bloc.dart';

/// Snapshot of the alarm list
sealed class AlarmsState {
  AlarmsState({required this.alarms});

  /// Alarms in list order
  final List<Alarm> alarms;
}

/// Alarm list ready to draw
class AlarmsContentState extends AlarmsState {
  AlarmsContentState({required super.alarms});
}
