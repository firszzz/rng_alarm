import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';

part 'alarm_editor_effect.dart';
part 'alarm_editor_event.dart';
part 'alarm_editor_state.dart';

const _defaultTime = AlarmTime(hour: 7, minute: 0);

/// BLoC of the alarm editor
class AlarmEditorBloc extends Bloc<AlarmEditorEvent, AlarmEditorState> {
  AlarmEditorBloc({String Function()? createId})
    : _createId = createId ?? _createAlarmId,
      super(AlarmEditorEditingState(alarmId: null, time: _defaultTime, name: '', isEnabled: true, vibrates: true)) {
    on<AlarmEditorStartedEvent>(_handleStartedEvent);
    on<AlarmEditorTimeChangedEvent>(_handleTimeChangedEvent);
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

  void _handleStartedEvent(AlarmEditorStartedEvent event, Emitter<AlarmEditorState> emit) {
    final alarm = event.alarm;
    if (alarm == null) {
      emit(AlarmEditorEditingState(alarmId: null, time: _defaultTime, name: '', isEnabled: true, vibrates: true));
      return;
    }

    emit(
      AlarmEditorEditingState(alarmId: alarm.id, time: alarm.time, name: alarm.name, isEnabled: alarm.isEnabled, vibrates: alarm.vibrates),
    );
  }

  void _handleTimeChangedEvent(AlarmEditorTimeChangedEvent event, Emitter<AlarmEditorState> emit) {
    emit(_editing.copyWith(time: event.time));
  }

  void _handleNameChangedEvent(AlarmEditorNameChangedEvent event, Emitter<AlarmEditorState> emit) {
    emit(_editing.copyWith(name: event.name));
  }

  void _handleVibrationChangedEvent(AlarmEditorVibrationChangedEvent event, Emitter<AlarmEditorState> emit) {
    emit(_editing.copyWith(vibrates: event.vibrates));
  }

  void _handleSaveEvent(AlarmEditorSaveEvent event, Emitter<AlarmEditorState> emit) {
    final current = _editing;
    _effects.add(
      AlarmEditorSavedEffect(
        Alarm(
          id: current.alarmId ?? _createId(),
          time: current.time,
          name: current.name.trim(),
          isEnabled: current.isEnabled,
          vibrates: current.vibrates,
        ),
      ),
    );
  }

  AlarmEditorEditingState get _editing => state as AlarmEditorEditingState;

  @override
  Future<void> close() async {
    await _effects.close();
    await super.close();
  }
}

String _createAlarmId() => DateTime.now().microsecondsSinceEpoch.toString();
