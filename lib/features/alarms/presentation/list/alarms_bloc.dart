import 'package:bloc/bloc.dart';
import 'package:rng_alarm/features/alarms/data/alarms_repository.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';

part 'alarms_event.dart';
part 'alarms_state.dart';

/// BLoC of the main alarm screen
class AlarmsBloc extends Bloc<AlarmsEvent, AlarmsState> {
  AlarmsBloc(this._repository) : super(AlarmsContentState.empty()) {
    on<AlarmsStartedEvent>(_handleStartedEvent);
    on<AlarmsToggleEvent>(_handleToggleEvent);
    on<AlarmsDeleteEvent>(_handleDeleteEvent);
    on<AlarmsUpsertEvent>(_handleUpsertEvent);
  }

  final AlarmsRepository _repository;

  Future<void> _handleStartedEvent(AlarmsStartedEvent event, Emitter<AlarmsState> emit) async {
    emit(AlarmsContentState(alarms: await _repository.readAll()));
  }

  Future<void> _handleToggleEvent(AlarmsToggleEvent event, Emitter<AlarmsState> emit) async {
    final index = state.alarms.indexWhere((alarm) => alarm.id == event.id);
    if (index < 0) {
      return;
    }

    final alarm = state.alarms[index];
    emit(AlarmsContentState(alarms: await _repository.save(alarm.copyWith(isEnabled: !alarm.isEnabled))));
  }

  Future<void> _handleDeleteEvent(AlarmsDeleteEvent event, Emitter<AlarmsState> emit) async {
    if (!state.alarms.any((alarm) => alarm.id == event.id)) {
      return;
    }

    emit(AlarmsContentState(alarms: await _repository.delete(event.id)));
  }

  Future<void> _handleUpsertEvent(AlarmsUpsertEvent event, Emitter<AlarmsState> emit) async {
    emit(AlarmsContentState(alarms: await _repository.save(event.alarm)));
  }
}
