import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rng_alarm/features/alarms/data/alarm_ring.dart';
import 'package:rng_alarm/features/alarms/data/alarm_ring_timeout.dart';
import 'package:rng_alarm/features/alarms/data/alarms_repository.dart';

class _MockAlarmRing extends Mock implements AlarmRing {}

class _MockAlarmsRepository extends Mock implements AlarmsRepository {}

void main() {
  group('$AlarmRingTimeout', () {
    late _MockAlarmRing ring;
    late _MockAlarmsRepository repository;
    late StreamController<Set<int>> ringing;

    setUp(() {
      ring = _MockAlarmRing();
      repository = _MockAlarmsRepository();
      ringing = StreamController<Set<int>>.broadcast();
      when(() => ring.ringingIds).thenAnswer((_) => ringing.stream);
      when(() => ring.stop(any())).thenAnswer((_) async {});
      when(() => repository.scheduleNextDay(any())).thenAnswer((_) async {});
    });

    tearDown(() async {
      await ringing.close();
    });

    test('Stops the native alarm five minutes after it starts ringing', () {
      fakeAsync((async) {
        final timeout = AlarmRingTimeout(ring: ring, repository: repository);
        timeout.start();
        ringing.add({7});

        async.elapse(const Duration(minutes: 4));
        verifyNever(() => ring.stop(any()));

        async.elapse(const Duration(minutes: 1));
        verify(() => ring.stop(7)).called(1);

        timeout.close();
        async.flushMicrotasks();
      });
    });

    test('Schedules the next day when the ring ends before the limit', () {
      fakeAsync((async) {
        final timeout = AlarmRingTimeout(ring: ring, repository: repository);
        timeout.start();
        ringing.add({7});
        async.elapse(const Duration(minutes: 1));

        ringing.add(<int>{});
        async.flushMicrotasks();

        verify(() => repository.scheduleNextDay(7)).called(1);
        async.elapse(const Duration(minutes: 5));
        verifyNever(() => ring.stop(any()));

        timeout.close();
        async.flushMicrotasks();
      });
    });
  });
}
