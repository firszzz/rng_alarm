part of 'alarm_editor_bloc.dart';

/// Snapshot of the alarm form
sealed class AlarmEditorState {
  AlarmEditorState({
    required this.alarmId,
    required this.from,
    required this.to,
    required this.name,
    required this.isEnabled,
    required this.vibrates,
  });

  /// Identifier of the alarm being edited
  ///
  /// Null when the form creates a new alarm
  final String? alarmId;

  /// First minute of the window shown in the form
  final AlarmTime from;

  /// Last minute of the window shown in the form
  final AlarmTime to;

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
    required super.from,
    required super.to,
    required super.name,
    required super.isEnabled,
    required super.vibrates,
  });

  AlarmEditorEditingState.empty()
    : this(
        alarmId: null,
        from: AlarmTime(hour: 6, minute: 40),
        to: AlarmTime(hour: 7, minute: 0),
        name: '',
        isEnabled: true,
        vibrates: true,
      );

  /// Copy with the given fields replaced
  ///
  /// A null argument keeps the current value
  AlarmEditorEditingState copyWith({AlarmTime? from, AlarmTime? to, String? name, bool? vibrates}) {
    return AlarmEditorEditingState(
      alarmId: alarmId,
      from: from ?? this.from,
      to: to ?? this.to,
      name: name ?? this.name,
      isEnabled: isEnabled,
      vibrates: vibrates ?? this.vibrates,
    );
  }
}
