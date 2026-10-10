import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/presentation/editor/alarm_editor_bloc.dart';

AlarmEditorBloc _bloc() => AlarmEditorBloc(createId: () => 'new-id');

void main() {
  group('$AlarmEditorBloc', () {
    final existing = Alarm(id: 'existing', time: const AlarmTime(hour: 8, minute: 15), name: 'Работа', isEnabled: false, vibrates: false);

    blocTest<AlarmEditorBloc, AlarmEditorState>(
      'Старт существующего будильника заполняет форму',
      build: _bloc,
      act: (bloc) => bloc.add(AlarmEditorStartedEvent(existing)),
      expect: () => [
        AlarmEditorEditingState(
          alarmId: existing.id,
          time: existing.time,
          name: existing.name,
          isEnabled: existing.isEnabled,
          vibrates: existing.vibrates,
        ),
      ],
    );

    blocTest<AlarmEditorBloc, AlarmEditorState>(
      'Смена времени, названия и вибрации обновляет форму',
      build: _bloc,
      act: (bloc) {
        bloc
          ..add(const AlarmEditorTimeChangedEvent(AlarmTime(hour: 6, minute: 40)))
          ..add(const AlarmEditorNameChangedEvent('Подъём'))
          ..add(const AlarmEditorVibrationChangedEvent(false));
      },
      expect: () => [
        AlarmEditorEditingState(alarmId: null, time: AlarmTime(hour: 6, minute: 40), name: '', isEnabled: true, vibrates: true),
        AlarmEditorEditingState(alarmId: null, time: AlarmTime(hour: 6, minute: 40), name: 'Подъём', isEnabled: true, vibrates: true),
        AlarmEditorEditingState(alarmId: null, time: AlarmTime(hour: 6, minute: 40), name: 'Подъём', isEnabled: true, vibrates: false),
      ],
    );

    test('Сохранение нового будильника отдаёт эффект с новым id', () async {
      final bloc = _bloc();
      final saved = expectLater(
        bloc.effects,
        emits(
          const AlarmEditorSavedEffect(
            Alarm(id: 'new-id', time: AlarmTime(hour: 6, minute: 40), name: 'Подъём', isEnabled: true, vibrates: false),
          ),
        ),
      );

      bloc
        ..add(const AlarmEditorTimeChangedEvent(AlarmTime(hour: 6, minute: 40)))
        ..add(const AlarmEditorNameChangedEvent('  Подъём  '))
        ..add(const AlarmEditorVibrationChangedEvent(false))
        ..add(const AlarmEditorSaveEvent());

      await saved;
      await bloc.close();
    });

    test('Сохранение существующего будильника сохраняет id и выключенное состояние', () async {
      final bloc = _bloc();
      final saved = expectLater(bloc.effects, emits(AlarmEditorSavedEffect(existing.copyWith(name: 'Смена'))));

      bloc
        ..add(AlarmEditorStartedEvent(existing))
        ..add(const AlarmEditorNameChangedEvent('Смена'))
        ..add(const AlarmEditorSaveEvent());

      await saved;
      await bloc.close();
    });
  });
}
