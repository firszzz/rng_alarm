import 'package:injector/injector.dart';
import 'package:rng_alarm/features/alarms/data/alarm_package_ring.dart';
import 'package:rng_alarm/features/alarms/data/alarm_permissions.dart';
import 'package:rng_alarm/features/alarms/data/alarm_ring.dart';
import 'package:rng_alarm/features/alarms/data/alarm_ring_timeout.dart';
import 'package:rng_alarm/features/alarms/data/alarms_repository.dart';
import 'package:rng_alarm/features/alarms/data/alarms_storage.dart';
import 'package:rng_alarm/features/alarms/presentation/editor/alarm_editor_bloc.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_bloc.dart';
import 'package:rng_alarm/storage/preference_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AlarmsDI {
  static Future<void> init(Injector injector) async {
    final preferences = await SharedPreferences.getInstance();
    final ring = AlarmPackageRing();
    await ring.init();
    await AlarmPermissions.request();

    final storage = AlarmsStorage(preferences);
    final repository = AlarmsRepository(storage: storage, ring: ring);
    final timeout = AlarmRingTimeout(ring: ring, repository: repository);
    timeout.start();

    injector.registerSingleton<AlarmsStorage>(() => storage);
    injector.registerSingleton<PreferenceStorage>(() => storage);
    injector.registerSingleton<AlarmRing>(() => ring);
    injector.registerSingleton<AlarmsRepository>(() => repository);
    injector.registerSingleton<AlarmRingTimeout>(() => timeout);
    injector.registerDependency<AlarmsBloc>(() => AlarmsBloc(injector.get<AlarmsRepository>()));
    injector.registerDependency<AlarmEditorBloc>(() => AlarmEditorBloc());
  }
}
