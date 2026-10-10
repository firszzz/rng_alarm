import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_window.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_window_issue.dart';

part 'alarm_editor_effect.dart';

part 'alarm_editor_event.dart';

part 'alarm_editor_state.dart';

/// BLoC of the alarm editor
class AlarmEditorBloc extends Bloc<AlarmEditorEvent, AlarmEditorState> {
  AlarmEditorBloc({String Function()? createId}) : _createId = createId ?? _createAlarmId, super(AlarmEditorEditingState.empty()) {
    on<AlarmEditorStartedEvent>(_handleStartedEvent);
    on<AlarmEditorFromChangedEvent>(_handleFromChangedEvent);
    on<AlarmEditorToChangedEvent>(_handleToChangedEvent);
    on<AlarmEditorNameChangedEvent>(_handleNameChangedEvent);
    on<AlarmEditorVibrationChangedEvent>(_handleVibrationChangedEvent);
    on<AlarmEditorSaveEvent>(_handleSaveEvent);
  }

  final String Function() _createId;
  final _effects = StreamController<AlarmEditorEffect>.broadcast();

  /// One saved alarm per successful save
  ///
  /// Nothing is emitted when the form only changes its fields
  Stream<AlarmEditorEffect> get effects => _effects.stream;

  @override
  Future<void> close() async {
    await _effects.close();
    await super.close();
  }

  void _handleStartedEvent(AlarmEditorStartedEvent event, Emitter<AlarmEditorState> emit) {
    final alarm = event.alarm;
    if (alarm == null) {
      emit(AlarmEditorEditingState.empty());
      return;
    }

    emit(
      AlarmEditorEditingState(
        alarmId: alarm.id,
        from: alarm.from,
        to: alarm.to,
        name: alarm.name,
        isEnabled: alarm.isEnabled,
        vibrates: alarm.vibrates,
      ),
    );
  }

  void _handleFromChangedEvent(AlarmEditorFromChangedEvent event, Emitter<AlarmEditorState> emit) {
    emit(_editing.copyWith(from: event.from));
  }

  void _handleToChangedEvent(AlarmEditorToChangedEvent event, Emitter<AlarmEditorState> emit) {
    emit(_editing.copyWith(to: event.to));
  }

  void _handleNameChangedEvent(AlarmEditorNameChangedEvent event, Emitter<AlarmEditorState> emit) {
    emit(_editing.copyWith(name: event.name));
  }

  void _handleVibrationChangedEvent(AlarmEditorVibrationChangedEvent event, Emitter<AlarmEditorState> emit) {
    emit(_editing.copyWith(vibrates: event.vibrates));
  }

  void _handleSaveEvent(AlarmEditorSaveEvent event, Emitter<AlarmEditorState> emit) {
    final current = _editing;
    final issue = AlarmWindow(from: current.from, to: current.to).issue;
    if (issue != null) {
      _effects.add(AlarmEditorInvalidEffect(issue));
      return;
    }

    _effects.add(
      AlarmEditorSavedEffect(
        Alarm(
          id: current.alarmId ?? _createId(),
          from: current.from,
          to: current.to,
          name: current.name.trim(),
          isEnabled: current.isEnabled,
          vibrates: current.vibrates,
        ),
      ),
    );
  }

  AlarmEditorEditingState get _editing => state as AlarmEditorEditingState;
}

String _createAlarmId() => DateTime.now().microsecondsSinceEpoch.toString();
