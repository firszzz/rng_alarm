import 'dart:math';

import 'package:rng_alarm/features/alarms/data/alarm_ring.dart';
import 'package:rng_alarm/features/alarms/data/alarms_storage.dart';
import 'package:rng_alarm/features/alarms/data/dto/alarm_dto.dart';
import 'package:rng_alarm/features/alarms/data/mappers/alarm_mapper.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_window.dart';

/// Alarm list stored locally and armed on the native clock
///
/// The ring minute stays in storage. [readAll] and [save] return alarms without it
class AlarmsRepository {
  AlarmsRepository({
    required AlarmsStorage storage,
    required AlarmRing ring,
    DateTime Function()? now,
    int Function(int count)? pickIndex,
    int Function()? createNativeId,
  }) : _storage = storage,
       _ring = ring,
       _now = now ?? DateTime.now,
       _pickIndex = pickIndex ?? Random().nextInt,
       _createNativeId = createNativeId ?? _randomNativeId;

  final AlarmsStorage _storage;
  final AlarmRing _ring;
  final DateTime Function() _now;
  final int Function(int count) _pickIndex;
  final int Function() _createNativeId;
  Future<void> _tail = Future<void>.value();

  /// Stored alarms in list order, with due rings restored or rolled forward
  Future<List<Alarm>> readAll() => _serialized(_readAll);

  /// Inserts or replaces [alarm] and arms or cancels its native ring
  Future<List<Alarm>> save(Alarm alarm) => _serialized(() => _save(alarm));

  /// Removes the alarm with [id] and cancels its native ring
  Future<List<Alarm>> delete(String id) => _serialized(() => _delete(id));

  /// Rolls a new minute for the next day after [nativeId] has finished ringing
  ///
  /// Does nothing when that alarm is missing or switched off
  Future<void> scheduleNextDay(int nativeId) => _serialized(() => _scheduleNextDay(nativeId));

  Future<List<Alarm>> _readAll() async {
    final records = await _storage.readRecords();
    final now = _now();
    final next = <AlarmDto>[];
    var changed = false;

    for (final record in records) {
      if (!record.isEnabled) {
        await _ring.stop(record.nativeId);
        next.add(record);
        continue;
      }

      if (await _ring.isRinging(record.nativeId)) {
        next.add(record);
        continue;
      }

      final ringTime = _ringTime(record);
      final scheduledAt = record.scheduledAt;
      if (ringTime != null && scheduledAt != null && scheduledAt.isAfter(now)) {
        await _schedule(record, scheduledAt);
        next.add(record);
        continue;
      }

      final earliest = scheduledAt == null ? now : _startOfNextDay(now);
      final rolled = _roll(record, earliest: earliest);
      await _scheduleRecord(rolled);
      next.add(rolled);
      changed = true;
    }

    if (changed) {
      await _storage.writeRecords(next);
    }
    return next.map(AlarmMapper.toAlarm).toList();
  }

  Future<List<Alarm>> _save(Alarm alarm) async {
    if (alarm.isEnabled && AlarmWindow(from: alarm.from, to: alarm.to).issue != null) {
      throw ArgumentError('Alarm window is invalid');
    }

    final records = await _storage.readRecords();
    final index = records.indexWhere((record) => record.id == alarm.id);
    final previous = index < 0 ? null : records[index];
    final nativeId = previous?.nativeId ?? _nativeId(records);
    final record = _recordForSave(alarm, previous, nativeId);
    final updated = [...records];
    if (index < 0) {
      updated.add(record);
    } else {
      updated[index] = record;
    }

    await _apply(previous, record);
    await _storage.writeRecords(updated);
    return updated.map(AlarmMapper.toAlarm).toList();
  }

  Future<List<Alarm>> _delete(String id) async {
    final records = await _storage.readRecords();
    final existing = records.where((record) => record.id == id).toList();
    if (existing.isEmpty) {
      return records.map(AlarmMapper.toAlarm).toList();
    }

    await _ring.stop(existing.first.nativeId);
    final updated = records.where((record) => record.id != id).toList();
    await _storage.writeRecords(updated);
    return updated.map(AlarmMapper.toAlarm).toList();
  }

