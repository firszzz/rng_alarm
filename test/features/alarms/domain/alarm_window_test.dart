import 'package:flutter_test/flutter_test.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_window.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_window_issue.dart';

void main() {
  group('$AlarmWindow', () {
    const from = AlarmTime(hour: 6, minute: 40);
    const tenMinutesLater = AlarmTime(hour: 6, minute: 50);
    const twentyMinutesLater = AlarmTime(hour: 7, minute: 0);

    test('Accepts a window of 10 minutes', () {
      expect(const AlarmWindow(from: from, to: tenMinutesLater).issue, isNull);
    });

    test('Rejects a window shorter than 10 minutes', () {
      expect(const AlarmWindow(from: from, to: AlarmTime(hour: 6, minute: 49)).issue, AlarmWindowIssue.shorterThanMinimum);
    });

    test('Rejects a window that does not end later the same day', () {
      expect(const AlarmWindow(from: from, to: from).issue, AlarmWindowIssue.endsTooEarly);
      expect(const AlarmWindow(from: twentyMinutesLater, to: from).issue, AlarmWindowIssue.endsTooEarly);
    });

    test('Chooses an inclusive minute inside the window', () {
      const window = AlarmWindow(from: from, to: twentyMinutesLater);

      expect(window.ringTime((_) => 0), from);
      expect(window.ringTime((count) => count - 1), twentyMinutesLater);
    });
  });
}
