// Issues #52 / #91: the repository's hand-rolled in-flight dedup returned the
// stored future from its own whenComplete callback, so first-run Bible loads
// and downloads never completed.

import 'dart:async';

import 'package:basic_bible/src/features/library/data/in_flight_requests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the returned future completes (the old pattern never did)', () async {
    final requests = InFlightRequests<String, int>();
    final result = await requests
        .run('kjv', () => Future.delayed(Duration.zero, () => 42))
        .timeout(const Duration(seconds: 2));
    expect(result, 42);
    expect(requests.isRunning('kjv'), isFalse);
  });

  test('concurrent callers share one run', () async {
    final requests = InFlightRequests<String, int>();
    final gate = Completer<int>();
    var starts = 0;
    Future<int> start() {
      starts++;
      return gate.future;
    }

    final a = requests.run('kjv', start);
    final b = requests.run('kjv', start);
    expect(identical(a, b), isTrue);
    expect(requests.isRunning('kjv'), isTrue);

    gate.complete(7);
    expect(await Future.wait([a, b]), [7, 7]);
    expect(starts, 1);
  });

  test('errors reach the caller and a retry starts a fresh run', () async {
    final requests = InFlightRequests<String, int>();
    await expectLater(
      requests.run('web', () => Future.error(StateError('offline'))),
      throwsStateError,
    );
    expect(requests.isRunning('web'), isFalse);
    expect(await requests.run('web', () async => 1), 1);
  });

  test('different keys run independently', () async {
    final requests = InFlightRequests<String, String>();
    final results = await Future.wait([
      requests.run('a', () async => 'A'),
      requests.run('b', () async => 'B'),
    ]);
    expect(results, ['A', 'B']);
  });
}
