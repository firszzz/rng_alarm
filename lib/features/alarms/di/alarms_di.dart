import 'package:injector/injector.dart';
import 'package:rng_alarm/features/alarms/presentation/editor/alarm_editor_bloc.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_bloc.dart';

/// Registrations of the alarm feature
abstract class AlarmsDI {
  /// Registers a new list bloc and a new editor bloc on each lookup
  static void init(Injector injector) {
    injector.registerDependency<AlarmsBloc>(AlarmsBloc.new);
    injector.registerDependency<AlarmEditorBloc>(() => AlarmEditorBloc());
  }
}