  Future<void> _scheduleNextDay(int nativeId) async {
    final records = await _storage.readRecords();
    final index = records.indexWhere((record) => record.nativeId == nativeId);
    if (index < 0) {
      return;
    }

    final record = records[index];
    if (!record.isEnabled) {
      return;
    }

    final rolled = _roll(record, earliest: _startOfNextDay(_now()));
    final updated = [...records];
    updated[index] = rolled;
    await _scheduleRecord(rolled);
    await _storage.writeRecords(updated);
  }

  AlarmDto _recordForSave(Alarm alarm, AlarmDto? previous, int nativeId) {
    if (!alarm.isEnabled) {
      return AlarmMapper.toDto(alarm: alarm, nativeId: nativeId);
    }

    final now = _now();
    final previousRing = previous == null ? null : _ringTime(previous);
    final sameWindow =
        previous != null &&
        previous.fromHour == alarm.from.hour &&
        previous.fromMinute == alarm.from.minute &&
        previous.toHour == alarm.to.hour &&
        previous.toMinute == alarm.to.minute;
    final scheduledAt = previous?.scheduledAt;
    if (previousRing != null && sameWindow && previous.isEnabled && scheduledAt != null && scheduledAt.isAfter(now)) {
      return AlarmMapper.toDto(alarm: alarm, nativeId: nativeId, ringTime: previousRing, scheduledAt: scheduledAt);
    }

    return _roll(
      AlarmMapper.toDto(alarm: alarm, nativeId: nativeId),
      earliest: now,
    );
  }

  AlarmDto _roll(AlarmDto record, {required DateTime earliest}) {
    final from = AlarmTime(hour: record.fromHour, minute: record.fromMinute);
    final to = AlarmTime(hour: record.toHour, minute: record.toMinute);
    final window = AlarmWindow(from: from, to: to);
    final ring = window.ringTime(_pickIndex);
    return AlarmMapper.toDto(
      alarm: AlarmMapper.toAlarm(record),
      nativeId: record.nativeId,
      ringTime: ring,
      scheduledAt: ring.nextAfter(earliest),
    );
  }

  DateTime _startOfNextDay(DateTime instant) {
    final today = DateTime(instant.year, instant.month, instant.day);
    return today.add(const Duration(days: 1));
  }

  Future<void> _apply(AlarmDto? previous, AlarmDto record) async {
    if (!record.isEnabled) {
      if (previous != null) {
        await _ring.stop(previous.nativeId);
      }
      return;
    }

    final ringTime = _ringTime(record);
    final scheduledAt = record.scheduledAt;
    if (ringTime == null || scheduledAt == null) {
      return;
    }
    await _schedule(record, scheduledAt);
  }

  Future<void> _scheduleRecord(AlarmDto record) async {
    final scheduledAt = record.scheduledAt;
    if (_ringTime(record) == null || scheduledAt == null) {
      return;
    }
    await _schedule(record, scheduledAt);
  }

  Future<void> _schedule(AlarmDto record, DateTime at) {
    return _ring.schedule(id: record.nativeId, at: at, name: record.name, vibrates: record.vibrates);
  }

  AlarmTime? _ringTime(AlarmDto record) {
    final hour = record.ringHour;
    final minute = record.ringMinute;
    if (hour == null || minute == null) {
      return null;
    }
    return AlarmTime(hour: hour, minute: minute);
  }

  int _nativeId(List<AlarmDto> records) {
    final used = records.map((record) => record.nativeId).toSet();
    for (var attempt = 0; attempt < 8; attempt++) {
      final id = _createNativeId();
      if (id > 0 && id <= 2147483647 && !used.contains(id)) {
        return id;
      }
    }
    throw StateError('Could not allocate a native alarm id');
  }

  Future<T> _serialized<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}

final _nativeRandom = Random();

int _randomNativeId() => _nativeRandom.nextInt(1 << 30) + 1;
