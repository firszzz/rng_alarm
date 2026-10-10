import 'package:alarm/alarm.dart';
import 'package:rng_alarm/features/alarms/data/alarm_ring.dart';

/// [AlarmRing] backed by the `alarm` package
class AlarmPackageRing implements AlarmRing {
  @override
  Future<void> init() => Alarm.init();

  @override
  Future<void> schedule({required int id, required DateTime at, required String name, required bool vibrates}) {
    return Alarm.set(
      alarmSettings: alarmRingSettings(id: id, at: at, name: name, vibrates: vibrates),
    );
  }

  @override
  Future<void> stop(int id) async {
    await Alarm.stop(id);
  }

  @override
  Future<bool> isRinging(int id) => Alarm.isRinging(id);

  @override
  Stream<Set<int>> get ringingIds {
    return Alarm.ringing.map((alarms) => alarms.alarms.map((alarm) => alarm.id).toSet());
  }
}

/// Native settings for one ring
///
/// The notification title is the alarm name, never the clock time. Killing the
/// app does not raise a "reopen me" warning. iOS keeps no silent player: that
/// platform is out of scope. Swiping the app away does not cut a ring short of
/// the stop timer
AlarmSettings alarmRingSettings({required int id, required DateTime at, required String name, required bool vibrates}) {
  final title = name.trim().isEmpty ? 'Alarm' : name.trim();
  return AlarmSettings(
    id: id,
    dateTime: at,
    loopAudio: true,
    vibrate: vibrates,
    warningNotificationOnKill: false,
    androidFullScreenIntent: true,
    allowAlarmOverlap: true,
    allowSameSecondScheduling: true,
    iOSBackgroundAudio: false,
    androidStopAlarmOnTermination: false,
    androidAlarmClock: true,
    volumeSettings: const VolumeSettings.fixed(volumeEnforced: true),
    notificationSettings: NotificationSettings(title: title, body: title, stopButton: 'Stop'),
  );
}
