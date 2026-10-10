part of 'alarm_editor_bloc.dart';

/// Snapshot of the alarm form
sealed class AlarmEditorState {
  AlarmEditorState({required this.alarmId, required this.time, required this.name, required this.isEnabled, required this.vibrates});

  /// Identifier of the alarm being edited
  ///
  /// Null when the form creates a new alarm
  final String? alarmId;

  /// Time shown in the form
  final AlarmTime time;

  /// Name shown in the form, including surrounding spaces
  final String name;

  /// Whether the saved alarm stays switched on
  final bool isEnabled;

  /// Whether vibration is enabled in the form
  final bool vibrates;
}

/// Form fields ready to edit
class AlarmEditorEditingState extends AlarmEditorState {
  AlarmEditorEditingState({
    required super.alarmId,
    required super.time,
    required super.name,
    required super.isEnabled,
    required super.vibrates,
  });

  /// Copy with the given fields replaced
  ///
  /// A null argument keeps the current value
  AlarmEditorEditingState copyWith({AlarmTime? time, String? name, bool? vibrates}) {
    return AlarmEditorEditingState(
      alarmId: alarmId,
      time: time ?? this.time,
      name: name ?? this.name,
      isEnabled: isEnabled,
      vibrates: vibrates ?? this.vibrates,
    );
  }
}
