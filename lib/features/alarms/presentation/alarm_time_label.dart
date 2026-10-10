import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';

/// 24-hour label of [time] with hours and minutes padded to two digits
String alarmTimeLabel(AlarmTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}
