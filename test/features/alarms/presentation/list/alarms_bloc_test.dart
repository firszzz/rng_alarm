import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rng_alarm/features/alarms/data/alarms_repository.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_bloc.dart';

class MockAlarmsRepository extends Mock implements AlarmsRepository {}

Alarm _alarm({String id = '1', bool isEnabled = true}) {
  return Alarm(
    id: id,
    from: const AlarmTime(hour: 6, minute: 40),
    to: const AlarmTime(hour: 7, minute: 0),
    name: 'Подъём',
    isEnabled: isEnabled,
    vibrates: true,
  );
}

Matcher _content(List<Alarm> alarms) {
  return isA<AlarmsContentState>().having((state) => state.alarms, 'alarms', alarms);
}

void main() {
  group('$AlarmsBloc', () {
    late MockAlarmsRepository repository;
    final alarm = _alarm();

    setUpAll(() {
      registerFallbackValue(alarm);
    });

    setUp(() {
      repository = MockAlarmsRepository();
    });

    blocTest<AlarmsBloc, AlarmsState>(
      'Opening the list shows the stored alarms',
      build: () => AlarmsBloc(repository),
      setUp: () {
        when(() => repository.readAll()).thenAnswer((_) async => [alarm]);
      },
      act: (bloc) => bloc.add(const AlarmsStartedEvent()),
      expect: () => [
        _content([alarm]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Adding an alarm appends it to the list',
      build: () => AlarmsBloc(repository),
      setUp: () {
        when(() => repository.save(alarm)).thenAnswer((_) async => [alarm]);
      },
      act: (bloc) => bloc.add(AlarmsUpsertEvent(alarm)),
      expect: () => [
        _content([alarm]),
      ],
      verify: (_) {
        verify(() => repository.save(alarm)).called(1);
      },
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Saving the same id replaces the alarm',
      build: () => AlarmsBloc(repository),
      setUp: () {
        final replacement = alarm.copyWith(name: 'Работа');
        when(() => repository.save(replacement)).thenAnswer((_) async => [replacement]);
      },
      act: (bloc) => bloc.add(AlarmsUpsertEvent(alarm.copyWith(name: 'Работа'))),
      expect: () => [
        _content([alarm.copyWith(name: 'Работа')]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Toggling flips whether the alarm is enabled',
      build: () => AlarmsBloc(repository),
      seed: () => AlarmsContentState(alarms: [alarm]),
      setUp: () {
        when(() => repository.save(_alarm(isEnabled: false))).thenAnswer((_) async => [_alarm(isEnabled: false)]);
      },
      act: (bloc) => bloc.add(const AlarmsToggleEvent('1')),
      expect: () => [
        _content([_alarm(isEnabled: false)]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Toggling an unknown id leaves the list unchanged',
      build: () => AlarmsBloc(repository),
      seed: () => AlarmsContentState(alarms: [alarm]),
      act: (bloc) => bloc.add(const AlarmsToggleEvent('missing')),
      expect: () => <AlarmsState>[],
      verify: (_) {
        verifyNever(() => repository.save(any()));
      },
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Deleting removes the alarm from the list',
      build: () => AlarmsBloc(repository),
      seed: () => AlarmsContentState(
        alarms: [
          alarm,
          _alarm(id: '2'),
        ],
      ),
      setUp: () {
        when(() => repository.delete('1')).thenAnswer((_) async => [_alarm(id: '2')]);
      },
      act: (bloc) => bloc.add(const AlarmsDeleteEvent('1')),
      expect: () => [
        _content([_alarm(id: '2')]),
      ],
    );

    blocTest<AlarmsBloc, AlarmsState>(
      'Deleting an unknown id leaves the list unchanged',
      build: () => AlarmsBloc(repository),
      seed: () => AlarmsContentState(alarms: [alarm]),
      act: (bloc) => bloc.add(const AlarmsDeleteEvent('missing')),
      expect: () => <AlarmsState>[],
      verify: (_) {
        verifyNever(() => repository.delete(any()));
      },
    );
  });
}
