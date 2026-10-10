import 'package:equatable/equatable.dart';

/// Clock time within a single day
class AlarmTime with Equatable {
  const AlarmTime({required this.hour, required this.minute});

  /// Hour from 0 through 23
  final int hour;

  /// Minute from 0 through 59
  final int minute;

  /// First instant of this time that is strictly after [earliest]
  DateTime nextAfter(DateTime earliest) {
    final sameDay = DateTime(earliest.year, earliest.month, earliest.day, hour, minute);
    if (sameDay.isAfter(earliest)) {
      return sameDay;
    }

    final nextDay = sameDay.add(const Duration(days: 1));
    return DateTime(nextDay.year, nextDay.month, nextDay.day, hour, minute);
  }

  @override
  List<Object?> get props => [hour, minute];
}
