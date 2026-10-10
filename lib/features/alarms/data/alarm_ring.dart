/// Native alarm clock used to ring at one hidden minute
abstract interface class AlarmRing {
  /// Prepares the native scheduler
  Future<void> init();

  /// Arms [id] to ring at [at]
  ///
  /// Replaces a previous arming of the same [id]. [name] is shown on the
  /// ringing notification and does not include the ring minute
  Future<void> schedule({required int id, required DateTime at, required String name, required bool vibrates});

  /// Silences [id] when it is ringing and cancels it when it is only armed
  Future<void> stop(int id);

  /// Whether [id] is audible now
  Future<bool> isRinging(int id);

  /// Ids that are audible now
  ///
  /// Emits the current set on listen, then a new set whenever it changes
  Stream<Set<int>> get ringingIds;
}
