import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';

/// Alarm labels for specific cases
abstract class AlarmLabels {
  /// 24-hour label of [time] with hours and minutes padded to two digits
  static String alarmTimeLabel(AlarmTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  /// 24-hour label of a window, from [from] through [to]
  static String alarmWindowLabel(AlarmTime from, AlarmTime to) {
    return '${alarmTimeLabel(from)} – ${alarmTimeLabel(to)}';
  }
}
