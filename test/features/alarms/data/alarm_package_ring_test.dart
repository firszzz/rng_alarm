import 'package:alarm/alarm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rng_alarm/features/alarms/data/alarm_package_ring.dart';

void main() {
  group('Alarm ring settings', () {
    final at = DateTime(2026, 10, 11, 6, 45);

    test('Arms an alarm clock without revealing the minute or keeping the app warm', () {
      expect(
        alarmRingSettings(id: 7, at: at, name: '  Подъём  ', vibrates: false),
        AlarmSettings(
          id: 7,
          dateTime: at,
          loopAudio: true,
          vibrate: false,
          warningNotificationOnKill: false,
          androidFullScreenIntent: true,
          allowAlarmOverlap: true,
          allowSameSecondScheduling: true,
          iOSBackgroundAudio: false,
          androidStopAlarmOnTermination: false,
          androidAlarmClock: true,
          volumeSettings: const VolumeSettings.fixed(volumeEnforced: true),
          notificationSettings: const NotificationSettings(title: 'Подъём', body: 'Подъём', stopButton: 'Stop'),
        ),
      );
    });

    test('Uses Alarm as the notification title when the name is blank', () {
      expect(alarmRingSettings(id: 7, at: at, name: '   ', vibrates: true).notificationSettings.title, 'Alarm');
    });
  });
}
