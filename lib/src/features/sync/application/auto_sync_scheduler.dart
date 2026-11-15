import 'dart:async';

/// Something that wants to hear "notes changed locally, sync soon".
abstract class NoteSyncTrigger {
  void schedule();
}

class NoOpNoteSyncTrigger implements NoteSyncTrigger {
  const NoOpNoteSyncTrigger();

  @override
  void schedule() {}
}

/// Debounces bursts of sync requests (e.g. several highlight taps) into a
/// single trigger call, so the radio wakes up once instead of per edit.
///
/// Deliberately has no periodic/polling mode: sync is purely event-driven
/// (note edits, app resume, network restored) to keep battery use low.
class AutoSyncScheduler implements NoteSyncTrigger {
  AutoSyncScheduler({
    required Future<void> Function() trigger,
    this.debounceDuration = const Duration(seconds: 5),
  }) : _trigger = trigger;

  final Future<void> Function() _trigger;
  final Duration debounceDuration;

  Timer? _debounceTimer;
  bool _isRunning = false;
  bool _rerunRequested = false;
  bool _disposed = false;

  @override
  void schedule() {
    if (_disposed) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, _flush);
  }

  Future<void> _flush() async {
    _debounceTimer = null;
    if (_isRunning) {
      // A request arrived mid-run: run once more afterwards instead of
      // silently dropping it.
      _rerunRequested = true;
      return;
    }
    _isRunning = true;
    try {
      do {
        _rerunRequested = false;
        await _trigger();
      } while (_rerunRequested && !_disposed);
    } finally {
      _isRunning = false;
    }
  }

  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
