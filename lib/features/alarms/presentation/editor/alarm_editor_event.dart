part of 'alarm_editor_bloc.dart';

/// Fact reported to the alarm form
sealed class AlarmEditorEvent {
  const AlarmEditorEvent();
}

/// Screen opened the form for a new or existing alarm
class AlarmEditorStartedEvent extends AlarmEditorEvent {
  const AlarmEditorStartedEvent(this.alarm);

  /// Alarm opened in the form
  ///
  /// Null when the form creates a new alarm
  final Alarm? alarm;
}

/// User picked another time
class AlarmEditorTimeChangedEvent extends AlarmEditorEvent {
  const AlarmEditorTimeChangedEvent(this.time);

  /// Time chosen in the form
  final AlarmTime time;
}

/// User edited the name
class AlarmEditorNameChangedEvent extends AlarmEditorEvent {
  const AlarmEditorNameChangedEvent(this.name);

  /// Name typed in the form, not yet trimmed
  final String name;
}

/// User switched vibration
class AlarmEditorVibrationChangedEvent extends AlarmEditorEvent {
  const AlarmEditorVibrationChangedEvent(this.vibrates);

  /// Whether vibration is enabled in the form
  final bool vibrates;
}

/// User confirmed the form
class AlarmEditorSaveEvent extends AlarmEditorEvent {
  const AlarmEditorSaveEvent();
}
