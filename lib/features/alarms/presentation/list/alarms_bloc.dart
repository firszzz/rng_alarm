import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';

part 'alarms_event.dart';
part 'alarms_state.dart';

/// BLoC of the main alarm screen
class AlarmsBloc extends Bloc<AlarmsEvent, AlarmsState> {
  AlarmsBloc() : super(AlarmsContentState(alarms: [])) {
    on<AlarmsStartedEvent>(_handleStartedEvent);
    on<AlarmsToggleEvent>(_handleToggleEvent);
    on<AlarmsDeleteEvent>(_handleDeleteEvent);
    on<AlarmsUpsertEvent>(_handleUpsertEvent);
  }

  void _handleStartedEvent(AlarmsStartedEvent event, Emitter<AlarmsState> emit) {
    emit(AlarmsContentState(alarms: state.alarms));
  }

  void _handleToggleEvent(AlarmsToggleEvent event, Emitter<AlarmsState> emit) {
    final index = state.alarms.indexWhere((alarm) => alarm.id == event.id);
    if (index < 0) {
      return;
    }

    final updated = [...state.alarms];
    final alarm = updated[index];
    updated[index] = alarm.copyWith(isEnabled: !alarm.isEnabled);
    emit(AlarmsContentState(alarms: updated));
  }

  void _handleDeleteEvent(AlarmsDeleteEvent event, Emitter<AlarmsState> emit) {
    final updated = state.alarms.where((alarm) => alarm.id != event.id).toList();
    if (updated.length == state.alarms.length) {
      return;
    }

    emit(AlarmsContentState(alarms: updated));
  }

  void _handleUpsertEvent(AlarmsUpsertEvent event, Emitter<AlarmsState> emit) {
    final index = state.alarms.indexWhere((alarm) => alarm.id == event.alarm.id);
    final updated = [...state.alarms];
    if (index >= 0) {
      updated[index] = event.alarm;
    } else {
      updated.add(event.alarm);
    }

    emit(AlarmsContentState(alarms: updated));
  }
}
