import 'package:basic_bible/src/features/sync/application/auto_sync_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debounces multiple rapid sync requests into one trigger', () async {
    var triggerCount = 0;

    final scheduler = AutoSyncScheduler(
      trigger: () async {
        triggerCount++;
      },
      debounceDuration: const Duration(milliseconds: 50),
    );

    scheduler.schedule();
    scheduler.schedule();
    scheduler.schedule();

    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(triggerCount, 1);
  });

  test('runs the trigger again after the debounce window resets', () async {
    var triggerCount = 0;

    final scheduler = AutoSyncScheduler(
      trigger: () async {
        triggerCount++;
      },
      debounceDuration: const Duration(milliseconds: 30),
    );

    scheduler.schedule();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    scheduler.schedule();
    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(triggerCount, 2);
  });

  test('a request arriving mid-run triggers exactly one more run', () async {
    var triggerCount = 0;
    late AutoSyncScheduler scheduler;
    scheduler = AutoSyncScheduler(
      trigger: () async {
        triggerCount++;
        if (triggerCount == 1) {
          // Simulate edits saved while the first sync is still running.
          scheduler.schedule();
          scheduler.schedule();
          await Future<void>.delayed(const Duration(milliseconds: 60));
        }
      },
      debounceDuration: const Duration(milliseconds: 10),
    );
    addTearDown(scheduler.dispose);

    scheduler.schedule();
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(triggerCount, 2);
  });

  test('dispose cancels a pending trigger', () async {
    var triggerCount = 0;
    final scheduler = AutoSyncScheduler(
      trigger: () async => triggerCount++,
      debounceDuration: const Duration(milliseconds: 20),
    );

    scheduler.schedule();
    scheduler.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(triggerCount, 0);
  });
}
