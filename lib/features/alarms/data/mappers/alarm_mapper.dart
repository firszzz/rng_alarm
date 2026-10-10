import 'package:rng_alarm/features/alarms/data/dto/alarm_dto.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';

abstract class AlarmMapper {
  static Alarm toAlarm(AlarmDto dto) {
    return Alarm(
      id: dto.id,
      from: AlarmTime(hour: dto.fromHour, minute: dto.fromMinute),
      to: AlarmTime(hour: dto.toHour, minute: dto.toMinute),
      name: dto.name,
      isEnabled: dto.isEnabled,
      vibrates: dto.vibrates,
    );
  }

  static AlarmDto toDto({required Alarm alarm, required int nativeId, AlarmTime? ringTime, DateTime? scheduledAt}) {
    return AlarmDto(
      id: alarm.id,
      nativeId: nativeId,
      fromHour: alarm.from.hour,
      fromMinute: alarm.from.minute,
      toHour: alarm.to.hour,
      toMinute: alarm.to.minute,
      name: alarm.name,
      isEnabled: alarm.isEnabled,
      vibrates: alarm.vibrates,
      ringHour: ringTime?.hour,
      ringMinute: ringTime?.minute,
      scheduledAt: scheduledAt,
    );
  }
}
