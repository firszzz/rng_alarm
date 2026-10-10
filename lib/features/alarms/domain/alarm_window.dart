import 'package:equatable/equatable.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_window_issue.dart';

/// Inclusive range of minutes in which an alarm may ring
class AlarmWindow with Equatable {
  const AlarmWindow({required this.from, required this.to});

  static const _minimumMinutes = 10;

  /// First minute of the window, inclusive
  final AlarmTime from;

  /// Last minute of the window, inclusive
  final AlarmTime to;

  /// Why this window cannot ring
  ///
  /// Null when the window is valid
  AlarmWindowIssue? get issue {
    final length = _minuteOfDay(to) - _minuteOfDay(from);
    if (length <= 0) {
      return AlarmWindowIssue.endsTooEarly;
    }
    if (length < _minimumMinutes) {
      return AlarmWindowIssue.shorterThanMinimum;
    }
    return null;
  }

  /// Inclusive ring minute inside this window
  ///
  /// [pickIndex] receives how many minutes can ring and returns an index from 0
  /// through that count minus one. Callers keep the result out of screen state
  AlarmTime ringTime(int Function(int count) pickIndex) {
    final problem = issue;
    if (problem != null) {
      throw ArgumentError(problem);
    }

    final count = _minuteOfDay(to) - _minuteOfDay(from) + 1;
    final index = pickIndex(count);
    if (index < 0 || index >= count) {
      throw RangeError.range(index, 0, count - 1, 'pickIndex');
    }

    final minuteOfDay = _minuteOfDay(from) + index;
    return AlarmTime(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
  }

  static int _minuteOfDay(AlarmTime time) => time.hour * 60 + time.minute;

  @override
  List<Object?> get props => [from, to];
}
