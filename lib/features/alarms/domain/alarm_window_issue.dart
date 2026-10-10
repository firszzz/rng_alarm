/// Reason why a window cannot be scheduled
enum AlarmWindowIssue {
  /// End is not later than the start on the same day
  endsTooEarly,

  /// End is less than 10 minutes after the start
  shorterThanMinimum,
}
