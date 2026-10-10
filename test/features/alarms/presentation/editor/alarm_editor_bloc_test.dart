import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_window_issue.dart';
import 'package:rng_alarm/features/alarms/presentation/editor/alarm_editor_bloc.dart';

AlarmEditorBloc _bloc() => AlarmEditorBloc(createId: () => 'new-id');

Matcher _form({
  required String? alarmId,
  required AlarmTime from,
  required AlarmTime to,
  required String name,
  required bool isEnabled,
  required bool vibrates,
}) {
  return isA<AlarmEditorEditingState>()
      .having((state) => state.alarmId, 'alarmId', alarmId)
      .having((state) => state.from, 'from', from)
      .having((state) => state.to, 'to', to)
      .having((state) => state.name, 'name', name)
      .having((state) => state.isEnabled, 'isEnabled', isEnabled)
      .having((state) => state.vibrates, 'vibrates', vibrates);
}

void main() {
  group('$AlarmEditorBloc', () {
    const from = AlarmTime(hour: 6, minute: 40);
    const to = AlarmTime(hour: 7, minute: 0);
    final existing = Alarm(
      id: 'existing',
      from: const AlarmTime(hour: 8, minute: 0),
      to: const AlarmTime(hour: 8, minute: 20),
      name: 'Работа',
      isEnabled: false,
      vibrates: false,
    );

    blocTest<AlarmEditorBloc, AlarmEditorState>(
      'Starting with an existing alarm fills the form',
      build: _bloc,
      act: (bloc) => bloc.add(AlarmEditorStartedEvent(existing)),
      expect: () => [
        _form(
          alarmId: existing.id,
          from: existing.from,
          to: existing.to,
          name: existing.name,
          isEnabled: existing.isEnabled,
          vibrates: existing.vibrates,
        ),
      ],
    );

    blocTest<AlarmEditorBloc, AlarmEditorState>(
      'Changing the window, name and vibration updates the form',
      build: _bloc,
      act: (bloc) {
        bloc
          ..add(const AlarmEditorFromChangedEvent(AlarmTime(hour: 6, minute: 30)))
          ..add(const AlarmEditorToChangedEvent(AlarmTime(hour: 6, minute: 50)))
          ..add(const AlarmEditorNameChangedEvent('Подъём'))
          ..add(const AlarmEditorVibrationChangedEvent(false));
      },
      expect: () => [
        _form(alarmId: null, from: const AlarmTime(hour: 6, minute: 30), to: to, name: '', isEnabled: true, vibrates: true),
        _form(
          alarmId: null,
          from: const AlarmTime(hour: 6, minute: 30),
          to: const AlarmTime(hour: 6, minute: 50),
          name: '',
          isEnabled: true,
          vibrates: true,
        ),
        _form(
          alarmId: null,
          from: const AlarmTime(hour: 6, minute: 30),
          to: const AlarmTime(hour: 6, minute: 50),
          name: 'Подъём',
          isEnabled: true,
          vibrates: true,
        ),
        _form(
          alarmId: null,
          from: const AlarmTime(hour: 6, minute: 30),
          to: const AlarmTime(hour: 6, minute: 50),
          name: 'Подъём',
          isEnabled: true,
          vibrates: false,
        ),
      ],
    );

    test('Saving a new alarm emits an effect with a new id', () async {
      final bloc = _bloc();
      final saved = expectLater(
        bloc.effects,
        emits(const AlarmEditorSavedEffect(Alarm(id: 'new-id', from: from, to: to, name: 'Подъём', isEnabled: true, vibrates: false))),
      );

      bloc
        ..add(const AlarmEditorNameChangedEvent('  Подъём  '))
        ..add(const AlarmEditorVibrationChangedEvent(false))
        ..add(const AlarmEditorSaveEvent());

      await saved;
      await bloc.close();
    });

    test('Saving an existing alarm keeps its id and disabled state', () async {
      final bloc = _bloc();
      final saved = expectLater(bloc.effects, emits(AlarmEditorSavedEffect(existing.copyWith(name: 'Смена'))));

      bloc
        ..add(AlarmEditorStartedEvent(existing))
        ..add(const AlarmEditorNameChangedEvent('Смена'))
        ..add(const AlarmEditorSaveEvent());

      await saved;
      await bloc.close();
    });

    test('Saving a window that ends too early rejects the form', () async {
      final bloc = _bloc();
      final rejected = expectLater(bloc.effects, emits(const AlarmEditorInvalidEffect(AlarmWindowIssue.endsTooEarly)));

      bloc
        ..add(const AlarmEditorToChangedEvent(from))
        ..add(const AlarmEditorSaveEvent());

      await rejected;
      await bloc.close();
    });

    test('Saving a window shorter than 10 minutes rejects the form', () async {
      final bloc = _bloc();
      final rejected = expectLater(bloc.effects, emits(const AlarmEditorInvalidEffect(AlarmWindowIssue.shorterThanMinimum)));

      bloc
        ..add(const AlarmEditorToChangedEvent(AlarmTime(hour: 6, minute: 49)))
        ..add(const AlarmEditorSaveEvent());

      await rejected;
      await bloc.close();
    });
  });
}
