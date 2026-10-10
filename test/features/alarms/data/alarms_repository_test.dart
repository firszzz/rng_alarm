import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rng_alarm/features/alarms/data/alarm_ring.dart';
import 'package:rng_alarm/features/alarms/data/alarms_repository.dart';
import 'package:rng_alarm/features/alarms/data/alarms_storage.dart';
import 'package:rng_alarm/features/alarms/data/dto/alarm_dto.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAlarmRing extends Mock implements AlarmRing {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$AlarmsRepository', () {
    const from = AlarmTime(hour: 6, minute: 40);
    const to = AlarmTime(hour: 7, minute: 0);
    final today = DateTime(2026, 10, 11, 6, 40);
    final alarm = Alarm(id: '1', from: from, to: to, name: 'Подъём', isEnabled: true, vibrates: true);

    late SharedPreferences preferences;
    late AlarmsStorage storage;
    late MockAlarmRing ring;
    late DateTime now;
    late int rolls;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      storage = AlarmsStorage(preferences);
      ring = MockAlarmRing();
      now = DateTime(2026, 10, 11, 6);
      rolls = 0;
      when(
        () => ring.schedule(
          id: any(named: 'id'),
          at: any(named: 'at'),
          name: any(named: 'name'),
          vibrates: any(named: 'vibrates'),
        ),
      ).thenAnswer((_) async {});
      when(() => ring.stop(any())).thenAnswer((_) async {});
      when(() => ring.isRinging(any())).thenAnswer((_) async => false);
    });

    AlarmsRepository repository() {
      return AlarmsRepository(
        storage: storage,
        ring: ring,
        now: () => now,
        pickIndex: (count) {
          final index = rolls == 0 ? 0 : count - 1;
          rolls += 1;
          return index;
        },
        createNativeId: () => 7,
      );
    }

    test('Saving an enabled alarm schedules one hidden minute inside the window', () async {
      final saved = await repository().save(alarm);

      expect(saved, [alarm]);
      verify(() => ring.schedule(id: 7, at: today, name: 'Подъём', vibrates: true)).called(1);
      expect(await storage.readRecords(), [
        AlarmDto(
          id: '1',
          nativeId: 7,
          fromHour: 6,
          fromMinute: 40,
          toHour: 7,
          toMinute: 0,
          name: 'Подъём',
          isEnabled: true,
          vibrates: true,
          ringHour: 6,
          ringMinute: 40,
          scheduledAt: today,
        ),
      ]);
    });

    test('Saving the same window again keeps the scheduled minute', () async {
      final alarms = repository();
      await alarms.save(alarm);

      await alarms.save(alarm.copyWith(name: 'Работа'));

      verify(() => ring.schedule(id: 7, at: today, name: 'Работа', vibrates: true)).called(1);
      verifyNever(
        () => ring.schedule(
          id: 7,
          at: DateTime(2026, 10, 11, 7),
          name: any(named: 'name'),
          vibrates: true,
        ),
      );
    });

    test('Changing the window schedules a new minute', () async {
      final alarms = repository();
      await alarms.save(alarm);

      await alarms.save(alarm.copyWith(to: const AlarmTime(hour: 7, minute: 10)));

      verify(() => ring.schedule(id: 7, at: DateTime(2026, 10, 11, 7, 10), name: 'Подъём', vibrates: true)).called(1);
    });

    test('Disabling an alarm cancels it and enabling it rolls again', () async {
      final alarms = repository();
      await alarms.save(alarm);

      final disabled = await alarms.save(alarm.copyWith(isEnabled: false));

      expect(disabled.single.isEnabled, isFalse);
      verify(() => ring.stop(7)).called(1);
      expect(await storage.readRecords(), [
        const AlarmDto(
          id: '1',
          nativeId: 7,
          fromHour: 6,
          fromMinute: 40,
          toHour: 7,
          toMinute: 0,
          name: 'Подъём',
          isEnabled: false,
          vibrates: true,
        ),
      ]);

      await alarms.save(alarm);

      verify(() => ring.schedule(id: 7, at: DateTime(2026, 10, 11, 7), name: 'Подъём', vibrates: true)).called(1);
    });

    test('Opening the list keeps a future minute', () async {
      final alarms = repository();
      await alarms.save(alarm);

      final loaded = await alarms.readAll();

      expect(loaded, [alarm]);
      verify(() => ring.schedule(id: 7, at: today, name: 'Подъём', vibrates: true)).called(2);
    });

    test('Opening the list after the ring rolls the next day', () async {
      final alarms = repository();
      await alarms.save(alarm);
      now = DateTime(2026, 10, 11, 8);

      await alarms.readAll();

      verify(() => ring.schedule(id: 7, at: DateTime(2026, 10, 12, 7), name: 'Подъём', vibrates: true)).called(1);
    });

    test('Opening the list while the alarm is ringing leaves that ring in place', () async {
      final alarms = repository();
      await alarms.save(alarm);
      now = DateTime(2026, 10, 11, 8);
      when(() => ring.isRinging(7)).thenAnswer((_) async => true);

      await alarms.readAll();

      verify(() => ring.schedule(id: 7, at: today, name: 'Подъём', vibrates: true)).called(1);
    });

    test('Deleting an alarm cancels its ring', () async {
      final alarms = repository();
      await alarms.save(alarm);

      final remaining = await alarms.delete(alarm.id);

      expect(remaining, isEmpty);
      verify(() => ring.stop(7)).called(1);
    });

    test('A finished ring is scheduled again for the next day', () async {
      final alarms = repository();
      await alarms.save(alarm);
      now = DateTime(2026, 10, 11, 6, 50);

      await alarms.scheduleNextDay(7);

      verify(() => ring.schedule(id: 7, at: DateTime(2026, 10, 12, 7), name: 'Подъём', vibrates: true)).called(1);
    });
  });
}
