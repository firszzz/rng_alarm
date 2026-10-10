import 'package:injector/injector.dart';
import 'package:rng_alarm/features/alarms/presentation/editor/alarm_editor_bloc.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_bloc.dart';

abstract class AlarmsDI {
  static void init(Injector injector) {
    injector.registerDependency<AlarmsBloc>(AlarmsBloc.new);
    injector.registerDependency<AlarmEditorBloc>(() => AlarmEditorBloc());
  }
}
