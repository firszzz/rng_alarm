import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_bloc.dart';

Alarm _alarm({String id = '1', bool isEnabled = true}) {
  return Alarm(id: id, time: const AlarmTime(hour: 7, minute: 30), name: 'Подъём', isEnabled: isEnabled, vibrates: true);
}

void main() {
  group('$AlarmsBloc', () {
    final alarm = _alarm();

    blocTest<AlarmsBloc, AlarmsState>(
      'Добавление кладёт будильник в конец списка',
      build: AlarmsBloc.new,
      act: (bloc) => bloc.add(AlarmsUpsertEvent(alarm)),
      expect: () => [
        AlarmsContentState(alarms: [alarm]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Повторное сохранение заменяет будильник с тем же id',
      build: AlarmsBloc.new,
      seed: () => AlarmsContentState(alarms: [alarm]),
      act: (bloc) => bloc.add(AlarmsUpsertEvent(alarm.copyWith(name: 'Работа'))),
      expect: () => [
        AlarmsContentState(alarms: [alarm.copyWith(name: 'Работа')]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Переключение меняет включённость будильника',
      build: AlarmsBloc.new,
      seed: () => AlarmsContentState(alarms: [alarm]),
      act: (bloc) => bloc.add(const AlarmsToggleEvent('1')),
      expect: () => [
        AlarmsContentState(alarms: [_alarm(isEnabled: false)]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Переключение неизвестного id не меняет список',
      build: AlarmsBloc.new,
      seed: () => AlarmsContentState(alarms: [alarm]),
      act: (bloc) => bloc.add(const AlarmsToggleEvent('missing')),
      expect: () => <AlarmsState>[],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Удаление убирает будильник из списка',
      build: AlarmsBloc.new,
      seed: () => AlarmsContentState(
        alarms: [
          alarm,
          _alarm(id: '2'),
        ],
      ),
      act: (bloc) => bloc.add(const AlarmsDeleteEvent('1')),
      expect: () => [
        AlarmsContentState(alarms: [_alarm(id: '2')]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Удаление неизвестного id не меняет список',
      build: AlarmsBloc.new,
      seed: () => AlarmsContentState(alarms: [alarm]),
      act: (bloc) => bloc.add(const AlarmsDeleteEvent('missing')),
      expect: () => <AlarmsState>[],
    );
  });
}
