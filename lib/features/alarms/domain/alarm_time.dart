import 'package:equatable/equatable.dart';

/// Clock time within a single day
class AlarmTime with Equatable {
  const AlarmTime({required this.hour, required this.minute});

  /// Hour from 0 through 23
  final int hour;

  /// Minute from 0 through 59
  final int minute;

  @override
  List<Object?> get props => [hour, minute];
}
