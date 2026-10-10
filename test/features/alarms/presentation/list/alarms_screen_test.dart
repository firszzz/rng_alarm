import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rng_alarm/app/ui_theme.dart';
import 'package:rng_alarm/di/injector.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_bloc.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_screen.dart';

class MockAlarmsBloc extends MockBloc<AlarmsEvent, AlarmsState> implements AlarmsBloc {}

Widget _themedList() {
  return MaterialApp(theme: UITheme.dark.toThemeData(), home: const AlarmsScreen());
}

void main() {
  group('$AlarmsScreen', () {
    late MockAlarmsBloc bloc;

    final alarm = Alarm(id: '1', time: const AlarmTime(hour: 7, minute: 30), name: 'Подъём', isEnabled: true, vibrates: true);

    setUpAll(() {
      registerFallbackValue(const AlarmsStartedEvent());
    });

    setUp(() {
      bloc = MockAlarmsBloc();
      when(() => bloc.add(any())).thenReturn(null);
      whenListen(bloc, const Stream<AlarmsState>.empty(), initialState: AlarmsContentState(alarms: [alarm]));
      injector.registerDependency<AlarmsBloc>(() => bloc);
    });

    tearDown(() {
      injector.removeByKey<AlarmsBloc>();
    });

    testWidgets('Карточка показывает время и название и шлёт переключение', (tester) async {
      await tester.pumpWidget(_themedList());

      expect(find.text('07:30'), findsOneWidget);
      expect(find.text('Подъём'), findsOneWidget);

      await tester.tap(find.byKey(const Key('testAlarmSwitch_1')));
      await tester.pump();

      verify(() => bloc.add(any(that: isA<AlarmsToggleEvent>().having((event) => event.id, 'id', '1')))).called(1);
    });

    testWidgets('Закрытие экрана закрывает блок', (tester) async {
      await tester.pumpWidget(_themedList());

      await tester.pumpWidget(const SizedBox.shrink());

      verify(() => bloc.close()).called(1);
    });
  });
}
