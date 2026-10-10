part of 'alarm_editor_bloc.dart';

/// One-shot result of the alarm form
sealed class AlarmEditorEffect with Equatable {
  const AlarmEditorEffect();

  @override
  List<Object?> get props => [];
}

/// Alarm produced by saving the form
final class AlarmEditorSavedEffect extends AlarmEditorEffect {
  const AlarmEditorSavedEffect(this.alarm);

  /// Alarm built from the form, with the name trimmed
  final Alarm alarm;

  @override
  List<Object?> get props => [alarm];
}

/// Save rejected because the window cannot ring
final class AlarmEditorInvalidEffect extends AlarmEditorEffect {
  const AlarmEditorInvalidEffect(this.issue);

  /// Why the window was rejected
  final AlarmWindowIssue issue;

  @override
  List<Object?> get props => [issue];
}
