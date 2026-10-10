import 'dart:async';

import 'package:rng_alarm/features/alarms/data/alarm_ring.dart';
import 'package:rng_alarm/features/alarms/data/alarms_repository.dart';

/// Stops a ring after five minutes and arms the next day
///
/// The timer calls [AlarmRing.stop], which ends the native ringing service
class AlarmRingTimeout {
  AlarmRingTimeout({required AlarmRing ring, required AlarmsRepository repository, Duration limit = _defaultLimit})
    : _ring = ring,
      _repository = repository,
      _limit = limit;

  static const _defaultLimit = Duration(minutes: 5);

  final AlarmRing _ring;
  final AlarmsRepository _repository;
  final Duration _limit;
  final _timers = <int, Timer>{};
  StreamSubscription<Set<int>>? _subscription;
  var _ringing = <int>{};

  /// Listens for rings until [close]
  void start() {
    _subscription ??= _ring.ringingIds.listen(_onRinging);
  }

  /// Cancels the listener and any pending stop
  Future<void> close() async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onRinging(Set<int> ids) {
    final ended = _ringing.difference(ids);
    _ringing = ids;
    for (final id in ended) {
      _timers.remove(id)?.cancel();
      unawaited(_repository.scheduleNextDay(id));
    }

    for (final id in ids) {
      _timers.putIfAbsent(id, () => Timer(_limit, () => unawaited(_ring.stop(id))));
    }
  }
}
