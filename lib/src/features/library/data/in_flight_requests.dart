/// Shares one in-progress [Future] per key so concurrent callers of the same
/// expensive operation (parse, download, session read) await a single run.
///
/// This replaces a hand-rolled pattern that deadlocked:
///
/// ```dart
/// map.putIfAbsent(id, () => work().whenComplete(() => map.remove(id)));
/// ```
///
/// The arrow callback *returns* `map.remove(id)` — the very future
/// `whenComplete` produced and stored — and `whenComplete` waits for any
/// future its callback returns, so that future waited on itself and never
/// completed. A first-run Bible load (web: #52) or a download (#91) then spun
/// forever even though the work had finished and been cached; only a restart,
/// which takes a different cached path, appeared to "fix" it.
class InFlightRequests<K, V> {
  final Map<K, Future<V>> _pending = {};

  /// Whether a request for [key] is currently running.
  bool isRunning(K key) => _pending.containsKey(key);

  /// Returns the running future for [key], or starts one with [start].
  ///
  /// The entry is cleared once the future settles (success or error) so the
  /// next call starts fresh — e.g. a retry after a failed download.
  Future<V> run(K key, Future<V> Function() start) {
    final existing = _pending[key];
    if (existing != null) return existing;

    final future = start();
    _pending[key] = future;
    // Block body on purpose: nothing may be returned from this callback
    // (see the class doc). `ignore` keeps this bookkeeping branch from
    // reporting the error a second time; callers still receive it.
    future.whenComplete(() {
      if (identical(_pending[key], future)) _pending.remove(key);
    }).ignore();
    return future;
  }
}
