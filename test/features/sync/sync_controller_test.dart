import 'package:basic_bible/src/features/sync/application/view_models/sync_view_models.dart';
import 'package:basic_bible/src/features/sync/data/google_auth_service.dart';
import 'package:basic_bible/src/features/sync/data/notes_sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuth implements GoogleAuthService {
  int restoreCalls = 0;

  @override
  bool get isSupported => true;
  @override
  bool get isConfigured => true;
  @override
  Future<GoogleAccount?> restoreExistingSignIn() async {
    restoreCalls++;
    return const GoogleAccount(email: 'test@example.com');
  }

  @override
  Future<GoogleAccount> signIn() async =>
      const GoogleAccount(email: 'test@example.com');
  @override
  Future<String> getAccessToken() async => 'token';
  @override
  Future<void> signOut() async {}
}

class _FakeRepository implements NotesSyncRepository {
  int syncCalls = 0;
  bool fail = false;

  @override
  Future<SyncSummary> syncOnce() async {
    syncCalls++;
    if (fail) throw Exception('network down');
    return const SyncSummary(applied: 0, pushed: 0);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuth auth;
  late _FakeRepository repository;
  late DateTime now;

  setUp(() {
    auth = _FakeAuth();
    repository = _FakeRepository();
    now = DateTime(2026, 11, 3, 12);
  });

  Future<SyncController> controllerWith(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final controller = SyncController(
      auth,
      repository,
      await SharedPreferences.getInstance(),
      clock: () => now,
    );
    addTearDown(controller.dispose);
    // Let the async restore in the constructor settle.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return controller;
  }

  test(
    'never touches Google auth on launch for users who never signed in',
    () async {
      await controllerWith({});
      expect(auth.restoreCalls, 0);
      expect(repository.syncCalls, 0);
    },
  );

  test('restores and syncs on launch for signed-in users', () async {
    final controller = await controllerWith({'googleSyncSignedIn': true});
    expect(auth.restoreCalls, 1);
    expect(controller.state.isSignedIn, isTrue);
    expect(repository.syncCalls, 1);
  });

  test(
    'auto sync is throttled shortly after a success with no changes',
    () async {
      final controller = await controllerWith({'googleSyncSignedIn': true});
      expect(repository.syncCalls, 1);

      now = now.add(const Duration(minutes: 1));
      await controller.requestAutoSync();
      expect(repository.syncCalls, 1, reason: 'nothing changed, too soon');

      controller.markLocalChange();
      await controller.requestAutoSync();
      expect(repository.syncCalls, 2, reason: 'local edits bypass throttle');

      now = now.add(const Duration(minutes: 1));
      await controller.triggerSync();
      expect(repository.syncCalls, 3, reason: 'manual sync is never throttled');
    },
  );

  test('auto sync backs off after a failure', () async {
    final controller = await controllerWith({'googleSyncSignedIn': true});
    repository.fail = true;
    controller.markLocalChange();
    await controller.requestAutoSync();
    expect(repository.syncCalls, 2);
    expect(controller.state.phase, SyncPhase.error);

    now = now.add(const Duration(seconds: 30));
    await controller.requestAutoSync();
    expect(repository.syncCalls, 2, reason: 'inside 1 min backoff');

    now = now.add(const Duration(minutes: 1));
    repository.fail = false;
    await controller.requestAutoSync();
    expect(repository.syncCalls, 3);
    expect(controller.state.phase, SyncPhase.idle);
  });
}
