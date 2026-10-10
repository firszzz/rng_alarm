import 'package:flutter_test/flutter_test.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';

void main() {
  group('$AlarmTime', () {
    const ring = AlarmTime(hour: 6, minute: 40);

    test('Schedules later today when that minute is still ahead', () {
      expect(ring.nextAfter(DateTime(2026, 10, 11, 6, 30)), DateTime(2026, 10, 11, 6, 40));
    });

    test('Schedules the next day when that minute is not still ahead', () {
      expect(ring.nextAfter(DateTime(2026, 10, 11, 6, 40)), DateTime(2026, 10, 12, 6, 40));
    });
  });
}
